#!/bin/bash
# Upload WCS-GoldTest to TestFlight via Fastlane
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f fastlane/.env ]]; then
  echo "Create fastlane/.env from fastlane/.env.example with your App Store Connect API key."
  exit 1
fi

export $(grep -v '^#' fastlane/.env | xargs)

echo "Installing Ruby gems..."
bundle install --path vendor/bundle 2>/dev/null || bundle install

echo "Uploading to TestFlight (App Store Connect app 6770415355)..."
bundle exec fastlane ios beta

echo "Done. Open TestFlight in App Store Connect to add testers."
