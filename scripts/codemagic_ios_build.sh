#!/usr/bin/env bash
# Codemagic iOS TestFlight build — Flutter only (no Shorebird).
set -eo pipefail

# Generate export_options.plist from installed profiles
xcode-project use-profiles

EXPORT_PLIST="${HOME}/export_options.plist"

if [[ ! -f "${EXPORT_PLIST}" ]]; then
  echo "Error: ${EXPORT_PLIST} not found. Codemagic iOS signing must run before this step."
  exit 1
fi

# Auto-increment build number from App Store Connect
LATEST_BUILD=$(app-store-connect get-latest-build-number \
  --bundle-id com.p2pfittech.ai \
  --platform IOS \
  --pre-release 2>/dev/null || echo "33")
BUILD_NUM=$((LATEST_BUILD + 1))
echo "Using build number: ${BUILD_NUM}"

if command -v shorebird >/dev/null 2>&1; then
  echo "Note: Shorebird CLI is installed but this script uses flutter build ipa only."
fi

flutter build ipa \
  --release \
  --export-options-plist="${EXPORT_PLIST}" \
  --build-number="${BUILD_NUM}"