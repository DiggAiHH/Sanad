# 🏥 Sanad - Praxismanagement-System

> **Sanad** (سند) bedeutet "Unterstützung" auf Arabisch – und genau das ist unsere Mission: Medizinische Praxen bei der effizienten Patientenversorgung unterstützen.

## 📋 Übersicht

Sanad ist ein modernes, modulares Praxismanagement-System für deutsche Arztpraxen. Es besteht aus:

- **4 Flutter Apps** für verschiedene Benutzergruppen
- **1 FastAPI Backend** für die API
- **2 Shared Packages** für gemeinsame Logik und UI

## 🏗️ Architektur

```
┌─────────────────────────────────────────────────────────────────┐
│                        SANAD MONOREPO                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌───────────┐ │
│  │ Admin App   │ │  MFA App    │ │ Staff App   │ │Patient App│ │
│  │ (Dashboard) │ │ (Check-in)  │ │ (Chat/Tasks)│ │ (Status)  │ │
│  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └─────┬─────┘ │
│         │               │               │               │       │
│         └───────────────┴───────────────┴───────────────┘       │
│                              │                                   │
│  ┌───────────────────────────┴───────────────────────────┐      │
│  │                  Shared Packages                       │      │
│  │  ┌─────────────────────┐  ┌─────────────────────────┐ │      │
│  │  │     sanad_core      │  │       sanad_ui          │ │      │
│  │  │ (Models, Services,  │  │  (Theme, Widgets)       │ │      │
│  │  │  Providers, Utils)  │  │                         │ │      │
│  │  └─────────────────────┘  └─────────────────────────┘ │      │
│  └───────────────────────────────────────────────────────┘      │
│                              │                                   │
│  ┌───────────────────────────┴───────────────────────────┐      │
│  │                   FastAPI Backend                      │      │
│  │  (Auth, Queue, Tickets, Chat, Practice)               │      │
│  └───────────────────────────────────────────────────────┘      │
│                              │                                   │
│  ┌───────────────────────────┴───────────────────────────┐      │
│  │           PostgreSQL + Redis                           │      │
│  └───────────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Schnellstart

### Voraussetzungen

- Flutter 3.16+
- Dart 3.2+
- Python 3.11+
- Docker & Docker Compose

### Setup

```bash
# 1. Repository klonen
git clone https://github.com/your-org/sanad.git
cd sanad

# 2. Setup-Script ausführen
chmod +x scripts/setup.sh
./scripts/setup.sh
```

### Backend starten

```bash
# Mit Docker Compose
docker-compose up -d

# Oder manuell
cd backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

### Apps starten

```bash
# Admin Dashboard
cd apps/admin_app && flutter run -d chrome

# MFA App
cd apps/mfa_app && flutter run -d chrome

# Staff App
cd apps/staff_app && flutter run -d chrome

# Patient App
cd apps/patient_app && flutter run -d chrome
```

## 📁 Projektstruktur

```
Sanad/
├── apps/
│   ├── admin_app/      # Praxis-Admin Dashboard
│   ├── mfa_app/        # MFA Check-in App
│   ├── staff_app/      # Arzt/Team App
│   └── patient_app/    # Patienten App
├── packages/
│   ├── core/           # Business Logic
│   └── ui/             # Shared UI Components
├── backend/
│   ├── app/            # FastAPI Application
│   ├── alembic/        # DB Migrations
│   ├── requirements.txt
│   └── Dockerfile
├── docs/
│   └── laufbahn.md     # Agent Handoff Log
├── scripts/
│   └── setup.sh        # Automatisiertes Setup
├── docker-compose.yml
├── melos.yaml
└── README.md
```

## 📚 Dokumentation

- [Laufbahn (Agent Handoff Log)](docs/laufbahn.md)
- [API Docs](http://localhost:8000/docs) (Swagger UI)

## 🛠️ Tech Stack

| Komponente | Technologie |
|------------|-------------|
| **Frontend** | Flutter 3.16+, Dart 3.2+ |
| **State Management** | Riverpod 2.5.1 |
| **Navigation** | go_router 13.0.0 |
| **HTTP Client** | Dio |
| **Code Generation** | Freezed, JSON Serializable |
| **Monorepo** | Melos |
| **Backend** | FastAPI, SQLAlchemy (async) |
| **Datenbank** | PostgreSQL |
| **Auth** | JWT + bcrypt |
| **Container** | Docker, Docker Compose |

## 📝 Lizenz

Copyright © 2025. Alle Rechte vorbehalten.