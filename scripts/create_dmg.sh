#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VERSION="1.0.0"
APP_NAME="Caffeine"
BUILD_DIR="${PROJECT_DIR}/build"
DIST_DIR="${PROJECT_DIR}/dist"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-v${VERSION}-macOS.dmg"
DMG_PATH="${DIST_DIR}/${DMG_NAME}"
STAGING_DIR="${BUILD_DIR}/dmg_staging"

# Ensure app is built
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "⚠️  ${APP_NAME}.app not found. Running build_app.sh first..."
    "${SCRIPT_DIR}/build_app.sh"
fi

echo "💿 Creating DMG disk image: ${DMG_PATH}..."

rm -rf "${STAGING_DIR}" "${DMG_PATH}"
mkdir -p "${STAGING_DIR}"
mkdir -p "${DIST_DIR}"

# Copy app to staging
cp -R "${APP_BUNDLE}" "${STAGING_DIR}/${APP_NAME}.app"

# Create Applications shortcut
ln -s /Applications "${STAGING_DIR}/Applications"

# Create DMG with hdiutil
hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${STAGING_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

rm -rf "${STAGING_DIR}"

echo "✅ DMG created successfully at: ${DMG_PATH}"
