"""Tests use synthetic errors only; no real credentials or Apple calls."""
from contextlib import redirect_stderr, redirect_stdout
import importlib.util
import io
import json
import logging
from pathlib import Path
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "diagnose_ios_signing.py"
spec = importlib.util.spec_from_file_location("signing_diagnostics", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SigningDiagnosticsTest(unittest.TestCase):
    def test_success_does_not_return_material(self):
        result = module.probe_loader(lambda key, password: key, b"fake-secret", None)
        self.assertEqual(result, {"accepted": True})
        self.assertNotIn("fake-secret", json.dumps(result))

    def test_password_error_is_categorized_without_leaking(self):
        def loader(key, password):
            print(key)
            logging.error("secret password %s", password)
            raise TypeError("Password was given but private key is not encrypted")
        with redirect_stdout(io.StringIO()) as out, redirect_stderr(io.StringIO()) as err:
            result = module.probe_loader(loader, b"fake-key", "fake-password")
        self.assertEqual(out.getvalue(), "")
        self.assertEqual(err.getvalue(), "")
        self.assertIn("password_on_unencrypted_key", result["reasons"])
        self.assertNotIn("fake", json.dumps(result))

    def test_nested_cause_survives_generic_cli_error(self):
        inner = ValueError("Could not deserialize key data: fake-secret")
        outer = ValueError("Invalid private key PEM content")
        outer.__cause__ = inner
        reasons = module.classify_error(outer)
        self.assertIn("deserialization_failed", reasons)
        self.assertNotIn("fake-secret", json.dumps(reasons))

    def test_unknown_exception_text_is_never_returned(self):
        self.assertEqual(
            module.classify_error(RuntimeError("fake-secret")),
            ["unclassified_key_loading_error"],
        )

    def test_logging_configuration_is_restored(self):
        before = logging.root.manager.disable
        module.probe_loader(lambda *_: None, b"fake-key", None)
        self.assertEqual(logging.root.manager.disable, before)

    def test_workflow_runs_diagnostic_before_apple_fetch(self):
        yaml = (SCRIPT.parents[1] / "codemagic.yaml").read_text()
        loop = yaml[yaml.index('for CERTIFICATE_KEY in "$CANDIDATE_DIR"/*.pem; do'):]
        self.assertLess(loop.index("diagnose_ios_signing.py"), loop.index("fetch_signing_files"))
        self.assertNotIn("--create \\", yaml)


if __name__ == "__main__":
    unittest.main()
