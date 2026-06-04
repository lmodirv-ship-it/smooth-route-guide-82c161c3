#!/usr/bin/env bash
# Build one **NATIVE (bundled) APK** per role.
# All web assets are embedded inside the APK → works fully offline,
# but every code change requires rebuilding & redistributing the APK.
#
# Usage: bash scripts/build-apk.sh <role>
#   role = general | admin | callcenter | client | delivery | driver | store
set -euo pipefail

ROLE="${1:-}"
case "$ROLE" in
  general|admin|callcenter|client|delivery|driver|store) ;;
  *) echo "Usage: $0 <general|admin|callcenter|client|delivery|driver|store>"; exit 1 ;;
esac

CONFIG="capacitor.config.${ROLE}.json"
[ -f "$CONFIG" ] || { echo "Missing $CONFIG"; exit 1; }

# Map role → vite build command
declare -A BUILD_CMD=(
  [general]="pnpm build"
  [admin]="pnpm build:admin"
  [callcenter]="vite build --config vite.config.call-center.ts"
  [client]="pnpm build:client"
  [delivery]="pnpm build:driver-delivery"
  [driver]="pnpm build:driver-ride"
  [store]="pnpm build"
)

echo "→ [$ROLE] Using $CONFIG"
cp "$CONFIG" capacitor.config.json

echo "→ [$ROLE] Installing deps..."
pnpm install --frozen-lockfile

echo "→ [$ROLE] Building bundled web assets..."
eval "${BUILD_CMD[$ROLE]}"

echo "→ [$ROLE] Syncing native Android (embedding assets)..."
npx cap sync android

echo "→ [$ROLE] Assembling release APK..."
cd android && ./gradlew assembleRelease
cd ..

SRC="android/app/build/outputs/apk/release/app-release-unsigned.apk"
DEST="public/downloads/apps/hn-${ROLE}.apk"
mkdir -p public/downloads/apps
cp "$SRC" "$DEST"

echo ""
echo "✅ Native APK built → $DEST"
echo "ℹ️  Sign it via Android Studio (Build → Generate Signed APK) before publishing."
echo "⚠️  This is a BUNDLED APK — any future code change requires rebuilding & redistributing."
