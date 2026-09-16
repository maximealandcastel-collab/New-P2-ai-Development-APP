"""Validate release origin and record exactly what CI is about to build."""
import argparse
import datetime
import ipaddress
import json
import pathlib
import subprocess
from urllib.parse import urlparse

def validate_origin(value):
    uri = urlparse(value)
    if uri.scheme != 'https' or not uri.hostname or uri.username or uri.password or uri.query or uri.fragment or uri.path not in ('', '/'):
        raise ValueError('Use a permanent HTTPS origin without credentials, path or query')
    if uri.hostname == 'localhost' or uri.hostname.endswith(('.localhost', '.local', '.replit.dev')):
        raise ValueError('Development hosts cannot be released')
    try:
        ipaddress.ip_address(uri.hostname)
    except ValueError:
        return uri.geturl().rstrip('/')
    raise ValueError('Use the permanent production domain, not an IP address')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--origin', required=True)
    parser.add_argument('--build', type=int, required=True)
    args = parser.parse_args()
    if args.build <= 0:
        parser.error('Build number must be positive')
    origin = validate_origin(args.origin)
    commit = subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip()
    output = pathlib.Path('build/release-manifest.json')
    output.parent.mkdir(exist_ok=True)
    output.write_text(json.dumps({'commit': commit, 'apiOrigin': origin, 'buildNumber': args.build,
        'bundleId': 'com.p2pfittech.ai', 'version': '4.11.0', 'flutter': '3.41.4',
        'createdAt': datetime.datetime.now(datetime.timezone.utc).isoformat()}, indent=2)+'\n')
    print('Release configuration recorded:', output)
