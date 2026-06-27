#!/bin/bash

# Generate dSYM bundles for embedded third-party frameworks (e.g. media_kit / libmpv).
# Required for TestFlight / App Store Connect symbol upload validation on Xcode 15+.

set +e

if [[ "${CONFIGURATION}" != "Release" && "${CONFIGURATION}" != "Profile" ]]; then
  exit 0
fi

if [[ -z "${DWARF_DSYM_FOLDER_PATH}" ]]; then
  echo "warning: DWARF_DSYM_FOLDER_PATH is not set; skipping framework dSYM generation"
  exit 0
fi

mkdir -p "${DWARF_DSYM_FOLDER_PATH}"

generate_dsym_for_framework() {
  local framework_path="$1"
  local framework_name
  framework_name="$(basename "${framework_path}" .framework)"
  local binary_path="${framework_path}/${framework_name}"
  local dsym_output="${DWARF_DSYM_FOLDER_PATH}/${framework_name}.framework.dSYM"

  if [[ -d "${dsym_output}" ]]; then
    return 0
  fi

  if [[ ! -f "${binary_path}" ]]; then
    return 0
  fi

  echo "Generating dSYM for ${framework_name}.framework"
  dsymutil "${binary_path}" -o "${dsym_output}"

  if [[ ! -d "${dsym_output}" ]]; then
    echo "warning: failed to generate dSYM for ${framework_name}.framework"
  fi
}

copy_existing_dsym() {
  local dsym_path="$1"
  local dsym_name
  dsym_name="$(basename "${dsym_path}")"
  local dest="${DWARF_DSYM_FOLDER_PATH}/${dsym_name}"

  if [[ -d "${dest}" ]]; then
    return 0
  fi

  echo "Copying ${dsym_name}"
  cp -R "${dsym_path}" "${dest}"
}

FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
if [[ -d "${FRAMEWORKS_DIR}" ]]; then
  find "${FRAMEWORKS_DIR}" -type d -name '*.framework' | while read -r framework; do
    generate_dsym_for_framework "${framework}"
  done
fi

SEARCH_PATHS=(
  "${PODS_ROOT}/../.symlinks/plugins/media_kit_libs_ios_video/ios/Frameworks"
  "${PODS_XCFRAMEWORKS_BUILD_DIR}"
  "${BUILT_PRODUCTS_DIR}"
)

for search_path in "${SEARCH_PATHS[@]}"; do
  if [[ -d "${search_path}" ]]; then
    find "${search_path}" -type d -name '*.dSYM' | while read -r dsym; do
      copy_existing_dsym "${dsym}"
    done
  fi
done

exit 0
