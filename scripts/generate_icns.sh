#!/bin/bash
set -e

# Path to logo PNG
LOGO_PNG="Sources/YubiToggle/Resources/YubiToggleLogo.png"
OUTPUT_DIR="Sources/YubiToggle/Resources"
ICONSET_DIR="${OUTPUT_DIR}/AppIcon.iconset"
TEMP_PNG="Sources/YubiToggle/Resources/YubiToggleLogo_temp.png"

echo "Setting up virtual environment for Python Pillow..."
python3 -m venv venv_temp
source venv_temp/bin/activate
pip install --quiet pillow

echo "Processing image to make black background transparent..."
python3 scripts/make_transparent.py "$LOGO_PNG" "$TEMP_PNG"

echo "Deactivating and cleaning up virtual environment..."
deactivate
rm -rf venv_temp

echo "Creating iconset directory..."
mkdir -p "$ICONSET_DIR"

# Resize images using sips
sips -z 16 16     "$TEMP_PNG" --out "${ICONSET_DIR}/icon_16x16.png"
sips -z 32 32     "$TEMP_PNG" --out "${ICONSET_DIR}/icon_16x16@2x.png"
sips -z 32 32     "$TEMP_PNG" --out "${ICONSET_DIR}/icon_32x32.png"
sips -z 64 64     "$TEMP_PNG" --out "${ICONSET_DIR}/icon_32x32@2x.png"
sips -z 128 128   "$TEMP_PNG" --out "${ICONSET_DIR}/icon_128x128.png"
sips -z 256 256   "$TEMP_PNG" --out "${ICONSET_DIR}/icon_128x128@2x.png"
sips -z 256 256   "$TEMP_PNG" --out "${ICONSET_DIR}/icon_256x256.png"
sips -z 512 512   "$TEMP_PNG" --out "${ICONSET_DIR}/icon_256x256@2x.png"
sips -z 512 512   "$TEMP_PNG" --out "${ICONSET_DIR}/icon_512x512.png"
sips -z 1024 1024 "$TEMP_PNG" --out "${ICONSET_DIR}/icon_512x512@2x.png"

echo "Compiling iconset into AppIcon.icns..."
iconutil -c icns "$ICONSET_DIR" -o "${OUTPUT_DIR}/AppIcon.icns"

# Clean up temporary files
rm -rf "$ICONSET_DIR"
rm -f "$TEMP_PNG"

echo "AppIcon.icns generated successfully!"
