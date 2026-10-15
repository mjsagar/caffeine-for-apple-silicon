#!/usr/bin/env bash
set -euo pipefail

# Determine script and project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

VERSION="1.0.0"
APP_NAME="Caffeine"
BUILD_DIR="${PROJECT_DIR}/build"
DIST_DIR="${PROJECT_DIR}/dist"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CACHE_DIR="/tmp/clang-cache"

echo "☕ Building ${APP_NAME} v${VERSION} (Universal: Apple Silicon arm64 + Intel x86_64)..."

mkdir -p "${BUILD_DIR}"
mkdir -p "${DIST_DIR}"
mkdir -p "${CACHE_DIR}"

# 1. Generate AppIcon.icns if needed
if [ ! -f "${PROJECT_DIR}/Resources/AppIcon.icns" ]; then
    echo "🎨 Generating AppIcon.icns..."
    swiftc -module-cache-path "${CACHE_DIR}" \
           -parse-as-library \
           -target arm64-apple-macos11.0 \
           "${PROJECT_DIR}/scripts/generate_icons.swift" \
           -o "${BUILD_DIR}/generate_icons"
    "${BUILD_DIR}/generate_icons"
fi

# 2. Compile ARM64 binary (Apple Silicon)
echo "⚡ Compiling for arm64 (Apple Silicon)..."
swiftc -O \
       -module-cache-path "${CACHE_DIR}" \
       -target arm64-apple-macos11.0 \
       -o "${BUILD_DIR}/${APP_NAME}_arm64" \
       ${PROJECT_DIR}/Sources/Caffeine/*.swift

# 3. Compile x86_64 binary (Intel)
echo "⚡ Compiling for x86_64 (Intel)..."
swiftc -O \
       -module-cache-path "${CACHE_DIR}" \
       -target x86_64-apple-macos11.0 \
       -o "${BUILD_DIR}/${APP_NAME}_x86_64" \
       ${PROJECT_DIR}/Sources/Caffeine/*.swift

# 4. Create Universal Binary using lipo
echo "🔗 Creating Universal Binary..."
lipo -create \
     -output "${BUILD_DIR}/${APP_NAME}" \
     "${BUILD_DIR}/${APP_NAME}_arm64" \
     "${BUILD_DIR}/${APP_NAME}_x86_64"

lipo -info "${BUILD_DIR}/${APP_NAME}"

# 5. Assemble macOS App Bundle
echo "📦 Assembling ${APP_NAME}.app bundle..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp "${PROJECT_DIR}/Resources/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
cp "${PROJECT_DIR}/Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# 6. Ad-hoc code signing
echo "🔏 Code signing ${APP_NAME}.app..."
codesign --force --deep --sign - "${APP_BUNDLE}"
codesign --verify --deep --strict "${APP_BUNDLE}"

# 7. Package ZIP distribution
ZIP_NAME="${APP_NAME}-v${VERSION}-macOS.zip"
echo "🗜️  Packaging ${DIST_DIR}/${ZIP_NAME}..."
ditto -c -k --sequesterRsrc --keepParent "${APP_BUNDLE}" "${DIST_DIR}/${ZIP_NAME}"

echo "✅ Build complete!"
echo "   App Bundle: ${APP_BUNDLE}"
echo "   Zip Release: ${DIST_DIR}/${ZIP_NAME}"
