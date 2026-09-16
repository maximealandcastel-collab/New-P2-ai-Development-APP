import importlib.util
from pathlib import Path
import unittest
spec = importlib.util.spec_from_file_location('release_config', Path(__file__).parents[1] / 'verify_release_config.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

class ReleaseConfigTests(unittest.TestCase):
    def test_permanent_https_origin(self):
        self.assertEqual(module.validate_origin('https://p2pfitechai.com/'), 'https://p2pfitechai.com')
    def test_reject_development_and_credential_urls(self):
        for url in ['http://p2pfitechai.com','https://localhost','https://127.0.0.1','https://[::1]','https://example.replit.dev','https://user:password@example.com','https://example.com/api','https://example.com?debug=1']:
            with self.subTest(url=url), self.assertRaises(ValueError): module.validate_origin(url)

if __name__ == '__main__': unittest.main()
