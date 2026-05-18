#!/bin/bash
# Build, install, and run UI tests on a physical iPhone (real CoreBluetooth).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEVICE_ID="${DEVICE_ID:-00008150-001102643CD2401C}"
COREDEVICE_ID="${COREDEVICE_ID:-9D1F4302-903A-5348-B555-308AAB62C9B2}"
DESTINATION="platform=iOS,id=${DEVICE_ID}"

cd "$ROOT"

if ! xcrun xctrace list devices 2>&1 | grep -q "$DEVICE_ID"; then
  echo "Warning: xctrace shows device offline; trying devicectl install anyway."
  xcrun devicectl list devices 2>&1 | head -10
fi

echo "Building for device $DEVICE_ID..."
xcodebuild build \
  -project WCS-GoldTest.xcodeproj \
  -scheme WCS-GoldTest \
  -destination "$DESTINATION" \
  -allowProvisioningUpdates \
  -configuration Debug

APP=$(find ~/Library/Developer/Xcode/DerivedData -path "*Debug-iphoneos/WCS-GoldTest.app" -maxdepth 6 2>/dev/null | head -1)
if [[ -z "$APP" ]]; then
  echo "Could not locate WCS-GoldTest.app in DerivedData."
  exit 1
fi

echo "Installing on device..."
xcrun devicectl device install app --device "$COREDEVICE_ID" "$APP" \
  || xcrun devicectl device install app --device "$DEVICE_ID" "$APP"

echo "Launching app..."
xcrun devicectl device process launch --device "$COREDEVICE_ID" wcs.WCS-GoldTest 2>/dev/null || true

echo "Running UI tests on device (real BLE — pair probe in Settings)..."
xcodebuild test \
  -project WCS-GoldTest.xcodeproj \
  -scheme WCS-GoldTest \
  -destination "$DESTINATION" \
  -allowProvisioningUpdates \
  -only-testing:WCS-GoldTestUITests

echo "Done. Open the app on your iPhone to pair a physical WCS probe and activate firmware."
