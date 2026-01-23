#!/bin/bash
# ==============================================================================
# SANAD - Flutter Web Build Script
# ==============================================================================
# Builds all 4 Flutter apps for web deployment
# Output: build/web_deploy/<app_name>/
# ==============================================================================

set -e

echo "🔨 Building Sanad Flutter Web Apps..."
echo "=================================================="

# Get the repository root
REPO_ROOT="/workspaces/Sanad"
OUTPUT_DIR="$REPO_ROOT/build/web_deploy"

# Create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# API URL for production (update after Render deployment)
API_URL="${API_BASE_URL:-https://sanad-api.onrender.com/api/v1}"

echo "📡 Using API URL: $API_URL"
echo ""

# Function to build an app
build_app() {
    local APP_NAME=$1
    local APP_PATH=$2
    
    echo "📦 Building $APP_NAME..."
    cd "$REPO_ROOT/$APP_PATH"
    
    # Clean and get dependencies
    flutter clean
    flutter pub get
    
    # Build for web with production API URL
    flutter build web \
        --release \
        --dart-define=API_BASE_URL="$API_URL" \
        --base-href "/"
    
    # Copy to output directory
    cp -r build/web "$OUTPUT_DIR/$APP_NAME"
    
    echo "✅ $APP_NAME built successfully!"
    echo ""
}

# Build all apps
build_app "admin" "apps/admin_app"
build_app "mfa" "apps/mfa_app"
build_app "staff" "apps/staff_app"
build_app "patient" "apps/patient_app"

echo "=================================================="
echo "✅ All apps built successfully!"
echo ""
echo "📁 Output locations:"
echo "   - Admin:   $OUTPUT_DIR/admin/"
echo "   - MFA:     $OUTPUT_DIR/mfa/"
echo "   - Staff:   $OUTPUT_DIR/staff/"
echo "   - Patient: $OUTPUT_DIR/patient/"
echo ""
echo "🚀 Next: Deploy each folder to Cloudflare Pages"
echo "=================================================="
