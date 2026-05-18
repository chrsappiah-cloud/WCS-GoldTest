#!/bin/bash
# Build, run UI tests on iPhone Simulator (mock BLE + firmware simulation).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 16}"
DESTINATION="platform=iOS Simulator,name=${SIMULATOR_NAME},OS=latest"

cd "$ROOT"
export PATH="/opt/homebrew/opt/ruby/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

echo "Booting ${SIMULATOR_NAME}..."
xcrun simctl boot "$SIMULATOR_NAME" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_NAME" -b 2>/dev/null || true

echo "Building Debug for simulator..."
xcodebuild build \
  -project WCS-GoldTest.xcodeproj \
  -scheme WCS-GoldTest \
  -destination "$DESTINATION" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO

echo "Running UI tests (mock BLE, all tabs)..."
xcodebuild test \
  -project WCS-GoldTest.xcodeproj \
  -scheme WCS-GoldTest \
  -destination "$DESTINATION" \
  -only-testing:WCS-GoldTestUITests \
  CODE_SIGNING_ALLOWED=NO

echo "Simulator UI tests passed."
