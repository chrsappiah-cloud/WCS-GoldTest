#!/usr/bin/env bash
set -euo pipefail

pick_simulator() {
  local line name
  for pattern in "iPhone 17 Pro" "iPhone 17" "iPhone 16 Pro" "iPhone 16" "iPhone 15" "E2E-Test-iPhone"; do
    line="$(xcrun simctl list devices available | grep -F "$pattern" | head -1 || true)"
    if [[ -n "$line" ]]; then
      name="$(sed -E 's/^[[:space:]]+([^(]+)\(.*/\1/' <<<"$line" | xargs)"
      echo "$name"
      return 0
    fi
  done

  line="$(xcrun simctl list devices available | grep -E '^\s+.+\([0-9A-F-]{36}\)' | head -1 || true)"
  if [[ -n "$line" ]]; then
    sed -E 's/^[[:space:]]+([^(]+)\(.*/\1/' <<<"$line" | xargs
    return 0
  fi

  echo "No iOS simulator found" >&2
  return 1
}

SIMULATOR_NAME="$(pick_simulator)"
>&2 echo "Using simulator: $SIMULATOR_NAME"
echo "simulator_name=$SIMULATOR_NAME"
