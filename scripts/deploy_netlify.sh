#!/bin/bash
# ==============================================================================
# SANAD - Netlify CLI Deploy Script
# ==============================================================================
# Deploys pre-built web apps to Netlify using the CLI.
# Prerequisite: Run build_web.sh first, then this script.
# ==============================================================================

set -e

echo "🚀 Sanad Netlify Deployment"
echo "=================================================="

REPO_ROOT="/workspaces/Sanad"
BUILD_DIR="$REPO_ROOT/build/web_deploy"

# Check if builds exist
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ ERROR: Build directory not found: $BUILD_DIR"
    echo "   Run 'bash scripts/build_web.sh' first."
    exit 1
fi

# Check netlify CLI
if ! command -v netlify &> /dev/null; then
    echo "📥 Installing Netlify CLI..."
    npm install -g netlify-cli
fi

# Check login status
echo "🔐 Checking Netlify authentication..."
netlify status || netlify login

echo ""
echo "📋 Available apps to deploy:"
echo "   1. admin  → sanad-admin.netlify.app"
echo "   2. mfa    → sanad-mfa.netlify.app"
echo "   3. staff  → sanad-staff.netlify.app"
echo "   4. patient → sanad-patient.netlify.app"
echo "   5. ALL    → Deploy all apps"
echo ""

# Function to deploy a single app
deploy_app() {
    local APP_NAME=$1
    local SITE_NAME="sanad-$APP_NAME"
    local APP_DIR="$BUILD_DIR/$APP_NAME"
    
    if [ ! -d "$APP_DIR" ]; then
        echo "⚠️  Skipping $APP_NAME - build not found at $APP_DIR"
        return 1
    fi
    
    echo ""
    echo "🚀 Deploying $APP_NAME to $SITE_NAME.netlify.app..."
    
    # Check if site exists, if not create it
    if ! netlify sites:list | grep -q "$SITE_NAME"; then
        echo "📝 Creating new site: $SITE_NAME"
        netlify sites:create --name "$SITE_NAME" --account-slug "$NETLIFY_ACCOUNT"
    fi
    
    # Deploy
    netlify deploy \
        --dir="$APP_DIR" \
        --site="$SITE_NAME" \
        --prod \
        --message "Deploy $APP_NAME from $(git rev-parse --short HEAD 2>/dev/null || echo 'local')"
    
    echo "✅ $APP_NAME deployed!"
}

# Parse arguments or interactive mode
if [ -n "$1" ]; then
    case "$1" in
        all|ALL)
            deploy_app "admin"
            deploy_app "mfa"
            deploy_app "staff"
            deploy_app "patient"
            ;;
        admin|mfa|staff|patient)
            deploy_app "$1"
            ;;
        *)
            echo "❌ Unknown app: $1"
            echo "   Valid options: admin, mfa, staff, patient, all"
            exit 1
            ;;
    esac
else
    # Interactive mode
    read -p "Enter app to deploy (admin/mfa/staff/patient/all): " APP_CHOICE
    
    case "$APP_CHOICE" in
        all|ALL)
            deploy_app "admin"
            deploy_app "mfa"
            deploy_app "staff"
            deploy_app "patient"
            ;;
        admin|mfa|staff|patient)
            deploy_app "$APP_CHOICE"
            ;;
        *)
            echo "❌ Invalid choice: $APP_CHOICE"
            exit 1
            ;;
    esac
fi

echo ""
echo "=================================================="
echo "✅ Deployment complete!"
echo ""
echo "🔗 Site URLs:"
echo "   Admin:   https://sanad-admin.netlify.app"
echo "   MFA:     https://sanad-mfa.netlify.app"
echo "   Staff:   https://sanad-staff.netlify.app"
echo "   Patient: https://sanad-patient.netlify.app"
echo "=================================================="
