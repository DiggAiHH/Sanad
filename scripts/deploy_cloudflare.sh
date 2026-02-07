#!/bin/bash
# ==============================================================================
# SANAD - Cloudflare Pages CLI Deploy
# ==============================================================================
# Deployed alle 4 Flutter Web Apps via Wrangler CLI
# Voraussetzung: npm install -g wrangler && wrangler login
# ==============================================================================

set -e

echo "☁️  SANAD - Cloudflare Pages Deployment"
echo "=================================================="

# Check wrangler
if ! command -v wrangler &> /dev/null; then
    echo "📦 Installiere Wrangler CLI..."
    npm install -g wrangler
fi

# Get repo root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# API URL (update with your Render URL)
API_URL="${API_BASE_URL:-https://sanad-api.onrender.com/api/v1}"

echo "📡 API URL: $API_URL"
echo ""

# Function to deploy an app
deploy_app() {
    local APP_NAME=$1
    local APP_PATH=$2
    local PROJECT_NAME="sanad-$APP_NAME"
    
    echo "🚀 Deploying $APP_NAME..."
    
    BUILD_DIR="$REPO_ROOT/$APP_PATH/build/web"
    
    if [ ! -d "$BUILD_DIR" ]; then
        echo "❌ Build nicht gefunden: $BUILD_DIR"
        echo "   Führe zuerst scripts/build_web.sh aus!"
        return 1
    fi
    
    # Deploy to Cloudflare Pages
    wrangler pages deploy "$BUILD_DIR" --project-name="$PROJECT_NAME"
    
    echo "✅ $APP_NAME deployed: https://$PROJECT_NAME.pages.dev"
    echo ""
}

# Deploy all apps
deploy_app "admin" "apps/admin_app"
deploy_app "mfa" "apps/mfa_app"
deploy_app "staff" "apps/staff_app"
deploy_app "patient" "apps/patient_app"

echo "=================================================="
echo "✅ Alle Apps deployed!"
echo ""
echo "🔗 URLs:"
echo "   Admin:   https://sanad-admin.pages.dev"
echo "   MFA:     https://sanad-mfa.pages.dev"
echo "   Staff:   https://sanad-staff.pages.dev"
echo "   Patient: https://sanad-patient.pages.dev"
echo "=================================================="
