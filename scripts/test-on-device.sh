#!/bin/bash
set -euo pipefail
DEVICE_ID="${DEVICE_ID:-00008150-001102643CD2401C}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Building for device $DEVICE_ID..."
xcodebuild -project "$ROOT/WCS-GoldTest.xcodeproj" \
  -scheme WCS-GoldTest \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  build

APP="$HOME/Library/Developer/Xcode/DerivedData/Build/Products/Debug-iphoneos/WCS-GoldTest.app"
echo "Installing on device..."
xcrun devicectl device install app --device "$DEVICE_ID" "$APP"

echo "Running UI tests on device..."
xcodebuild test -project "$ROOT/WCS-GoldTest.xcodeproj" \
  -scheme WCS-GoldTest \
  -destination "platform=iOS,id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  -only-testing:WCS-GoldTestUITests

echo "Done. Unit tests with SwiftData run best on simulator:"
echo "  xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:WCS-GoldTestTests"
