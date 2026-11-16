"""Local synthetic-key checks; never uses CI or user signing credentials."""
import base64
from contextlib import redirect_stdout
import importlib.util
import io
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "prepare_ios_signing_keys.py"
spec = importlib.util.spec_from_file_location("signing_keys", SCRIPT)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class SigningKeysTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.key = subprocess.run(
            ["openssl", "genrsa", "2048"], capture_output=True, check=True,
        ).stdout.decode()

    def prepare(self, env, cached=None):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            cache = root / "cache.pem"
            if cached:
                cache.write_text(cached)
            with redirect_stdout(io.StringIO()) as logs:
                count = module.prepare_keys(env, cache, root / "out")
            self.assertNotIn(self.key.strip(), logs.getvalue())
            files = list((root / "out").glob("*.pem"))
            self.assertEqual(len(files), count)
            self.assertTrue(all(p.stat().st_mode & 0o777 == 0o600 for p in files))
            self.assertTrue(all(
                p.read_text().startswith("-----BEGIN RSA PRIVATE KEY-----")
                for p in files
            ))
            return count

    def test_plain_pem(self):
        self.assertEqual(self.prepare({"CERT_PRIVATE_KEY": self.key}), 1)

    def test_base64_pem(self):
        encoded = base64.b64encode(self.key.encode()).decode()
        self.assertEqual(self.prepare({"CERT_PRIVATE_KEY_B64": encoded}), 1)

    def test_collapsed_and_literal_newlines(self):
        for key in (self.key.replace("\n", ""), self.key.replace("\n", "\\n")):
            self.assertEqual(self.prepare({"CERT_PRIVATE_KEY": key}), 1)

    def test_identical_variables_and_cache_are_deduplicated(self):
        self.assertEqual(self.prepare({
            "CERT_PRIVATE_KEY": self.key,
            "CERT_PRIVATE_KEY_B64": base64.b64encode(self.key.encode()).decode(),
        }, self.key), 1)

    def test_invalid_variable_does_not_block_valid_cache(self):
        self.assertEqual(self.prepare({"CERT_PRIVATE_KEY_B64": "bad!"}, self.key), 1)

    def test_missing_or_invalid_material_fails_closed(self):
        for env in ({}, {"CERT_PRIVATE_KEY": "invalid"}):
            with self.assertRaises(ValueError):
                self.prepare(env)

    def test_workflow_never_generates_or_creates_certificates(self):
        yaml = (SCRIPT.parents[1] / "codemagic.yaml").read_text()
        self.assertNotIn("openssl genrsa", yaml)
        self.assertNotIn("--create \\", yaml)
        self.assertNotIn('--certificate-key "@file:', yaml)
        self.assertIn('CERTIFICATE_PRIVATE_KEY="$(cat "$CERTIFICATE_KEY")"', yaml)
        self.assertIn("prepare_ios_signing_keys.py", yaml)
        self.assertIn("pattern: elijah-stabilization", yaml)


if __name__ == "__main__":
    unittest.main()
