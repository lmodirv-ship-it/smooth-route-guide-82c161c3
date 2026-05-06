#!/usr/bin/env bash
# ============================================================
# 🚀 HN Driver — Google Play AAB Build Script
# Builds a signed Android App Bundle (.aab) ready for Play Console.
# ============================================================
set -euo pipefail

echo "🧹 Step 1/5 — Installing dependencies..."
pnpm install --frozen-lockfile

echo "🏗️  Step 2/5 — Building web bundle..."
pnpm build

echo "📱 Step 3/5 — Capacitor sync..."
npx cap sync android

echo "🔢 Step 4/5 — Auto-incrementing versionCode..."
GRADLE_FILE="android/app/build.gradle"
CURRENT_CODE=$(grep -oE 'versionCode [0-9]+' "$GRADLE_FILE" | awk '{print $2}')
NEW_CODE=$((CURRENT_CODE + 1))
sed -i.bak "s/versionCode $CURRENT_CODE/versionCode $NEW_CODE/" "$GRADLE_FILE"
rm -f "$GRADLE_FILE.bak"
echo "   versionCode: $CURRENT_CODE → $NEW_CODE"

echo "📦 Step 5/5 — Building release AAB (Gradle bundleRelease)..."
cd android && ./gradlew bundleRelease

AAB_PATH="app/build/outputs/bundle/release/app-release.aab"
if [ -f "$AAB_PATH" ]; then
  SIZE=$(du -h "$AAB_PATH" | cut -f1)
  echo ""
  echo "✅ DONE — App Bundle ready for Google Play."
  echo "📦 Path: android/$AAB_PATH"
  echo "📏 Size: $SIZE"
  echo ""
  echo "Next:"
  echo "  1. Upload to Play Console → Internal Test track first."
  echo "  2. Enable App Signing by Google Play (recommended)."
  echo "  3. Promote to Closed → Production (staged 20% → 50% → 100%)."
else
  echo "❌ AAB not found at expected path"
  exit 1
fi
