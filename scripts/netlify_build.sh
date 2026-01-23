#!/bin/bash
# ==============================================================================
# SANAD - Netlify Build Script
# ==============================================================================
# Builds a single Flutter app for Netlify deployment.
# Requires: APP_NAME env variable (admin|mfa|staff|patient)
# ==============================================================================

set -e

echo "🔨 Sanad Netlify Build"
echo "=================================================="

# Validate APP_NAME
if [ -z "$APP_NAME" ]; then
    echo "❌ ERROR: APP_NAME environment variable is required"
    echo "   Set APP_NAME to one of: admin, mfa, staff, patient"
    exit 1
fi

# Map APP_NAME to directory
case "$APP_NAME" in
    admin)
        APP_DIR="apps/admin_app"
        ;;
    mfa)
        APP_DIR="apps/mfa_app"
        ;;
    staff)
        APP_DIR="apps/staff_app"
        ;;
    patient)
        APP_DIR="apps/patient_app"
        ;;
    *)
        echo "❌ ERROR: Invalid APP_NAME '$APP_NAME'"
        echo "   Valid values: admin, mfa, staff, patient"
        exit 1
        ;;
esac

echo "📦 Building: $APP_NAME"
echo "📁 App directory: $APP_DIR"

# API URL with fallback
API_URL="${API_BASE_URL:-https://sanad-api.onrender.com/api/v1}"
echo "📡 API URL: $API_URL"

# Feature flags
DEMO_MODE="${ENABLE_DEMO_MODE:-false}"
ANALYTICS="${ENABLE_ANALYTICS:-false}"
PUSH="${ENABLE_PUSH_NOTIFICATIONS:-false}"
echo "🔧 Demo Mode: $DEMO_MODE"
echo ""

# Install Flutter if not available (Netlify doesn't have Flutter by default)
if ! command -v flutter &> /dev/null; then
    echo "📥 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/.flutter
    export PATH="$PATH:$HOME/.flutter/bin"
    flutter precache --web
    flutter --version
fi

# Ensure Flutter web is enabled
flutter config --enable-web

# Get dependencies for all packages first (melos-like behavior)
echo "📦 Getting package dependencies..."
for pkg in packages/core packages/ui packages/voice packages/iot; do
    if [ -d "$pkg" ]; then
        echo "  → $pkg"
        (cd "$pkg" && flutter pub get)
    fi
done

# Build the app
echo ""
echo "🏗️ Building $APP_NAME for web..."
cd "$APP_DIR"

flutter pub get

flutter build web \
    --release \
    --dart-define=API_BASE_URL="$API_URL" \
    --dart-define=ENABLE_DEMO_MODE="$DEMO_MODE" \
    --dart-define=ENABLE_ANALYTICS="$ANALYTICS" \
    --dart-define=ENABLE_PUSH_NOTIFICATIONS="$PUSH" \
    --base-href "/"

# Copy to expected output location
cd ../..
OUTPUT_DIR="build/web_deploy/$APP_NAME"
mkdir -p "$(dirname "$OUTPUT_DIR")"
rm -rf "$OUTPUT_DIR"
cp -r "$APP_DIR/build/web" "$OUTPUT_DIR"

echo ""
echo "=================================================="
echo "✅ Build complete!"
echo "📁 Output: $OUTPUT_DIR"
echo "🔢 Files: $(find "$OUTPUT_DIR" -type f | wc -l)"
echo "📊 Size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
echo "=================================================="
