#!/usr/bin/env python3
"""Prepare existing CI signing keys without printing or generating key material."""
import argparse
import base64
import os
from pathlib import Path
import re
import subprocess
import sys


def normalize_pem(raw):
    text = raw.decode("utf-8").replace("\\r", "").replace("\\n", "\n").strip()
    match = re.fullmatch(
        r"-----BEGIN (RSA PRIVATE KEY|PRIVATE KEY)-----(.*?)-----END \1-----",
        text, re.DOTALL,
    )
    if not match:
        raise ValueError("Unsupported private-key format")
    body = re.sub(r"\s+", "", match.group(2))
    base64.b64decode(body, validate=True)
    folded = "\n".join(body[i:i + 64] for i in range(0, len(body), 64))
    label = match.group(1)
    return f"-----BEGIN {label}-----\n{folded}\n-----END {label}-----\n".encode()


def prepare_keys(env, cache, output):
    output.mkdir(parents=True, exist_ok=True)
    output.chmod(0o700)
    sources = []
    for name in ("CERT_PRIVATE_KEY", "CERT_PRIVATE_KEY_B64"):
        value = env.get(name, "").strip()
        if value:
            sources.append((name, value))
    if cache.is_file():
        sources.append(("signing cache", cache.read_text()))
    seen = set()
    for label, value in sources:
        try:
            raw = value.encode()
            if label == "CERT_PRIVATE_KEY_B64":
                raw = base64.b64decode(re.sub(rb"\s+", b"", raw), validate=True)
            pem = normalize_pem(raw)
            # Validate and canonicalize without exposing input or OpenSSL errors.
            result = subprocess.run(
                ["openssl", "rsa", "-traditional", "-passin", "pass:", "-outform", "PEM"],
                input=pem, capture_output=True, check=False,
            )
            if result.returncode != 0 or not result.stdout:
                raise ValueError("Invalid or encrypted private key")
            canonical = result.stdout
            if canonical in seen:
                continue
            seen.add(canonical)
            destination = output / f"key-{len(seen):02d}.pem"
            with destination.open("xb") as target:
                destination.chmod(0o600)
                target.write(canonical)
            print(f"Prepared existing signing key from {label}; value hidden")
        except (ValueError, UnicodeError):
            print(f"WARNING: {label} is not a usable unencrypted PEM key; value hidden")
    if not seen:
        raise ValueError(
            "No usable existing signing key. Restore CERT_PRIVATE_KEY or "
            "CERT_PRIVATE_KEY_B64 in Codemagic's secure appstore group. "
            "No new Apple certificate will be requested."
        )
    return len(seen)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--cache", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    try:
        prepare_keys(os.environ, args.cache, args.output)
    except (ValueError, OSError) as error:
        # All messages are fixed strings or filesystem errors, never secret values.
        print(f"ERROR: {error}", file=sys.stderr)
        sys.exit(1)
