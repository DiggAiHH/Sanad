                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             # 🚀 Sanad - Schnellstart-Anleitung

Diese Anleitung hilft dir, das Sanad-Projekt in wenigen Minuten aufzusetzen.

## Voraussetzungen

- **Flutter 3.16+** - [Installation](https://docs.flutter.dev/get-started/install)
- **Dart 3.2+** - Wird mit Flutter installiert
- **Docker & Docker Compose** - [Installation](https://docs.docker.com/get-docker/)
- **Python 3.11+** - Für Backend-Entwicklung

## 1. Repository klonen

```bash
git clone https://github.com/your-org/sanad.git
cd sanad
```

## 2. Automatisches Setup

```bash
# Führe das Setup-Script aus (empfohlen)
bash scripts/setup.sh
```

**Oder manuell:**

```bash
# Melos installieren
dart pub global activate melos

# Dependencies installieren
melos bootstrap
```

## 3. Backend starten

```bash
# Docker-Container starten (PostgreSQL + Redis + FastAPI)
docker-compose up -d

# Logs anzeigen
docker-compose logs -f backend
```

Wenn du das Backend **ohne Docker** startest, müssen mindestens diese Variablen gesetzt sein:

```bash
export DATABASE_URL="postgresql+asyncpg://postgres:postgres@localhost:5432/sanad"
export JWT_SECRET_KEY="<setze-ein-starkes-secret>"
```

**API erreichbar unter:** http://localhost:8000

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 4. Datenbank-Migrationen

```bash
cd backend

# Migrationen ausführen
alembic upgrade head

# Testdaten einfügen
python -m app.seed_data
```

## 5. Flutter App starten

```bash
# Admin Dashboard
cd apps/admin_app && flutter run

# MFA App
cd apps/mfa_app && flutter run

# Staff App
cd apps/staff_app && flutter run

# Patient App
cd apps/patient_app && flutter run
```

## 6. Entwicklung

### Code Generation (Freezed)

Die generierten Dateien sind bereits im Repository. Falls du Änderungen an Models machst:

```bash
melos exec -- dart run build_runner build --delete-conflicting-outputs
```

### Tests ausführen

```bash
# Flutter Tests
melos run test

# Backend Tests
cd backend && pytest
```

### Code analysieren

```bash
melos run analyze
```

## Test-Accounts

Nach dem Seed-Script sind folgende Accounts verfügbar:

| Rolle | E-Mail | Passwort |
|-------|--------|----------|
| Admin | admin@sanad.de | Admin123! |
| Arzt | arzt@sanad.de | Arzt123! |
| MFA | mfa@sanad.de | Mfa123! |
| Mitarbeiter | mitarbeiter@sanad.de | Staff123! |
| Patient | patient@example.de | Patient123! |

## Häufige Probleme

### "melos: command not found"

```bash
# Füge das Pub-Cache-Verzeichnis zum PATH hinzu
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Docker-Container startet nicht

```bash
# Überprüfe, ob Docker läuft
docker info

# Container-Status
docker-compose ps

# Logs anzeigen
docker-compose logs db
```

### Flutter Packages nicht gefunden

```bash
# Bootstrap erneut ausführen
melos bootstrap
```

## Nächste Schritte

1. Lies die [Laufbahn-Dokumentation](docs/laufbahn.md) für den aktuellen Projektstand
2. Schau dir die [Architektur-Entscheidungen](docs/laufbahn.md#2-architektur-entscheidungen) an
3. Beginne mit der Entwicklung!

---

Bei Fragen: Öffne ein Issue auf GitHub.
