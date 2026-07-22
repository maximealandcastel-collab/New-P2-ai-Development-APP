#!/usr/bin/env bash
# Codemagic iOS TestFlight build — Shorebird release (creates OTA baseline).
set -eo pipefail

export PATH="$HOME/.shorebird/bin:$PATH"

APP_STORE_APPLE_ID="${APP_STORE_APPLE_ID:?APP_STORE_APPLE_ID must be set in Codemagic env vars}"
FLUTTER_VERSION="${FLUTTER_VERSION:-3.41.4}"

if ! command -v shorebird >/dev/null 2>&1; then
  echo "Error: shorebird not found on PATH. Run the Install Shorebird step first."
  exit 1
fi

if [[ -z "${SHOREBIRD_TOKEN:-}" ]]; then
  echo "Error: SHOREBIRD_TOKEN is not set. Add it to the Codemagic 'shorebird' env group."
  exit 1
fi

# Highest build number across all versions on TestFlight AND App Store
LATEST=$(app-store-connect get-latest-build-number \
    "$APP_STORE_APPLE_ID" \
    --platform IOS \
    --all-versions 2>/dev/null || true)

# Validate it's actually a number; default to 0 if missing/error
if ! [[ "$LATEST" =~ ^[0-9]+$ ]]; then
  echo "Warning: could not fetch build number (got: '$LATEST'), starting from 0"
  LATEST=0
fi

BUILD_NUM=$(( LATEST + 1 ))
echo "Latest on App Store Connect: ${LATEST} → New build: ${BUILD_NUM}"

# Read marketing version from pubspec (the part before '+')
MARKETING=$(grep '^version:' pubspec.yaml \
    | sed 's/version:[[:space:]]*//' \
    | cut -d'+' -f1)

echo "Marketing version: ${MARKETING}"

# Rewrite pubspec.yaml in place (perl works identically on macOS + Linux)
perl -i -pe "s/^version: .*/version: ${MARKETING}+${BUILD_NUM}/" pubspec.yaml

echo "pubspec.yaml → version: ${MARKETING}+${BUILD_NUM}"

# Generate export options from installed profiles.
# manageAppVersionAndBuildNumber=false is required so Xcode does not bump the
# build number on upload (which would break Shorebird patch matching).
xcode-project use-profiles \
  --custom-export-options={\"manageAppVersionAndBuildNumber\":false}
EXPORT_PLIST="${HOME}/export_options.plist"

if [[ ! -f "$EXPORT_PLIST" ]]; then
  echo "Error: ${EXPORT_PLIST} not found. Run Codemagic iOS signing before this step."
  exit 1
fi

# Shorebird release = IPA for TestFlight + baseline for future OTA patches
shorebird release ios \
  --flutter-version="$FLUTTER_VERSION" \
  --build-name="$MARKETING" \
  --build-number="$BUILD_NUM" \
  --export-options-plist="$EXPORT_PLIST"
