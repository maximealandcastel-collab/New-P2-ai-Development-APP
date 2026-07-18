#!/usr/bin/env bash
# Codemagic iOS TestFlight build — Flutter only (no Shorebird).
set -eo pipefail

# Generate export_options.plist from installed profiles
xcode-project use-profiles

EXPORT_PLIST="${HOME}/export_options.plist"
BUILD_NUM="${PROJECT_BUILD_NUMBER:-${BUILD_NUMBER:-}}"

if [[ ! -f "${EXPORT_PLIST}" ]]; then
  echo "Error: ${EXPORT_PLIST} not found. Codemagic iOS signing must run before this step."
  exit 1
fi

if [[ -z "${BUILD_NUM}" ]]; then
  echo "Error: PROJECT_BUILD_NUMBER or BUILD_NUMBER is not set."
  echo "Enable build number increment in Codemagic project settings."
  exit 1
fi

if command -v shorebird >/dev/null 2>&1; then
  echo "Note: Shorebird CLI is installed but this script uses flutter build ipa only."
fi

flutter build ipa \
  --release \
  --export-options-plist="${EXPORT_PLIST}" \
  --build-number="${BUILD_NUM}"