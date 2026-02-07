#!/bin/bash
# ============================================================================
# 🚀 SANAD SETUP & BUILD SCRIPT
# ============================================================================
# Dieses Skript initialisiert das komplette Sanad-Projekt
# Ausführen: bash scripts/setup.sh
# ============================================================================

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🏥 SANAD SETUP SCRIPT                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# ============================================================================
# 1. FLUTTER SETUP
# ============================================================================
echo "📦 [1/5] Melos Bootstrap..."
cd /workspaces/Sanad

# Aktiviere Melos falls nötig
dart pub global activate melos

# Bootstrap alle Packages
melos bootstrap

echo "✅ Melos Bootstrap abgeschlossen!"
echo ""

# ============================================================================
# 2. CODE GENERATION (Freezed, JSON Serializable)
# ============================================================================
echo "🔧 [2/5] Code Generation (Freezed/JSON)..."

melos exec -- dart run build_runner build --delete-conflicting-outputs

echo "✅ Code Generation abgeschlossen!"
echo ""

# ============================================================================
# 3. FLUTTER ANALYZE
# ============================================================================
echo "🔍 [3/5] Flutter Analyze..."

melos exec -- flutter analyze --no-fatal-infos || true

echo "✅ Analyse abgeschlossen!"
echo ""

# ============================================================================
# 4. PYTHON BACKEND SETUP
# ============================================================================
echo "🐍 [4/5] Python Backend Setup..."

cd /workspaces/Sanad/backend

# Erstelle Virtual Environment falls nicht vorhanden
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Aktiviere venv und installiere Dependencies
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

echo "✅ Python Backend Setup abgeschlossen!"
echo ""

# ============================================================================
# 5. ENVIRONMENT KONFIGURATION
# ============================================================================
echo "⚙️ [5/5] Environment Setup..."

# Kopiere .env.example zu .env falls nicht vorhanden
if [ ! -f "/workspaces/Sanad/backend/.env" ]; then
    cp /workspaces/Sanad/backend/.env.example /workspaces/Sanad/backend/.env
    echo "  → .env erstellt aus .env.example"
    echo "  ⚠️  WICHTIG: Editiere backend/.env mit echten Werten!"
fi

echo "✅ Environment Setup abgeschlossen!"
echo ""

# ============================================================================
# ZUSAMMENFASSUNG
# ============================================================================
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ✅ SETUP ABGESCHLOSSEN                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Nächste Schritte:"
echo ""
echo "  1. Backend starten:"
echo "     cd /workspaces/Sanad/backend"
echo "     source venv/bin/activate"
echo "     uvicorn app.main:app --reload --port 8000"
echo ""
echo "  2. Admin App starten:"
echo "     cd /workspaces/Sanad/apps/admin_app"
echo "     flutter run -d chrome"
echo ""
echo "  3. MFA App starten:"
echo "     cd /workspaces/Sanad/apps/mfa_app"
echo "     flutter run -d chrome"
echo ""
echo "  4. Staff App starten:"
echo "     cd /workspaces/Sanad/apps/staff_app"
echo "     flutter run -d chrome"
echo ""
echo "  5. Patient App starten:"
echo "     cd /workspaces/Sanad/apps/patient_app"
echo "     flutter run -d chrome"
echo ""
echo "📚 API Docs: http://localhost:8000/docs"
echo ""
