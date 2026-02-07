#!/bin/bash

# Sanad Healthcare System - Build All Apps Script
# This script builds all 4 applications for production

set -e  # Exit on error

echo "🏥 Sanad Healthcare System - Building All Apps"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to build an app
build_app() {
    local app_name=$1
    local app_dir=$2
    
    echo "📦 Building $app_name..."
    cd "$app_dir"
    
    if [ ! -d "node_modules" ]; then
        echo "   Installing dependencies..."
        npm install --silent
    fi
    
    if npm run build --silent; then
        echo -e "${GREEN}✓${NC} $app_name built successfully"
    else
        echo -e "${RED}✗${NC} $app_name build failed"
        exit 1
    fi
    
    cd - > /dev/null
    echo ""
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build all apps
build_app "Reception App" "apps/reception"
build_app "Doctor Portal" "apps/doctor"
build_app "Patient Portal" "apps/patient"
build_app "Master Dashboard" "apps/dashboard"

echo "================================================"
echo -e "${GREEN}✅ All applications built successfully!${NC}"
echo ""
echo "Build artifacts are located in:"
echo "  - apps/reception/build"
echo "  - apps/doctor/build"
echo "  - apps/patient/build"
echo "  - apps/dashboard/build"
echo ""
echo "Ready for deployment to Netlify! 🚀"
echo "See DEPLOYMENT_CHECKLIST.md for deployment instructions."
