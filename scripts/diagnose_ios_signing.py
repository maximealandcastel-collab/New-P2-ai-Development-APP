#!/usr/bin/env python3
"""Offline signing diagnostics. Never print key material, passwords or tracebacks."""
import argparse
from contextlib import redirect_stderr, redirect_stdout
import importlib.metadata
import io
import json
import logging
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys


def classify_error(error):
    """Only emit fixed labels, not arbitrary exception messages or arguments."""
    kinds = []
    visited = set()
    while error is not None and id(error) not in visited:
        visited.add(id(error))
        message = str(error).lower()
        for fragment, label in (
            ("password was given but private key is not encrypted", "password_on_unencrypted_key"),
            ("password was not given but private key is encrypted", "encrypted_key_requires_password"),
            ("invalid private key passphrase", "passphrase_rejected"),
            ("bad decrypt", "decryption_failed"),
            ("incorrect password", "passphrase_rejected"),
            ("invalid pem", "pem_rejected"),
            ("malformed", "malformed_key"),
            ("could not deserialize", "deserialization_failed"),
            ("unsupported", "unsupported_format_or_algorithm"),
            ("not prime", "rsa_prime_validation_failed"),
            ("invalid private key", "private_key_validation_failed"),
        ):
            if fragment in message and label not in kinds:
                kinds.append(label)
        error = error.__cause__ or error.__context__
    return kinds or ["unclassified_key_loading_error"]


def probe_loader(loader, material, password):
    # Codemagic logs exception details internally. Suppress those logs and streams,
    # then return only our allowlisted reason codes.
    previous_logging = logging.root.manager.disable
    try:
        logging.disable(logging.CRITICAL)
        with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            loader(material, password)
        return {"accepted": True}
    except Exception as error:
        return {"accepted": False, "reasons": classify_error(error)}
    finally:
        logging.disable(previous_logging)


def version(package):
    try:
        value = importlib.metadata.version(package)
        return value if re.fullmatch(r"[A-Za-z0-9.+_-]{1,80}", value) else "unavailable"
    except importlib.metadata.PackageNotFoundError:
        return "unavailable"


def worker(key_path):
    report = {
        "python": ".".join(map(str, sys.version_info[:3])),
        "codemagic_cli": version("codemagic-cli-tools"),
        "cryptography": version("cryptography"),
        "certificate_password_present": "CERTIFICATE_PRIVATE_KEY_PASSWORD" in os.environ,
    }
    try:
        with redirect_stdout(io.StringIO()), redirect_stderr(io.StringIO()):
            from codemagic.models import PrivateKey
            from cryptography.hazmat.primitives.serialization import load_pem_private_key
            material = key_path.read_bytes()
        report["cryptography_without_password"] = probe_loader(load_pem_private_key, material, None)
        report["codemagic_without_password"] = probe_loader(PrivateKey.from_buffer, material, None)
        report["codemagic_with_cli_password_setting"] = probe_loader(
            PrivateKey.from_buffer, material,
            os.environ.get("CERTIFICATE_PRIVATE_KEY_PASSWORD"),
        )
    except Exception as error:
        report["diagnostic_setup"] = {
            "accepted": False,
            "reasons": (
                ["diagnostic_dependency_unavailable"]
                if isinstance(error, ImportError) else classify_error(error)
            ),
        }
    print("SIGNING_DIAGNOSTIC " + json.dumps(report, sort_keys=True))


def cli_python():
    """Use the tool's interpreter, not an unrelated system Python environment."""
    executable = shutil.which("app-store-connect")
    if not executable:
        return None
    try:
        with open(executable, "rb") as source:
            first = source.readline(1024).decode("utf-8")
        if not first.startswith("#!"):
            return None
        command = shlex.split(first[2:].strip())
        if Path(command[0]).name == "env":
            command = command[1:]
            if command and command[0] == "-S":
                command = command[1:]
        if command and Path(command[0]).name.startswith("python"):
            return command
    except (OSError, UnicodeError, ValueError, IndexError):
        pass
    return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--key", type=Path, required=True)
    parser.add_argument("--worker", action="store_true")
    args = parser.parse_args()
    if args.worker:
        worker(args.key)
        return
    interpreter = cli_python()
    if not interpreter:
        print("SIGNING_DIAGNOSTIC tool_interpreter_unavailable; no secrets printed")
        return
    try:
        result = subprocess.run(
            [*interpreter, str(Path(__file__).resolve()), "--worker", "--key", str(args.key)],
            capture_output=True, text=True, timeout=30, check=False,
        )
        # Worker output contains only version metadata, booleans and fixed codes.
        lines = [line for line in result.stdout.splitlines() if line.startswith("SIGNING_DIAGNOSTIC ")]
        if result.returncode == 0 and lines:
            print(lines[-1])
        else:
            print("SIGNING_DIAGNOSTIC worker_failed; raw output suppressed")
    except (OSError, subprocess.TimeoutExpired):
        print("SIGNING_DIAGNOSTIC worker_unavailable_or_timed_out; raw output suppressed")


if __name__ == "__main__":
    main()
