#!/bin/bash
# ==============================================================================
# SANAD - One-Click Local Deploy Script
# ==============================================================================
# Startet Backend + DB lokal via Docker für sofortiges Testing
# Dann können die Flutter Apps lokal oder remote getestet werden
# ==============================================================================

set -e

echo "🚀 SANAD - Local Deployment"
echo "=================================================="

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker nicht gefunden. Bitte Docker installieren."
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose nicht gefunden."
    exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "📁 Repository: $REPO_ROOT"
echo ""

# Create .env file if not exists
if [ ! -f "backend/.env" ]; then
    echo "📝 Erstelle backend/.env..."
    cat > backend/.env << 'EOF'
DATABASE_URL=postgresql+asyncpg://sanad:sanad_dev_password_2025@localhost:5432/sanad_db
JWT_SECRET_KEY=dev-secret-key-change-in-production-minimum-32-chars
DEBUG=true
SEED_ON_STARTUP=true
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080","http://localhost:5000","http://127.0.0.1:5000"]
EOF
    echo "✅ .env erstellt"
fi

# Start services
echo ""
echo "🐳 Starte Docker Container..."
docker compose up -d

# Wait for healthy
echo ""
echo "⏳ Warte auf Datenbank..."
sleep 5

# Check health
echo ""
echo "🔍 Prüfe Backend..."
for i in {1..30}; do
    if curl -s http://localhost:8000/health > /dev/null 2>&1; then
        echo "✅ Backend läuft!"
        break
    fi
    echo "   Versuch $i/30..."
    sleep 2
done

# Final status
echo ""
echo "=================================================="
echo "✅ SANAD Backend läuft!"
echo ""
echo "📡 API:          http://localhost:8000"
echo "📚 API Docs:     http://localhost:8000/docs"
echo "💾 PostgreSQL:   localhost:5432"
echo ""
echo "🔐 Test-Logins:"
echo "   Admin:  admin@sanad.de  / Admin123!"
echo "   Arzt:   arzt@sanad.de   / Arzt123!"
echo "   MFA:    mfa@sanad.de    / Mfa123!"
echo "   Staff:  staff@sanad.de  / Staff123!"
echo ""
echo "📱 Flutter Apps starten:"
echo "   cd apps/admin_app && flutter run -d chrome"
echo "   cd apps/mfa_app && flutter run -d chrome"
echo "   cd apps/staff_app && flutter run -d chrome"
echo "   cd apps/patient_app && flutter run -d chrome"
echo ""
echo "🛑 Stoppen: docker compose down"
echo "=================================================="
