#!/bin/bash
# Push GitHub Actions secrets for TestFlight CD on chrsappiah-cloud/WCS-GoldTest.
#
# Run in Terminal.app if keychain export prompts for your Mac password.
# Usage: bash scripts/setup-testflight-secrets.sh

set -euo pipefail

REPO="${GITHUB_REPO:-chrsappiah-cloud/WCS-GoldTest}"
TEAM_ID="TM2WG7HH96"
ISSUER_ID="70c46c69-5d6d-438d-b300-31df2b93163a"
KEY_ID="KLH62AX56M"
P8="${HOME}/.appstoreconnect/private_keys/AuthKey_${KEY_ID}.p8"
P12_PASSWORD="${IOS_DISTRIBUTION_CERTIFICATE_PASSWORD:-wcs-ci-temp}"

if ! command -v gh >/dev/null; then
  echo "Install GitHub CLI: brew install gh"
  exit 1
fi

if [[ ! -f "$P8" ]]; then
  echo "Missing API key: $P8"
  exit 1
fi

STORE_PROFILE=""
for f in "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/"*.mobileprovision; do
  xml=$(security cms -D -i "$f" 2>/dev/null) || continue
  appid=$(echo "$xml" | plutil -extract Entitlements.application-identifier raw -o - - 2>/dev/null || true)
  task=$(echo "$xml" | plutil -extract Entitlements.get-task-allow raw -o - - 2>/dev/null || true)
  [[ "$appid" == *"WCS-GoldTest" && "$task" == "false" ]] || continue
  STORE_PROFILE="$f"
  break
done

if [[ -z "$STORE_PROFILE" ]]; then
  echo "No App Store provisioning profile for wcs.WCS-GoldTest."
  echo "Archive once in Xcode (Product → Archive) with automatic signing."
  exit 1
fi

echo "Using profile: $STORE_PROFILE"
echo "Pushing secrets to $REPO ..."

gh secret set APP_STORE_CONNECT_API_KEY_ID --repo "$REPO" --body "$KEY_ID"
gh secret set APP_STORE_CONNECT_ISSUER_ID --repo "$REPO" --body "$ISSUER_ID"
gh secret set APP_STORE_CONNECT_API_KEY_CONTENT --repo "$REPO" --body "$(base64 < "$P8" | tr -d '\n')"
gh secret set DEVELOPMENT_TEAM_ID --repo "$REPO" --body "$TEAM_ID"
gh secret set APPLE_ID --repo "$REPO" --body "chrsappiah@gmail.com"
gh secret set TESTFLIGHT_GROUPS --repo "$REPO" --body "WCS Gold Internal"
gh secret set IOS_PROVISIONING_PROFILE_BASE64 --repo "$REPO" --body "$(base64 < "$STORE_PROFILE" | tr -d '\n')"

CERT_LINE=$(security find-identity -v -p codesigning | grep "Apple Distribution: Christopher Appiah-Thompson ($TEAM_ID)" | head -1)
if [[ -z "$CERT_LINE" ]]; then
  echo "Apple Distribution certificate not found."
  exit 1
fi

SHA1=$(echo "$CERT_LINE" | awk '{print $2}')
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

security export -k "$HOME/Library/Keychains/login.keychain-db" -t identities -f pkcs12 \
  -P "$P12_PASSWORD" -o "$TMPDIR/dist.p12" "$SHA1"

gh secret set IOS_DISTRIBUTION_CERTIFICATE_BASE64 --repo "$REPO" --body "$(base64 < "$TMPDIR/dist.p12" | tr -d '\n')"
gh secret set IOS_DISTRIBUTION_CERTIFICATE_PASSWORD --repo "$REPO" --body "$P12_PASSWORD"

echo "Done. Run: bash scripts/enforce-branch-protection.sh"
