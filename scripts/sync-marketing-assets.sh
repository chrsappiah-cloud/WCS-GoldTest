#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_SRC="${CURSOR_ASSETS:-$HOME/.cursor/projects/Applications-WCS-GoldTest/assets}"
DESKTOP="${HOME}/Desktop/WCS-GoldTest-Marketing"
MARKETING="$ROOT/Marketing"
ICONS="$ROOT/WCS-GoldTest/Assets.xcassets/AppIcon.appiconset"

mkdir -p "$MARKETING/images" "$DESKTOP/AppIcon" "$DESKTOP/Promotional" "$DESKTOP/InvestorDeck/images" "$ICONS"

copy_if_exists() {
  local src="$1" dest="$2"
  if [[ -f "$src" ]]; then
    cp "$src" "$dest"
    echo "Copied $(basename "$src") -> $dest"
  else
    echo "Missing: $src" >&2
  fi
}

# App icon
copy_if_exists "$ASSET_SRC/WCS-GoldTest-AppIcon.png" "$ICONS/AppIcon-1024.png"
copy_if_exists "$ASSET_SRC/WCS-GoldTest-AppIcon.png" "$ICONS/AppIcon-1024-dark.png"

# Marketing images
for f in promo-hero feature-gold-scan feature-vault feature-reports feature-pairing feature-premium; do
  copy_if_exists "$ASSET_SRC/${f}.png" "$MARKETING/images/${f}.png"
  copy_if_exists "$ASSET_SRC/${f}.png" "$DESKTOP/Promotional/${f}.png"
  copy_if_exists "$ASSET_SRC/${f}.png" "$DESKTOP/InvestorDeck/images/${f}.png"
done

copy_if_exists "$ASSET_SRC/WCS-GoldTest-AppIcon.png" "$DESKTOP/AppIcon/WCS-GoldTest-AppIcon-1024.png"
copy_if_exists "$MARKETING/investor-deck.html" "$DESKTOP/InvestorDeck/investor-deck.html"

echo "Marketing assets synced to Desktop: $DESKTOP"
