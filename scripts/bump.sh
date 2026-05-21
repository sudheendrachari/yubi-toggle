#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Error: Please specify the new version (e.g. 1.0.2)"
    echo "Usage: $0 <version>"
    exit 1
fi

NEW_VERSION="$1"

# Validate version format (e.g. 1.0.2)
if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g. 1.0.2)"
    exit 1
fi

# Get current version from Info.plist
CURRENT_VERSION=$(sed -n 's/.*<key>CFBundleShortVersionString<\/key>.*<string>\([^<]*\)<\/string>.*/\1/p' Sources/YubiToggle/Resources/Info.plist | xargs)

if [ -z "$CURRENT_VERSION" ]; then
    # Fallback search if on separate lines
    CURRENT_VERSION=$(grep -A1 "CFBundleShortVersionString" Sources/YubiToggle/Resources/Info.plist | grep string | sed 's/.*<string>\(.*\)<\/string>.*/\1/' | xargs)
fi

echo "Bumping version from $CURRENT_VERSION to $NEW_VERSION..."

# Update Info.plist
sed -i '' "s/<string>$CURRENT_VERSION<\/string>/<string>$NEW_VERSION<\/string>/g" Sources/YubiToggle/Resources/Info.plist || \
sed -i "s/<string>$CURRENT_VERSION<\/string>/<string>$NEW_VERSION<\/string>/g" Sources/YubiToggle/Resources/Info.plist

# Update SettingsView.swift
sed -i '' "s/?? \"$CURRENT_VERSION\"/?? \"$NEW_VERSION\"/g" Sources/YubiToggle/Views/SettingsView.swift || \
sed -i "s/?? \"$CURRENT_VERSION\"/?? \"$NEW_VERSION\"/g" Sources/YubiToggle/Views/SettingsView.swift

# Update Homebrew Formula
sed -i '' "s/version \"$CURRENT_VERSION\"/version \"$NEW_VERSION\"/g" HomebrewFormula/yubitoggle.rb || \
sed -i "s/version \"$CURRENT_VERSION\"/version \"$NEW_VERSION\"/g" HomebrewFormula/yubitoggle.rb

echo "Success! Bumed version to $NEW_VERSION."
echo "You can now commit and push the changes, then tag it:"
echo "  git add ."
echo "  git commit -m \"chore: bump version to v$NEW_VERSION\""
echo "  git tag v$NEW_VERSION"
echo "  git push origin main --tags"
