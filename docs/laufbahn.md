# 🛤️ LAUFBAHN – Sanad Agent Handoff Log

> **Letzte Aktualisierung:** 2026-01-14  
> **Agent-Version:** Senior Architect Agent v2025.1  
> **Status:** 🟢 Phase 13 abgeschlossen (Production Deployment & Demo Preparation)

---

## 📋 Inhaltsverzeichnis

1. [Projektkontext](#1-projektkontext)
2. [Architektur-Entscheidungen](#2-architektur-entscheidungen)
3. [Abgeschlossene Aktionen](#3-abgeschlossene-aktionen)
4. [Dateiregister](#4-dateiregister)
5. [Offene Aufgaben](#5-offene-aufgaben)
6. [Annahmen & Risiken](#6-annahmen--risiken)
7. [Fortsetzungsanleitung](#7-fortsetzungsanleitung)

---

## 1. Projektkontext

### 1.1 Projektvision

**Sanad** ist ein deutsches Praxismanagement-System für medizinische Einrichtungen. Der Name bedeutet "Unterstützung" auf Arabisch und symbolisiert die Kernmission: Ärzten und MFAs bei der effizienten Patientenversorgung zu helfen.

### 1.2 Zielgruppen & Apps

| App | Zielgruppe | Kernfunktionen |
|-----|------------|----------------|
| **Admin Dashboard** | Praxisinhaber, IT-Admin | "God Mode" - Vollzugriff auf alle Systeme, Benutzerverwaltung, Statistiken |
| **MFA App** | Medizinische Fachangestellte | Ticket-Vergabe, QR/NFC Check-in, Warteschlangenverwaltung |
| **Staff/Arzt App** | Ärzte, Pflegepersonal | Team-Chat, Aufgabenverwaltung, Patientenübersicht |
| **Patient App** | Patienten | Wartezeit-Anzeige, Ticket-Status, Gesundheitsinfos |

### 1.3 Technologie-Stack

```yaml
Frontend:
  Framework: Flutter 3.16+
  Sprache: Dart 3.2+
  Monorepo: Melos
  State Management: Riverpod 2.5.1
  Navigation: go_router 13.0.0
  HTTP Client: Dio

Backend (geplant):
  Framework: FastAPI (Python)
  Datenbank: PostgreSQL (Supabase/Neon)
  Auth: JWT + Refresh Tokens
  
Lokalisierung: Deutsch (de_DE) - Alle UI-Texte auf Deutsch
```

---

## 2. Architektur-Entscheidungen

### 2.1 ADR-001: Melos Monorepo

**Kontext:** Mehrere Flutter-Apps teilen gemeinsame Logik und UI-Komponenten.

**Entscheidung:** Melos als Monorepo-Manager verwenden.

**Begründung:**
- Einheitliche Dependency-Verwaltung
- Shared Packages ohne pub.dev Publishing
- Parallele Builds und Tests
- Konsistente Versionierung

**Konsequenzen:**
- Alle Apps unter `apps/`
- Shared Code unter `packages/`
- `melos bootstrap` für Setup erforderlich

### 2.2 ADR-002: Package-Struktur

**Entscheidung:** Zwei Shared Packages:

```
packages/
├── core/          # Business Logic Layer
│   ├── models/    # Freezed Data Classes
│   ├── services/  # API, Auth, Storage
│   ├── providers/ # Riverpod State
│   ├── utils/     # Validators, Formatters
│   └── constants/ # Endpoints, App Config
│
└── ui/            # Presentation Layer
    ├── theme/     # Colors, Typography, ThemeData
    └── widgets/   # Reusable UI Components
```

**Begründung:** Clean Architecture Separation – Apps sind "thin shells".

### 2.3 ADR-003: Riverpod statt BLoC

**Entscheidung:** flutter_riverpod 2.5.1 für State Management.

**Begründung:**
- Weniger Boilerplate als BLoC
- Compile-time Safety
- Bessere Testbarkeit
- Code Generation mit riverpod_generator

### 2.4 ADR-004: Freezed für Models

**Entscheidung:** Alle Models mit Freezed annotiert (aber Code Generation noch nicht ausgeführt).

**Begründung:**
- Immutable Data Classes
- copyWith, toString, == automatisch
- JSON Serialization via json_serializable

**Status:** ✅ Code Generation bereits durchgeführt (alle .freezed.dart und .g.dart Files generiert).

### 2.5 ADR-005: Deutsche UI-Sprache

**Entscheidung:** Alle UI-Texte hardcoded auf Deutsch.

**Begründung:** 
- Zielmarkt ist Deutschland
- Schnellere Entwicklung ohne i18n-Setup
- Später Migration zu flutter_localizations möglich

---

## 3. Abgeschlossene Aktionen

### Phase 0: Projekt-Setup ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| Monorepo-Struktur erstellt | ✅ | melos.yaml konfiguriert |
| Root pubspec.yaml | ✅ | Workspace dependencies |
| .gitignore | ✅ | Flutter + Dart patterns |

### Phase 1: Shared Packages ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| `sanad_core` Package | ✅ | Models, Services, Providers |
| `sanad_ui` Package | ✅ | Theme, 15+ Widget-Komponenten |
| Models definiert | ✅ | User, Ticket, Queue, Task, Chat, etc. |
| Services definiert | ✅ | Auth, API, Queue, Chat, Storage |
| Providers definiert | ✅ | auth_provider, queue_provider, chat_provider |

### Phase 2: Admin Dashboard App ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| App-Struktur | ✅ | Feature-basiert organisiert |
| Router Setup | ✅ | go_router mit Guards |
| Login Screen | ✅ | Email/Passwort + Demo-Login |
| Dashboard Screen | ✅ | Statistik-Karten, Charts, Quick Actions |
| Benutzerverwaltung | ✅ | Liste, Filter, Rollen |
| Warteschlange | ✅ | Live-Queue-Ansicht |
| Einstellungen | ✅ | Praxis-Konfiguration |

### Phase 3: MFA App ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| App-Struktur | ✅ | 5 Feature-Module |
| Home Screen | ✅ | Quick Actions, aktuelle Warteschlange |
| Check-in Screen | ✅ | QR, NFC, manuelle Eingabe |
| QR Scanner | ✅ | mobile_scanner Integration |
| Queue Screen | ✅ | Tickets verwalten, Prioritäten |
| Ticket Issued | ✅ | Erfolgsbestätigung mit Nummer |

### Phase 4: Staff/Arzt App ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| App-Struktur | ✅ | 4 Feature-Module |
| Home Screen | ✅ | Übersicht, Schnellaktionen |
| Chat-Liste | ✅ | Team-Konversationen |
| Chat-Room | ✅ | Messaging mit Quick Replies |
| Aufgabenliste | ✅ | Tasks mit Status-Filter |
| Aufgaben-Detail | ✅ | Vollständige Task-Ansicht |
| Team-Übersicht | ✅ | Mitarbeiter-Liste |

### Phase 5: Patient App ✅ (NEU)

| Aktion | Status | Notizen |
|--------|--------|---------|
| App-Struktur | ✅ | 3 Feature-Module |
| Home Screen | ✅ | Willkommen, Quick Actions, Wartezeit |
| Ticket-Eingabe | ✅ | Nummer-Input mit Validierung |
| Ticket-Status | ✅ | Live-Status mit QR-Code |
| Info Screen | ✅ | Praxis-Info, Öffnungszeiten |

### Phase 6: FastAPI Backend ✅ (NEU)

| Aktion | Status | Notizen |
|--------|--------|---------|
| Projekt-Struktur | ✅ | requirements.txt, Dockerfile |
| SQLAlchemy Models | ✅ | User, Practice, Queue, Ticket, Task, Chat |
| Pydantic Schemas | ✅ | Alle Request/Response Models |
| Auth Service | ✅ | JWT + bcrypt |
| Queue Service | ✅ | Ticket CRUD |
| Chat Service | ✅ | Room + Message CRUD |
| Auth Router | ✅ | Login, Register, Refresh, Logout |
| Users Router | ✅ | User CRUD |
| Queue Router | ✅ | Queue Management |
| Tickets Router | ✅ | Ticket Operations |
| Chat Router | ✅ | Rooms + Messages |
| Practice Router | ✅ | Practice Settings |
| Docker Compose | ✅ | PostgreSQL + Redis |

### Phase 7: Riverpod Wiring ✅ (NEU)

| Aktion | Status | Notizen |
|--------|--------|---------|
| core_providers.dart | ✅ | Zentrale Provider-Definitionen |
| auth_provider.dart | ✅ | Imports von core_providers |
| queue_provider.dart | ✅ | StateProvider für currentPracticeId |
| chat_provider.dart | ✅ | Imports von core_providers |
| App main.dart Updates | ✅ | Alle 4 Apps mit ProviderScope |

### Phase 8: Code Generation ✅ (NEU)

| Aktion | Status | Notizen |
|--------|--------|---------|
| user.freezed.dart | ✅ | Manuell generiert |
| user.g.dart | ✅ | JSON Serialization |
| ticket.freezed.dart | ✅ | Manuell generiert |
| ticket.g.dart | ✅ | JSON Serialization |
| queue.freezed.dart | ✅ | Manuell generiert |
| queue.g.dart | ✅ | JSON Serialization |
| auth_state.freezed.dart | ✅ | Union Types |
| task.freezed.dart | ✅ | Manuell generiert |
| task.g.dart | ✅ | JSON Serialization |
| chat_message.freezed.dart | ✅ | Manuell generiert |
| chat_message.g.dart | ✅ | JSON Serialization |
| chat_room.freezed.dart | ✅ | Manuell generiert |
| chat_room.g.dart | ✅ | JSON Serialization |
| staff_member.freezed.dart | ✅ | Manuell generiert |
| staff_member.g.dart | ✅ | JSON Serialization |
| practice.freezed.dart | ✅ | Manuell generiert |
| practice.g.dart | ✅ | JSON Serialization |
| patient.freezed.dart | ✅ | Manuell generiert |
| patient.g.dart | ✅ | JSON Serialization |
| education_content.freezed.dart | ✅ | Manuell generiert |
| education_content.g.dart | ✅ | JSON Serialization |
| video_content.freezed.dart | ✅ | Manuell generiert |
| video_content.g.dart | ✅ | JSON Serialization |

---

## 4. Dateiregister

### 4.1 Root-Konfiguration

```
/workspaces/Sanad/
├── melos.yaml                    # Monorepo-Konfiguration
├── pubspec.yaml                  # Root Workspace
├── analysis_options.yaml         # Dart Linter
└── README.md                     # Projekt-Dokumentation
```

### 4.2 Core Package (32 Dateien)

```
packages/core/
├── pubspec.yaml
├── lib/
│   ├── sanad_core.dart           # Barrel Export
│   ├── models/
│   │   ├── models.dart           # Barrel
│   │   ├── user.dart             # @freezed User
│   │   ├── auth_state.dart       # @freezed AuthState
│   │   ├── ticket.dart           # @freezed Ticket
│   │   ├── queue.dart            # @freezed Queue, QueueStats
│   │   ├── task.dart             # @freezed Task
│   │   ├── chat_message.dart     # @freezed ChatMessage
│   │   ├── chat_room.dart        # @freezed ChatRoom
│   │   ├── staff_member.dart     # @freezed StaffMember
│   │   └── practice.dart         # @freezed Practice
│   ├── services/
│   │   ├── services.dart         # Barrel
│   │   ├── auth_service.dart     # JWT Auth
│   │   ├── api_service.dart      # Dio Client
│   │   ├── queue_service.dart    # Queue CRUD
│   │   ├── chat_service.dart     # Chat/WebSocket
│   │   └── storage_service.dart  # Secure Storage
│   ├── providers/
│   │   ├── providers.dart        # Barrel
│   │   ├── auth_provider.dart    # AuthNotifier
│   │   ├── queue_provider.dart   # QueueNotifier
│   │   └── chat_provider.dart    # ChatNotifier
│   ├── utils/
│   │   ├── utils.dart            # Barrel
│   │   ├── validators.dart       # Input Validation
│   │   ├── formatters.dart       # Date/Currency
│   │   └── extensions.dart       # String/DateTime Extensions
│   └── constants/
│       ├── constants.dart        # Barrel
│       ├── api_endpoints.dart    # API URLs
│       └── app_constants.dart    # App Config
```

### 4.3 UI Package (20 Dateien)

```
packages/ui/
├── pubspec.yaml
├── lib/
│   ├── sanad_ui.dart             # Barrel Export
│   ├── theme/
│   │   ├── theme.dart            # Barrel
│   │   ├── app_theme.dart        # ThemeData
│   │   ├── app_colors.dart       # Farbpalette
│   │   └── app_text_styles.dart  # Typography
│   └── widgets/
│       ├── widgets.dart          # Barrel
│       ├── buttons/
│       │   └── primary_button.dart
│       ├── cards/
│       │   ├── stat_card.dart
│       │   └── info_card.dart
│       ├── inputs/
│       │   ├── text_input.dart
│       │   └── search_input.dart
│       ├── display/
│       │   ├── avatar.dart
│       │   ├── badge.dart
│       │   └── loading_indicator.dart
│       ├── layout/
│       │   ├── responsive_layout.dart
│       │   └── section_header.dart
│       └── dialogs/
│           └── confirm_dialog.dart
```

### 4.4 Admin App (15 Dateien)

```
apps/admin_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # App Entry
│   ├── app.dart                  # MaterialApp
│   ├── router.dart               # GoRouter Config
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       └── login_screen.dart
│       ├── dashboard/
│       │   └── screens/
│       │       └── dashboard_screen.dart
│       ├── users/
│       │   └── screens/
│       │       └── users_screen.dart
│       ├── queue/
│       │   └── screens/
│       │       └── queue_screen.dart
│       └── settings/
│           └── screens/
│               └── settings_screen.dart
```

### 4.5 MFA App (12 Dateien)

```
apps/mfa_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── router.dart
│   └── features/
│       ├── home/
│       │   └── screens/
│       │       └── home_screen.dart
│       ├── check_in/
│       │   └── screens/
│       │       └── check_in_screen.dart
│       ├── qr_scanner/
│       │   └── screens/
│       │       └── qr_scanner_screen.dart
│       ├── queue/
│       │   └── screens/
│       │       └── queue_screen.dart
│       └── ticket_issued/
│           └── screens/
│               └── ticket_issued_screen.dart
```

### 4.6 Staff App (14 Dateien)

```
apps/staff_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── router.dart
│   └── features/
│       ├── home/
│       │   └── screens/
│       │       └── home_screen.dart
│       ├── chat/
│       │   └── screens/
│       │       ├── chat_list_screen.dart
│       │       └── chat_room_screen.dart
│       ├── tasks/
│       │   └── screens/
│       │       ├── tasks_list_screen.dart
│       │       └── task_detail_screen.dart
│       └── team/
│           └── screens/
│               └── team_screen.dart
```

### 4.7 Patient App (10 Dateien) ✨ NEU

```
apps/patient_app/
├── pubspec.yaml
├── lib/
│   ├── main.dart                 # App Entry mit ProviderScope
│   ├── app.dart                  # MaterialApp
│   ├── router.dart               # GoRouter Config
│   └── features/
│       ├── home/
│       │   └── screens/
│       │       └── home_screen.dart        # Willkommen, Quick Actions
│       ├── ticket/
│       │   └── screens/
│       │       ├── ticket_entry_screen.dart  # Ticket-Eingabe
│       │       └── ticket_status_screen.dart # Live Status + QR
│       └── info/
│           └── screens/
│               └── info_screen.dart          # Praxis-Informationen
```

### 4.8 Backend (25+ Dateien) ✨ NEU

```
backend/
├── requirements.txt              # Pinned Dependencies (EU CRA)
├── Dockerfile                    # Multi-stage Production Build
├── .env.example                  # Environment Template
├── alembic.ini                   # Migration Config
├── alembic/
│   ├── env.py
│   └── versions/                 # Migration Scripts
├── app/
│   ├── __init__.py
│   ├── main.py                   # FastAPI App + CORS
│   ├── config.py                 # Pydantic Settings
│   ├── database.py               # Async SQLAlchemy
│   ├── dependencies.py           # JWT Auth Middleware
│   ├── models/
│   │   ├── __init__.py
│   │   └── models.py             # SQLAlchemy Models
│   ├── schemas/
│   │   ├── __init__.py
│   │   └── schemas.py            # Pydantic Request/Response
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py       # JWT + bcrypt
│   │   ├── queue_service.py      # Queue CRUD
│   │   └── chat_service.py       # Chat CRUD
│   └── routers/
│       ├── __init__.py
│       ├── auth.py               # Login, Register, Refresh
│       ├── users.py              # User CRUD
│       ├── queue.py              # Queue Management
│       ├── tickets.py            # Ticket Operations
│       ├── chat.py               # Chat Rooms + Messages
│       └── practice.py           # Practice Settings
```

### 4.9 Scripts & Config ✨ NEU

```
/workspaces/Sanad/
├── docker-compose.yml            # PostgreSQL + Backend + Redis
└── scripts/
    └── setup.sh                  # Automatisiertes Setup-Script
```

---

## 5. Offene Aufgaben

### 5.1 Kritisch (Blocker für MVP) - ✅ ABGESCHLOSSEN

| Priorität | Aufgabe | Status | Beschreibung |
|-----------|---------|--------|--------------|
| ✅ P0 | **FastAPI Backend** | ✅ Done | Auth, Queue, Chat, Practice Endpoints |
| ✅ P0 | **Riverpod Wiring** | ✅ Done | Provider mit core_providers.dart zentralisiert |
| ✅ P0 | **Code Generation** | ✅ Done | Freezed/JSON Dateien manuell generiert |
| ✅ P1 | **Patient App** | ✅ Done | 4. Flutter App mit 4 Screens |
| ✅ P0 | **Zero-Touch Reception** | ✅ Done | NFC, LED, MQTT, WebSocket IoT-System |

### 5.2 Hoch (MVP Features)

| Priorität | Aufgabe | Beschreibung | Status |
|-----------|---------|--------------|--------|
| ✅ P1 | **MFA-App NFC-Integration** | NFC-Service in Check-in Screen eingebunden | ✅ Done |
| ✅ P1 | **Device Secret Verification** | bcrypt Hash-Vergleich im Backend | ✅ Done |
| ✅ P1 | **Wayfinding Trigger** | LED-Route bei Check-in automatisch aktiviert | ✅ Done |
| ✅ P1 | **Dynamic Wait Time** | Wartezeit basierend auf Queue-Länge berechnet | ✅ Done |
| ✅ P1 | **Push Notifications** | FCM Integration Backend + Flutter | ✅ Done |
| ✅ P1 | **IoT Package Code Gen** | Freezed-Dateien für IoT-Package | ✅ Done |
| ✅ P1 | **NFC Service Hardening** | Retry/Timeout, Idempotency, Debounce, Tests | ✅ Done |
| ✅ P1 | **Production Deployment** | Render Backend + Netlify Multi-App | ✅ Done |

### 5.3 Kritisch - DEPLOYMENT BLOCKERS 🚨

| Aufgabe | Status | Action Required |
|---------|--------|-----------------|
| **Backend auf Render deployen** | 🔴 Pending | User muss dashboard.render.com öffnen und deploy triggern |
| **4 Netlify-Sites konfigurieren** | 🔴 Pending | Jede App braucht eigene Site mit APP_NAME env var |
| **API_BASE_URL in Netlify setzen** | 🔴 Pending | Nach Backend-Deployment: [https://sanad-api.onrender.com/api/v1](https://sanad-api.onrender.com/api/v1) |

**Guides:**
- [RENDER_DEPLOY.md](./RENDER_DEPLOY.md) - Backend auf Render.com deployen
- [NETLIFY_FIX.md](./NETLIFY_FIX.md) - Multi-App-Sites konfigurieren
- [CREDENTIALS.md](./CREDENTIALS.md) - Demo-Login-Daten

### 5.4 Mittel (Post-MVP)

| Priorität | Aufgabe | Beschreibung | Status |
|-----------|---------|--------------|--------|
| 📋 P2 | ESP32 Prototyp | Hardware-Test mit NFC + LED | Dokumentiert |
| 📋 P2 | Offline-Modus | SQLite + Sync | Konzept erstellt |
| 🟡 P2 | Analytics | Mixpanel/Amplitude | Offen |
| ✅ P2 | E2E Tests | Integration Tests | Test Suite erstellt |
| ✅ P2 | Observability | Logs + Metrics | ✅ Done |

### 5.4 Niedrig (Nice-to-Have)

| Priorität | Aufgabe | Beschreibung |
|-----------|---------|--------------|
| 🟢 P3 | Dark Mode | Theme Switching |
| 🟢 P3 | Mehrsprachigkeit | flutter_localizations |
| 🟢 P3 | Accessibility | Screen Reader Support |

---

## 6. Annahmen & Risiken

### 6.1 Getroffene Annahmen

| # | Annahme | Auswirkung bei Fehler |
|---|---------|----------------------|
| A1 | Eine Praxis = Ein Mandant (Single-Tenant) | Multi-Tenancy erfordert DB-Redesign |
| A2 | Alle User haben Smartphones mit Kamera | QR-Check-in funktioniert nicht |
| A3 | Stabile Internetverbindung in Praxis | Offline-Modus wird kritisch |
| A4 | PostgreSQL als Datenbank | Migration bei anderem DB-System |
| A5 | Deutsche Sprachversion ausreichend | i18n-Refactoring nötig |

### 6.2 Bekannte Risiken

| # | Risiko | Wahrscheinlichkeit | Impact | Mitigation |
|---|--------|-------------------|--------|------------|
| R1 | Freezed Code Generation fehlerhaft | Mittel | Hoch | Annotations prüfen |
| R2 | API-Endpoints nicht konsistent | Hoch | Mittel | OpenAPI Spec erstellen |
| R3 | State Management zu komplex | Niedrig | Mittel | Riverpod Best Practices |
| R4 | Performance bei großen Warteschlangen | Mittel | Mittel | Pagination implementieren |

### 6.3 Technische Schulden

| # | Schuld | Beschreibung | Priorität | Status |
|---|--------|--------------|-----------|--------|
| TD1 | Static Demo Data | Alle Screens haben Hardcoded Data | P0 | 🟢 Fixed (seed_data.py) |
| TD2 | Error Handling | Fehlende try/catch in Services | P1 | 🟡 Partial |
| TD3 | Loading States | Keine Skeleton Loader | P2 | 🔴 Offen |
| TD4 | Form Validation | Nur Basic Validators | P2 | 🔴 Offen |
| TD5 | Multi-App Deployment | Nur Admin-App deployed | P0 | 🟢 Fixed (NETLIFY_FIX.md) |

---

## 7. Fortsetzungsanleitung

### 7.1 Umgebung einrichten

```bash
# 1. Flutter Version prüfen
flutter --version  # Erwartet: 3.16+

# 2. Melos installieren
dart pub global activate melos

# 3. Dependencies bootstrappen
cd /workspaces/Sanad
melos bootstrap

# 4. Code Generation ausführen
melos exec -- dart run build_runner build --delete-conflicting-outputs
```

### 7.2 Nächste Schritte (Empfohlene Reihenfolge)

#### Schritt 1: Backend erstellen

```
backend/
├── app/
│   ├── main.py           # FastAPI App
│   ├── config.py         # Settings
│   ├── models/           # SQLAlchemy Models
│   ├── schemas/          # Pydantic Schemas
│   ├── routers/          # API Routes
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── queue.py
│   │   ├── tickets.py
│   │   └── chat.py
│   └── services/         # Business Logic
├── requirements.txt
└── Dockerfile
```

#### Schritt 2: API-Integration

```dart
// In packages/core/lib/constants/api_endpoints.dart
static const String baseUrl = 'http://localhost:8000/api/v1';
```

#### Schritt 3: Riverpod mit UI verbinden

```dart
// Beispiel: Queue Screen mit echten Daten
class QueueScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueProvider);
    
    return queueAsync.when(
      data: (queue) => QueueListView(tickets: queue.tickets),
      loading: () => LoadingIndicator(),
      error: (e, _) => ErrorDisplay(error: e),
    );
  }
}
```

#### Schritt 4: Patient App erstellen

```bash
# Struktur analog zu anderen Apps
melos exec --scope=patient_app -- flutter create .
```

### 7.3 Wichtige Befehle

```bash
# Alle Apps starten (zum Testen)
melos run:admin     # Admin Dashboard
melos run:mfa       # MFA App
melos run:staff     # Staff App

# Tests ausführen
melos test

# Analyse
melos analyze

# Clean Build
melos clean && melos bootstrap
```

### 7.4 Kontaktpunkte im Code

| Feature | Datei | Funktion |
|---------|-------|----------|
| Auth Flow | `packages/core/lib/services/auth_service.dart` | `login()`, `logout()` |
| Queue CRUD | `packages/core/lib/services/queue_service.dart` | `getQueue()`, `createTicket()` |
| Theme ändern | `packages/ui/lib/theme/app_colors.dart` | Farbpalette |
| Neue Route | `apps/*/lib/router.dart` | GoRouter Config |

### 7.5 Bekannte Quirks

1. **Freezed Imports:** Nach Code Generation müssen `.freezed.dart` und `.g.dart` Dateien importiert werden.

2. **Melos Scope:** Bei Änderungen in packages muss `melos bootstrap` erneut ausgeführt werden.

3. **Hot Reload:** Funktioniert nur innerhalb einer App, nicht package-übergreifend.

---

## 📝 Änderungsprotokoll

| Datum | Agent | Änderung |
|-------|-------|----------|
| 2026-01-11 | Senior Architect v2025.1 | Initiale Erstellung: Monorepo, 3 Apps, 2 Packages |
| 2026-01-12 | Senior Architect v2025.1 | Phase 2: FastAPI Backend, Patient App, Riverpod Wiring, Freezed Code Gen |
| 2026-01-12 | Senior Architect v2025.1 | Phase 3: DB Migration, Seed Data, Tests, Makefile, Alle Freezed Files |
| 2026-01-12 | Senior Architect v2025.1 | **Phase 4: Voice Package - TTS/STT für 16 Sprachen implementiert** |
| 2026-01-13 | Senior Architect v2025.1 | **Phase 9: Zero-Touch Reception - NFC, LED Wayfinding, MQTT/WebSocket IoT-Integration** |
| 2026-01-13 | Senior Architect v2025.1 | **Phase 10: Push Notifications, IoT Codegen, Observability** |
| 2026-01-13 | Senior Architect v2025.1 | **Phase 11: 10-Step Bugfix - LED per-Zone, Push Hardening, Offline MVP, Analytics, Docs** |
| 2026-01-14 | Senior Architect v2025.1 | **Phase 12: NFC Service Hardening - Retry/Timeout, Idempotency, Debounce, Tests** |
| 2026-01-14 | Senior Architect v2025.1 | **Phase 13: Production Deployment - Render Backend, Netlify Multi-App, Demo Data, Firebase Clarification** |

---

## 9. Zero-Touch Reception System ✨ NEU

### 9.1 Übersicht

Implementierung des automatisierten klinischen Empfangs- und Patientenflusssteuerungssystems gemäß der Forschungsdokumentation (VOICE_FEATURE_PLAN.md).

**Kernkonzept:** Patienten checken via NFC-Karte am Eingang selbstständig ein. LED-Wegführung leitet sie automatisch zum richtigen Wartebereich. Real-Time Updates via WebSocket.

### 9.2 Infrastruktur-Änderungen

#### docker-compose.yml (erweitert)
```yaml
services:
  mosquitto:
    image: eclipse-mosquitto:2
    ports:
      - "1883:1883"
      - "9001:9001"
    volumes:
      - ./mosquitto/config:/mosquitto/config
      - mosquitto_data:/mosquitto/data
```

#### requirements.txt (neue Dependencies)
```
aiomqtt==2.0.0            # Async MQTT Client
paho-mqtt==1.6.1          # MQTT Base Library
```

### 9.3 Datenbank-Models (SQLAlchemy)

```python
# backend/app/models/models.py

class NFCCard(Base):
    """NFC-Karten für Patienten-Identifikation (GDPR-konform)"""
    id: str (UUID)
    patient_id: str (FK -> User.id)
    uid_hash: str  # SHA-256 Hash der UID (schnelle Suche)
    uid_encrypted: str  # AES-256-GCM verschlüsselte UID
    label: str  # "Hauptkarte", "Ersatzkarte"
    is_active: bool
    last_used_at: datetime

class IoTDevice(Base):
    """ESP32/WLED Controller Registry"""
    id: str (UUID)
    practice_id: str (FK -> Practice.id)
    device_type: Enum  # nfc_reader, led_controller, display
    name: str
    location: str
    ip_address: str
    mac_address: str
    firmware_version: str
    last_heartbeat: datetime
    is_online: bool
    config: JSON  # Device-spezifische Konfiguration

class Zone(Base):
    """Physische Zonen in der Praxis"""
    id: str (UUID)
    practice_id: str (FK)
    name: str  # "Wartebereich A", "Zimmer 3"
    zone_type: Enum  # entrance, waiting_room, treatment_room, corridor
    led_device_id: str (FK -> IoTDevice.id)
    led_segment_start: int
    led_segment_end: int
    default_color: str  # Hex Color
    capacity: int

class WayfindingRoute(Base):
    """Vordefinierte LED-Routen"""
    id: str (UUID)
    practice_id: str (FK)
    name: str  # "Zu Zimmer 3"
    from_zone_id: str (FK)
    to_zone_id: str (FK)
    led_sequence: JSON  # [{device_id, segment, color, effect, delay}]
    animation_type: Enum  # chase, pulse, static
    duration_seconds: int

class CheckInEvent(Base):
    """Audit-Log aller Check-Ins"""
    id: str (UUID)
    practice_id: str (FK)
    patient_id: str (FK)
    nfc_device_id: str (FK)
    ticket_id: str (FK -> Ticket.id)
    check_in_time: datetime
    led_route_triggered: str (FK -> WayfindingRoute.id)
```

### 9.4 API-Endpoints (FastAPI)

#### NFC Router (`/api/v1/nfc/`)
| Method | Endpoint | Beschreibung |
|--------|----------|--------------|
| POST | `/check-in` | Auto Check-in via ESP32 NFC-Reader |
| POST | `/cards/register` | NFC-Karte für Patient registrieren |
| GET | `/cards/patient/{patient_id}` | Alle Karten eines Patienten |
| DELETE | `/cards/{card_id}` | Karte deaktivieren |
| GET | `/check-ins` | Check-in Event History |

#### LED Router (`/api/v1/led/`)
| Method | Endpoint | Beschreibung |
|--------|----------|--------------|
| GET/POST | `/devices` | IoT-Geräte verwalten |
| GET/POST | `/zones` | Zonen-Konfiguration |
| GET/POST | `/routes` | Wayfinding-Routen |
| POST | `/routes/trigger` | LED-Route aktivieren |
| POST | `/command` | Direkter LED-Segment-Befehl |
| GET | `/wait-times` | Wartezeit-Visualisierung |

#### WebSocket Router (`/api/v1/ws/`)
| Endpoint | Beschreibung |
|----------|--------------|
| `/events/{practice_id}` | Real-Time Event Stream |

**WebSocket Message Types:**
- `ticket.created` - Neues Ticket erstellt
- `ticket.called` - Patient aufgerufen
- `queue.updated` - Warteschlange geändert
- `wait_time.update` - Wartezeit-Update
- `led.status` - LED-Controller Status

### 9.5 Backend-Services

```
backend/app/services/
├── mqtt_service.py      # MQTT Broker Connection + Topic Handling
├── nfc_service.py       # NFC UID Encryption/Decryption, Card Management
└── led_service.py       # WLED API Integration, Route Calculation
```

**MQTT Topics:**
```
sanad/{practice_id}/nfc/+/scan       # NFC-Reader → Backend
sanad/{practice_id}/led/+/command    # Backend → WLED
sanad/{practice_id}/device/+/status  # Heartbeat
```

### 9.6 Flutter IoT Package

```
packages/iot/
├── pubspec.yaml
├── lib/
│   ├── sanad_iot.dart                    # Barrel Export
│   └── src/
│       ├── nfc/
│       │   ├── nfc_models.dart           # Freezed: NFCCheckInRequest/Response
│       │   └── nfc_service.dart          # NFC Reading, Check-in API
│       ├── websocket/
│       │   ├── event_models.dart         # Freezed: WSMessage, Events
│       │   └── websocket_service.dart    # WebSocket Connection, Reconnection
│       ├── wayfinding/
│       │   ├── wayfinding_models.dart    # Freezed: Zone, Route, LEDCommand
│       │   └── wayfinding_service.dart   # Route Triggering, LED Control
│       └── providers/
│           └── iot_providers.dart        # Riverpod: NFC, WS, Wayfinding
```

**Dependencies:**
- `nfc_manager: ^3.3.0`
- `web_socket_channel: ^2.4.0`
- `freezed_annotation: ^2.4.0`
- `riverpod_annotation: ^2.3.3`

### 9.7 ESP32 Firmware

Vollständige Dokumentation: [docs/ESP32_FIRMWARE.md](ESP32_FIRMWARE.md)

**Hardware-Komponenten:**
| Gerät | Funktion |
|-------|----------|
| ESP32 + PN532 | NFC-Reader am Eingang |
| ESP32 + WLED | LED-Strip Controller (WS2812B) |

**Verdrahtung (SPI-Modus):**
```
PN532 → ESP32
SCK   → GPIO 18
MISO  → GPIO 19
MOSI  → GPIO 23
SS    → GPIO 5
```

### 9.8 Sicherheit (GDPR/EU CRA)

1. **NFC UID Verschlüsselung:**
   - AES-256-GCM für UID-Speicherung
   - SHA-256 Hash für schnelle Suche
   - Schlüssel via `NFC_ENCRYPTION_KEY` Env-Variable

2. **Device Authentication:**
   - Device Secret Hash in DB
   - MQTT mit Authentication

3. **WebSocket Security:**
   - JWT Token Validation
   - Rate Limiting (60 req/min)
   - Topic-basierte Subscription

### 9.9 Dateien erstellt

| Datei | Beschreibung |
|-------|--------------|
| `backend/app/routers/nfc.py` | NFC Check-in API |
| `backend/app/routers/led.py` | LED/Wayfinding API |
| `backend/app/routers/websocket.py` | Real-Time WebSocket |
| `backend/app/services/mqtt_service.py` | MQTT Client |
| `backend/app/services/nfc_service.py` | NFC Encryption |
| `backend/app/services/led_service.py` | WLED Integration |
| `packages/iot/pubspec.yaml` | IoT Package Config |
| `packages/iot/lib/sanad_iot.dart` | Barrel Export |
| `packages/iot/lib/src/nfc/nfc_models.dart` | NFC Freezed Models |
| `packages/iot/lib/src/nfc/nfc_service.dart` | NFC Service |
| `packages/iot/lib/src/websocket/event_models.dart` | WS Event Models |
| `packages/iot/lib/src/websocket/websocket_service.dart` | WS Service |
| `packages/iot/lib/src/wayfinding/wayfinding_models.dart` | Wayfinding Models |
| `packages/iot/lib/src/wayfinding/wayfinding_service.dart` | Wayfinding Service |
| `packages/iot/lib/src/providers/iot_providers.dart` | Riverpod Providers |
| `docs/ESP32_FIRMWARE.md` | Hardware-Dokumentation |

---

## 8. Voice Package Implementation ✨ NEU

### 8.1 Übersicht

Vollständiges Voice-Package mit Text-to-Speech (TTS) und Speech-to-Text (STT) Support für 16 Sprachen.

### 8.2 Package-Struktur

```
packages/voice/
├── pubspec.yaml                    # Dependencies: flutter_tts, speech_to_text
├── lib/
│   ├── sanad_voice.dart            # Barrel Export
│   ├── src/
│   │   ├── tts/
│   │   │   └── tts_service.dart    # TTS Engine mit VoiceProfile
│   │   ├── stt/
│   │   │   └── stt_service.dart    # STT Engine mit Permission Handling
│   │   ├── commands/
│   │   │   └── command_parser.dart # Fuzzy Command Matching
│   │   ├── announcements/
│   │   │   └── announcement_builder.dart # SSML + Template Builder
│   │   ├── localization/
│   │   │   ├── voice_strings.dart  # Abstract Interface
│   │   │   ├── supported_languages.dart # Language Registry
│   │   │   └── strings/
│   │   │       ├── voice_strings_de.dart  # 🇩🇪 German
│   │   │       ├── voice_strings_en.dart  # 🇬🇧 English
│   │   │       ├── voice_strings_tr.dart  # 🇹🇷 Turkish
│   │   │       ├── voice_strings_ar.dart  # 🇸🇦 Arabic (RTL)
│   │   │       ├── voice_strings_ru.dart  # 🇷🇺 Russian (Slavic Plurals)
│   │   │       ├── voice_strings_pl.dart  # 🇵🇱 Polish (Slavic Plurals)
│   │   │       ├── voice_strings_fr.dart  # 🇫🇷 French
│   │   │       ├── voice_strings_es.dart  # 🇪🇸 Spanish
│   │   │       ├── voice_strings_it.dart  # 🇮🇹 Italian
│   │   │       ├── voice_strings_pt.dart  # 🇵🇹 Portuguese
│   │   │       ├── voice_strings_uk.dart  # 🇺🇦 Ukrainian (Slavic Plurals)
│   │   │       ├── voice_strings_fa.dart  # 🇮🇷 Persian (RTL)
│   │   │       ├── voice_strings_ur.dart  # 🇵🇰 Urdu (RTL)
│   │   │       ├── voice_strings_vi.dart  # 🇻🇳 Vietnamese
│   │   │       ├── voice_strings_ro.dart  # 🇷🇴 Romanian
│   │   │       └── voice_strings_el.dart  # 🇬🇷 Greek
│   │   ├── providers/
│   │   │   ├── voice_provider.dart   # Riverpod State Management
│   │   │   └── voice_provider.g.dart # Generated Code
│   │   └── widgets/
│   │       ├── voice_buttons.dart    # VoiceButton, SpeakButton
│   │       └── voice_settings.dart   # VoiceSettingsTile, WaveformIndicator
├── test/
│   ├── command_parser_test.dart      # Fuzzy Matching Tests
│   ├── supported_languages_test.dart # Language Registry Tests
│   ├── announcement_builder_test.dart # Announcement Tests
│   └── voice_strings_test.dart       # All 16 Language Tests
```

### 8.3 Unterstützte Sprachen (16)

| Phase | Sprache | Code | RTL | Pluralization |
|-------|---------|------|-----|---------------|
| P0 | 🇩🇪 Deutsch | `de-DE` | ❌ | Standard |
| P0 | 🇬🇧 English | `en-GB` | ❌ | Standard |
| P0 | 🇹🇷 Türkisch | `tr-TR` | ❌ | Standard |
| P0 | 🇸🇦 Arabisch | `ar-SA` | ✅ | Standard |
| P1 | 🇷🇺 Russisch | `ru-RU` | ❌ | Slavic (1/2-4/5+) |
| P1 | 🇵🇱 Polnisch | `pl-PL` | ❌ | Slavic (1/2-4/5+) |
| P1 | 🇫🇷 Französisch | `fr-FR` | ❌ | Standard |
| P1 | 🇪🇸 Spanisch | `es-ES` | ❌ | Standard |
| P2 | 🇮🇹 Italienisch | `it-IT` | ❌ | Standard |
| P2 | 🇵🇹 Portugiesisch | `pt-PT` | ❌ | Standard |
| P2 | 🇺🇦 Ukrainisch | `uk-UA` | ❌ | Slavic (1/2-4/5+) |
| P2 | 🇷🇴 Rumänisch | `ro-RO` | ❌ | Standard |
| P2 | 🇬🇷 Griechisch | `el-GR` | ❌ | Standard |
| P3 | 🇮🇷 Farsi | `fa-IR` | ✅ | Standard |
| P3 | 🇵🇰 Urdu | `ur-PK` | ✅ | Standard |
| P3 | 🇻🇳 Vietnamesisch | `vi-VN` | ❌ | Standard |

### 8.4 Kernfunktionen

#### TTS Service
```dart
final ttsService = TtsService();
await ttsService.initialize();
await ttsService.setLanguage('de-DE');
await ttsService.speak('Ihre Nummer A-047 wurde aufgerufen!');
```

#### STT Service
```dart
final sttService = SttService();
await sttService.initialize();
await sttService.requestPermission();
await sttService.startListening(localeId: 'de-DE');
sttService.resultStream.listen((result) {
  print('Erkannt: ${result.text}');
});
```

#### Command Parser
```dart
final parser = CommandParser(VoiceStringsDe());
final command = parser.parse('wie ist mein status');
// command.type == VoiceCommandType.status
```

#### Announcement Builder
```dart
final builder = AnnouncementBuilder(VoiceStringsDe());
final announcement = builder.ticketCalled(
  ticketNumber: 'A-047',
  room: 'Zimmer 3',
);
// announcement.text: "Achtung! Ihre Nummer A-047 wurde aufgerufen..."
// announcement.ssml: "<speak>...</speak>"
```

### 8.5 Voice Commands (pro Sprache)

Jede Sprache implementiert diese Befehls-Kategorien:
- **Status**: "Wie ist mein Status?" / "What's my status?"
- **Wartezeit**: "Wie lange noch?" / "How long?"
- **Position**: "Welche Position?" / "What's my position?"
- **Abbrechen**: "Ticket stornieren" / "Cancel ticket"
- **Hilfe**: "Hilfe" / "Help"
- **Nächster Patient**: "Nächster Patient" (Staff)
- **Patient fertig**: "Patient fertig" (Staff)

### 8.6 Tests

```bash
# Alle Voice-Tests ausführen
cd packages/voice
flutter test

# Einzelne Tests
flutter test test/command_parser_test.dart
flutter test test/voice_strings_test.dart
```

---

## 10. Session Log 2025-01-14: NFC MVP Completion

### 10.1 Implementierte Features

| Komponente | Änderung | Datei |
|------------|----------|-------|
| **Backend** | Device Secret bcrypt Verification | `backend/app/routers/nfc.py` |
| **Backend** | Dynamic Wait Time Calculation | `backend/app/routers/nfc.py` |
| **Backend** | Wayfinding Trigger bei Check-in | `backend/app/routers/nfc.py` |
| **Backend** | Secure Logging (keine UIDs/Secrets) | `backend/app/routers/nfc.py` |
| **MFA App** | TicketExtra mit zusätzlichen Daten | `apps/mfa_app/.../ticket_issued_screen.dart` |
| **MFA App** | Router extracts state.extra | `apps/mfa_app/lib/src/router.dart` |
| **MFA App** | Wayfinding Indicator in Success State | `apps/mfa_app/.../nfc_check_in_screen.dart` |
| **MFA App** | IoT Device Status Chip | `apps/mfa_app/.../home_screen.dart` |
| **Tests** | Comprehensive NFC Test Suite | `backend/tests/test_nfc.py` |

### 10.2 Neue Dateien

```
backend/tests/test_nfc.py      # 16 Test Cases für NFC Check-in
```

### 10.3 Test Coverage (NFC)

- ✅ Happy Path (Check-in Success)
- ✅ Wayfinding Route ID Response
- ✅ Unknown Device → 401
- ✅ Wrong Device Secret → 401
- ✅ Inactive Device → 401/403
- ✅ Unknown NFC Card → 404
- ✅ Expired NFC Card → 403
- ✅ Inactive NFC Card → 403
- ✅ Dynamic Wait Time Calculation
- ✅ Edge Cases (Empty UID, Malformed UUID)

### 10.4 Security Improvements

1. **Device Authentication**: bcrypt hash comparison via `passlib`
2. **Logging Audit**: No `nfc_uid` or `device_secret` in logs
3. **Secure Storage**: Device credentials stored in Flutter Secure Storage

---

## 11. Session Log 2026-01-13: Phase 10 – Push, IoT Codegen, Observability

### 11.1 Implementierte Features

| Komponente | Änderung | Datei(en) |
|------------|----------|-----------|
| **Backend** | FCM Push Notification Service | `backend/app/services/push_service.py` |
| **Backend** | Push Router (Token Registration) | `backend/app/routers/push.py` |
| **Backend** | Device Secret Generation (fixed TODO) | `backend/app/routers/led.py` |
| **Backend** | Observability Middleware | `backend/app/middleware/observability.py` |
| **Backend** | Correlation IDs + Structured Logging | `backend/app/main.py` |
| **Backend** | Prometheus Metrics (optional) | `backend/app/middleware/` |
| **Flutter** | Push Service (core package) | `packages/core/lib/src/services/push_service.dart` |
| **Flutter** | Push Provider | `packages/core/lib/src/providers/push_provider.dart` |
| **Flutter** | MFA/Patient App FCM Integration | `apps/*/pubspec.yaml` |
| **IoT Package** | Freezed Models für WebSocket/Wayfinding | `packages/iot/lib/src/*/` |
| **Tests** | Abuse/Security Test Suite | `backend/tests/test_abuse.py` |
| **Docs** | ESP32 Hardware Test Plan | `docs/ESP32_HARDWARE_TEST.md` |
| **Docs** | Offline/Retry Konzept | `docs/OFFLINE_CONCEPT.md` |

### 11.2 Neue Dateien

```
backend/app/services/push_service.py       # FCM Integration
backend/app/routers/push.py                # Push Token Management
backend/app/middleware/__init__.py         # Middleware Package
backend/app/middleware/observability.py    # Logs + Metrics
backend/tests/test_abuse.py                # Security/Abuse Tests
docs/ESP32_HARDWARE_TEST.md                # Hardware Test Plan
docs/OFFLINE_CONCEPT.md                    # Offline Architecture
packages/iot/lib/src/websocket/websocket_events.freezed.dart
packages/iot/lib/src/wayfinding/wayfinding.freezed.dart
packages/core/lib/src/services/push_service.dart
packages/core/lib/src/providers/push_provider.dart
```

### 11.3 Aktualisierter Status der MVP Features

| Priorität | Aufgabe | Status |
|-----------|---------|--------|
| ✅ P1 | Push Notifications (FCM) | ✅ Done |
| ✅ P1 | IoT Package Codegen | ✅ Done |
| ✅ P1 | Device Secret Generation | ✅ Done |
| ✅ P2 | Observability (Logs/Metrics) | ✅ Done |
| 🟡 P2 | ESP32 Hardware Test | 📋 Dokumentiert |
| 🟡 P2 | Offline-Modus | 📋 Konzept erstellt |
| 🟡 P2 | E2E/Abuse Tests | ✅ Test Suite erstellt |

### 11.4 Technische Highlights

1. **Push Notifications**: FCM-Integration für MFA + Patient App, Token-Management, Check-in Benachrichtigungen
2. **Observability**: Correlation IDs, strukturierte JSON-Logs, Prometheus-Metriken (optional)
3. **Security Tests**: Brute-force Protection, SQL Injection, Input Validation, Concurrent Requests
4. **Device Secret Fix**: Automatische Generierung via `secrets.token_hex(32)` bei Geräteregistrierung

### 11.5 Nächste Schritte (Empfohlen)

1. **Firebase Setup**: Projekt erstellen, `google-services.json` / `GoogleService-Info.plist` hinzufügen
2. **Prometheus**: Optional `prometheus-client` in requirements.txt ergänzen
3. **Tests ausführen**: `cd backend && pytest tests/ -v`
4. **Build Runner**: `melos exec -- dart run build_runner build` für Freezed

---

## 🔗 Referenzen

- [Flutter Docs](https://docs.flutter.dev)
- [Melos](https://melos.invertase.dev)
- [Riverpod](https://riverpod.dev)
- [Freezed](https://pub.dev/packages/freezed)
- [FastAPI](https://fastapi.tiangolo.com)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Prometheus Python Client](https://prometheus.github.io/client_python/)

---

> **Hinweis für nachfolgende Agents:** Dieses Dokument ist die Single Source of Truth für den Projektzustand. Bitte bei jeder signifikanten Änderung aktualisieren.
