# =============================================================================
# SANAD - Makefile
# =============================================================================
# Vereinfacht häufige Entwicklungsaufgaben.
# Usage: make <target>
# =============================================================================

.PHONY: help setup backend flutter test clean deploy deploy-local deploy-web

# Default target
help:
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "  SANAD - Praxismanagement System"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "  Setup:"
	@echo "    make setup        - Vollständiges Projekt-Setup"
	@echo "    make deps         - Nur Dependencies installieren"
	@echo ""
	@echo "  Backend:"
	@echo "    make backend      - Backend starten (mit Docker)"
	@echo "    make backend-dev  - Backend lokal starten (ohne Docker)"
	@echo "    make db           - Nur Datenbank starten"
	@echo "    make migrate      - Datenbank-Migrationen ausführen"
	@echo "    make seed         - Testdaten einfügen"
	@echo ""
	@echo "  Flutter:"
	@echo "    make admin        - Admin App starten"
	@echo "    make mfa          - MFA App starten"
	@echo "    make staff        - Staff App starten"
	@echo "    make patient      - Patient App starten"
	@echo "    make build        - Freezed Code Generation"
	@echo ""
	@echo "  Deploy:"
	@echo "    make deploy-local - Lokales Deployment (Docker)"
	@echo "    make deploy-web   - Flutter Web Apps bauen"
	@echo "    make deploy-cf    - Zu Cloudflare Pages deployen"
	@echo ""
	@echo "  Test & Qualität:"
	@echo "    make test         - Alle Tests ausführen"
	@echo "    make lint         - Code analysieren"
	@echo ""
	@echo "  Cleanup:"
	@echo "    make clean        - Build-Artefakte löschen"
	@echo "    make reset        - Kompletter Reset (inkl. DB)"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# =============================================================================
# SETUP
# =============================================================================

setup: deps build migrate seed
	@echo "✅ Setup abgeschlossen!"

deps:
	@echo "📦 Installing Melos..."
	dart pub global activate melos
	@echo "📦 Bootstrap Packages..."
	melos bootstrap

# =============================================================================
# BACKEND
# =============================================================================

backend:
	@echo "🚀 Starting Backend with Docker..."
	docker-compose up -d db redis
	@sleep 3
	docker-compose up backend

backend-dev:
	@echo "🚀 Starting Backend locally..."
	cd backend && uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

db:
	@echo "🐘 Starting PostgreSQL..."
	docker-compose up -d db

migrate:
	@echo "📊 Running migrations..."
	cd backend && alembic upgrade head

seed:
	@echo "🌱 Seeding database..."
	cd backend && python -m app.seed_data

# =============================================================================
# FLUTTER APPS
# =============================================================================

admin:
	@echo "🖥️  Starting Admin App..."
	cd apps/admin_app && flutter run

mfa:
	@echo "📱 Starting MFA App..."
	cd apps/mfa_app && flutter run

staff:
	@echo "👨‍⚕️ Starting Staff App..."
	cd apps/staff_app && flutter run

patient:
	@echo "🏥 Starting Patient App..."
	cd apps/patient_app && flutter run

build:
	@echo "🔧 Running build_runner..."
	melos exec -- dart run build_runner build --delete-conflicting-outputs

watch:
	@echo "👀 Watching for changes..."
	melos exec -- dart run build_runner watch

# =============================================================================
# TEST & QUALITÄT
# =============================================================================

test:
	@echo "🧪 Running all tests..."
	melos run test
	cd backend && pytest

lint:
	@echo "🔍 Analyzing code..."
	melos run analyze
	cd backend && ruff check .

format:
	@echo "✨ Formatting code..."
	melos exec -- dart format .
	cd backend && black .

# =============================================================================
# CLEANUP
# =============================================================================

clean:
	@echo "🧹 Cleaning build artifacts..."
	melos clean
	melos exec -- flutter clean
	find . -name "*.freezed.dart" -delete
	find . -name "*.g.dart" -delete

reset: clean
	@echo "💥 Full reset..."
	docker-compose down -v
	rm -rf .dart_tool
	rm -rf build

# =============================================================================
# DEPLOYMENT
# =============================================================================

deploy-local:
	@echo "🐳 Starting local deployment..."
	chmod +x scripts/deploy_local.sh
	./scripts/deploy_local.sh

deploy-web:
	@echo "🌐 Building Flutter Web Apps..."
	chmod +x scripts/build_web.sh
	./scripts/build_web.sh

deploy-cf:
	@echo "☁️  Deploying to Cloudflare Pages..."
	chmod +x scripts/deploy_cloudflare.sh
	./scripts/deploy_cloudflare.sh

web-admin:
	@echo "🌐 Building Admin Web..."
	cd apps/admin_app && flutter build web --release

web-mfa:
	@echo "🌐 Building MFA Web..."
	cd apps/mfa_app && flutter build web --release

web-staff:
	@echo "🌐 Building Staff Web..."
	cd apps/staff_app && flutter build web --release

web-patient:
	@echo "🌐 Building Patient Web..."
	cd apps/patient_app && flutter build web --release
