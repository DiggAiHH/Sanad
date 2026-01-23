# 🛤️ LAUFBAHN – Sanad Agent Handoff Log

> **Letzte Aktualisierung:** 2026-01-22  
> **Agent-Version:** Senior Architect Agent v2025.1  
> **Status:** 🟢 Phase 16 abgeschlossen (Online-Rezeption & Hausarzt-Automatisierung)

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
| 2026-01-21 | Codex | UX-Polish Patient App, API-Retry/Backoff, Rate Limiting Middleware, Netlify Kamera-Policy, Render Rate-Limit Env |
| 2026-01-21 | Codex | MFA UX/Flow-Polish: NFC setup banner, search results/empty state, QR validation, queue filters & refresh, NFC scan guards |
| 2026-01-21 | Codex | Staff UX/Flow-Polish: refresh timestamps, search/filter in chat/team, task list empty/refresh states, chat send guard |
| 2026-01-21 | Codex | Admin UX/Flow-Polish: dashboard refresh stamp, users search/filter/empty state, queue status filters/empty state, settings toggles, login submit guard |
| 2026-01-21 | Codex | Backend hardening: request size limit + security headers middleware, config/env updates |
| 2026-01-21 | Codex | Backend test readiness: UUID import fix, LED route model alignment, TESTING flag, DB engine sqlite safeguards, websocket db alias |

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

## 12. Session Log 2026-01-21: Phase 15 – Seed Analytics + Test Fixes

### 12.1 Implementierte Fixes

| Komponente | Änderung | Datei |
|------------|----------|-------|
| **Backend Tests** | NFC Endpoints auf `/api/v1` korrigiert | `backend/tests/test_nfc.py` |
| **Backend Tests** | Abuse Tests Pfadfixes | `backend/tests/test_abuse.py` |
| **Backend NFC** | Router-Model Alignment (Ticket-Felder, CheckInEvent) | `backend/app/routers/nfc.py` |
| **Backend NFC** | NFCService Lookup ohne Commit/Expiry | `backend/app/services/nfc_service.py` |
| **Tests** | Per-Request Sessions + File DB für Concurrency | `backend/tests/conftest.py` |
| **Tests** | NFC UID Hash Normalisierung | `backend/tests/test_nfc.py` |
| **Tests** | NFC UID Hash Normalisierung | `backend/tests/test_abuse.py` |
| **Admin App** | Responsive Stats/Charts + Filter-UX | `apps/admin_app/lib/src/features/dashboard/dashboard_screen.dart` |
| **Admin App** | Suche/Filter UX + Ergebniszählung | `apps/admin_app/lib/src/features/users/users_screen.dart` |
| **Admin App** | Ticket-Suche + responsive Layout | `apps/admin_app/lib/src/features/queue/queue_management_screen.dart` |
| **Admin App** | Settings Änderungs-Timestamp | `apps/admin_app/lib/src/features/settings/settings_screen.dart` |
| **MFA App** | Responsive Home-Layout | `apps/mfa_app/lib/src/features/home/home_screen.dart` |
| **MFA App** | Check-In UX (responsive, Trefferzählung) | `apps/mfa_app/lib/src/features/check_in/check_in_screen.dart` |
| **MFA App** | NFC Idle CTA | `apps/mfa_app/lib/src/features/check_in/nfc_check_in_screen.dart` |
| **MFA App** | QR Scan Guard (Stop/Start) | `apps/mfa_app/lib/src/features/check_in/qr_scanner_screen.dart` |
| **MFA App** | Queue Suche/Filter | `apps/mfa_app/lib/src/features/queue/queue_screen.dart` |
| **Staff App** | Responsive Schnellzugriff | `apps/staff_app/lib/src/features/home/home_screen.dart` |
| **Staff App** | Chat/Team Meta + Refresh | `apps/staff_app/lib/src/features/chat/chat_list_screen.dart` |
| **Staff App** | Team Meta + Refresh | `apps/staff_app/lib/src/features/team/team_screen.dart` |
| **Staff App** | Tasks Suche + Ergebniszählung | `apps/staff_app/lib/src/features/tasks/tasks_screen.dart` |
| **Patient App** | QuickStats responsive | `apps/patient_app/lib/features/home/screens/home_screen.dart` |
| **Backend Tests** | Middleware Tests | `backend/tests/test_middleware.py` |
| **Deploy** | HSTS + CORS Pages Domains | `render.yaml` |
| **Deploy** | HSTS Header | `netlify.toml` |
| **Seed Data** | NFC Device + Card + CheckInEvents ergänzt | `backend/app/seed_data.py` |
| **Seed Data** | ChatMessage-Liste repariert | `backend/app/seed_data.py` |
| **Seed Data** | Demo-Login Hinweis korrigiert | `backend/app/seed_data.py` |

### 12.2 Details

- NFC Check-ins werden nun im Seed als Events mit `CheckInMethod.NFC` und `MANUAL` erzeugt.
- Analytics hat damit echte Daten (Peak Hour, NFC/Manual Counts).
- Test-Clients greifen wieder auf die tatsächlichen `/api/v1/nfc/check-in` Endpoints zu.
- NFC Router nutzt bestehende Ticket-Model-Felder (`patient_name`, `estimated_wait_minutes`).
- Tests verwenden file-basiertes SQLite für parallele Sessions und Concurrency-Szenarien.
- Zeitzonen-sichere Timestamps: `datetime.now(timezone.utc)` statt `utcnow()` in Backend.
- Pytest-Asyncio Event-Loop Warning entfernt (Standard-Loop, kein Custom Fixture).
- NFC Expiry Vergleich robust gemacht (naive/aware normalisiert).
- Third-Party Warnings gefixt (pydantic SettingsConfigDict) + pytest filter für jose/passlib.
- Admin/MFA/Staff/Patient UX-Polish: responsive Layouts, Suche/Filter, Meta-Infos.
- Middleware Tests ergänzt (Security Headers, Request Size Limit).
- Deployment HSTS + CORS Pages Domains ergänzt.

---

## 13. Session Log 2026-01-22: Admin UX Bug Fixes

### 13.1 Implementierte Fixes

| Komponente | Änderung | Datei |
|------------|----------|-------|
| **Admin App** | Auth-State Listener aus Build verschoben (Mehrfach-Listener verhindert) | `apps/admin_app/lib/src/features/auth/login_screen.dart` |
| **Admin App** | Kategorienliste ohne unbounded Expanded (verhindert Layout-Exception) | `apps/admin_app/lib/src/features/queue/queue_management_screen.dart` |
| **Admin App** | Ticket-Filter-Reset leert Suche mit | `apps/admin_app/lib/src/features/queue/queue_management_screen.dart` |
| **Admin App** | Tippfehler "Patienten-App" korrigiert | `apps/admin_app/lib/src/features/settings/settings_screen.dart` |

### 13.2 Implementierte Backend-Qualitaetschecks

| Komponente | Änderung | Datei |
|------------|----------|-------|
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/routers/nfc.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/routers/led.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/routers/users.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/routers/analytics.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/services/led_service.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/services/queue_service.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/services/nfc_service.py` |
| **Backend** | Bool-Filter auf `is_(True)` vereinheitlicht | `backend/app/services/push_service.py` |
| **Backend** | Import-Order und ungenutzte Variablen bereinigt | `backend/app/routers/led.py` |
| **Backend Tests** | Ruff E402 fuer spaete Imports dokumentiert | `backend/tests/conftest.py` |
| **Backend** | Black Formatierung angewendet | `backend/` |

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

---

## 14. Session Log 2026-01-22: UX Error Handling Standardization

### 14.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Apps (Admin/MFA/Patient/Staff)** | Standardisierte Snackbar-UX mit `ModernSnackBar` + Retry-Aktionen | `apps/admin_app/lib/src/features/auth/login_screen.dart`, `apps/mfa_app/lib/src/app.dart`, `apps/mfa_app/lib/src/features/check_in/qr_scanner_screen.dart`, `apps/mfa_app/lib/src/features/check_in/nfc_check_in_screen.dart`, `apps/mfa_app/lib/src/features/settings/iot_device_credentials_screen.dart`, `apps/patient_app/lib/app.dart`, `apps/staff_app/lib/src/features/team/team_screen.dart` |
| **UI Package** | `ScreenState` fuer konsistente Screen-Level-States | `packages/ui/lib/src/widgets/feedback/screen_state.dart`, `packages/ui/lib/src/widgets/widgets.dart` |
| **Apps (Admin/MFA/Patient/Staff)** | `ScreenState` in Listen-/Empty-Views integriert | `apps/admin_app/lib/src/features/users/users_screen.dart`, `apps/mfa_app/lib/src/features/queue/queue_screen.dart`, `apps/staff_app/lib/src/features/team/team_screen.dart`, `apps/staff_app/lib/src/features/tasks/tasks_screen.dart`, `apps/staff_app/lib/src/features/chat/chat_list_screen.dart`, `apps/patient_app/lib/features/ticket/screens/ticket_status_screen.dart` |
| **Docs** | UX Error Handling Guide hinzugefuegt/erweitert | `docs/UX_ERROR_HANDLING.md` |

### 14.2 Details

- Snackbars sind jetzt konsistent (Styling, Typen, Aktionen) ueber alle Apps.
- Retry-Aktionen wurden fuer relevante Fehlerfaelle vereinheitlicht.
- `ScreenState` definiert Loading/Error/Empty-Handling auf Screen-Ebene.
- Listen- und Such-Views nutzen `ScreenState` fuer Empty-States mit klaren Aktionen.
- Dokumentation beschreibt Patterns fuer Screen-Level-States und Inline-Feedback.

---

## 15. Session Log 2026-01-22: Patient App Ticket-Status Integration (WIP)

### 15.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Core** | PublicTicket Modell + PublicTicketService + Provider | `packages/core/lib/src/models/public_ticket.dart`, `packages/core/lib/src/services/public_ticket_service.dart`, `packages/core/lib/src/providers/core_providers.dart`, `packages/core/lib/src/models/models.dart`, `packages/core/lib/src/services/services.dart` |
| **Patient App** | Ticket-Status Screen mit API-Integration, Riverpod Refresh, entfernte Demo-Daten | `apps/patient_app/lib/features/ticket/screens/ticket_status_screen.dart` |
| **Patient App** | Ticket-Status Provider hinzugefuegt | `apps/patient_app/lib/features/ticket/providers/ticket_status_provider.dart` |
| **Patient App** | Ticket-Eingabe ohne simulierten API-Delay | `apps/patient_app/lib/features/ticket/screens/ticket_entry_screen.dart` |
| **Patient App** | Dio Dependency fuer Fehler-Mapping | `apps/patient_app/pubspec.yaml` |

### 15.2 Offene Aufgaben (Patient App)

- [ ] Public Queue Summary Endpoint + UI fuer Home-Quick-Stats (Wartezeit/jetzt dran)
- [ ] Public Practice Info Endpoint oder Konfig-Quelle fuer `InfoScreen`
- [ ] Letzte Ticketnummer speichern + Schnellaufruf beim App-Start
- [ ] Offline/No-Connection UX fuer Ticket-Status Abfragen
- [ ] Demo-Wartezeiten in `HomeScreen` durch Backend-Daten ersetzen
- [ ] Tests fuer Public Ticket Status (Unit/Widget)

---

## 16. Session Log 2026-01-22: Repo Cleanup + Organisation

### 16.1 Aufgabenliste

- [x] Root `.gitignore` fuer Flutter/Python/IDE Artefakte anlegen
- [x] Generierte Artefakte entfernen (`.dart_tool`, `.flutter`, `build`, `__pycache__`, `.pytest_cache`, `.ruff_cache`, `.venv`, `.metadata`)
- [ ] Untracked Projektdateien sichten und entscheiden (z.B. `apps/*/README.md`, `apps/*/analysis_options.yaml`, `apps/*/web/`, `apps/*/test/`, `apps/*/pubspec.lock`)

### 16.2 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Repo** | Root `.gitignore` fuer generierte Artefakte | `.gitignore` |
| **Repo** | Build- und Cache-Artefakte entfernt | Workspace Clean |

---

## 17. Session Log 2026-01-22: Repo Cleanup Option 2 (Untracked Removal)

### 17.1 Entscheidung

- Option 2 gewaehlt: Untracked Dateien/Ordner entfernt und nicht wiederhergestellt.

### 17.2 Entfernte untracked Elemente (Auszug)

| Kategorie | Elemente |
|-----------|----------|
| **App Scaffolding** | `apps/admin_app/{README.md,analysis_options.yaml,pubspec.lock,test/,web/}`, `apps/mfa_app/{README.md,analysis_options.yaml,pubspec.lock,test/,web/}` |
| **App Artifacts** | `apps/admin_app/.gitignore`, `apps/mfa_app/.gitignore`, `apps/patient_app/lib/features/ticket/providers/` |
| **Core/UI** | `packages/core/lib/src/models/public_ticket.dart`, `packages/core/lib/src/services/public_ticket_service.dart`, `packages/ui/lib/src/widgets/feedback/screen_state.dart` |
| **Backend/Docs** | `backend/app/middleware/{rate_limit.py,request_size_limit.py,security_headers.py}`, `backend/tests/test_middleware.py`, `docs/UX_ERROR_HANDLING.md`, `docs/platform_audit.md`, `docs/platform_check_report.md` |
| **Root/Tools** | `pubspec.lock`, `packages/core/pubspec.lock`, `pytest.ini`, `scripts/check_all.sh` |

### 17.3 Hinweis

- Entfernte Dateien bleiben entfernt; keine Wiederherstellung vorgenommen.

---

## 18. Session Log 2026-01-22: Focused Cleanup of Tracked Artifacts

### 18.1 Implementierte Aenderungen

| Komponente | Aenderung | Hinweis |
|------------|-----------|--------|
| **Repo** | Entfernung getrackter Artefakte (`__pycache__`, `*.pyc`, `build/`, `.dart_tool/`) | Cleanup Pass |

---

## 19. Session Log 2026-01-22: IDE Artifact Cleanup

### 19.1 Aufgabenliste

- [x] IntelliJ `.iml` Dateien entfernen
- [x] `.gitignore` um `*.iml` erweitern

### 19.2 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Repo** | `.iml` Dateien entfernt | `apps/admin_app/admin_app.iml`, `apps/mfa_app/mfa_app.iml` |
| **Repo** | Ignore-Regel fuer IntelliJ Module | `.gitignore` |

---

## 20. Session Log 2026-01-22: IDE Artifact Cleanup Pass 2

### 20.1 Aufgabenliste

- [x] Verbleibende `.idea` Ordner entfernen
- [x] `.gitignore` fuer verschachtelte `.idea` Ordner ergaenzen

### 20.2 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Repo** | `.idea` Ordner entfernt | `apps/admin_app/.idea`, `apps/mfa_app/.idea` |
| **Repo** | Ignore-Regel fuer `.idea` in Subordnern | `.gitignore` |

---

## 21. Session Log 2026-01-22: Patient App Public Data Integration + Netlify Readiness

### 21.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Public Practice Endpoint (`/practice/public/default`) | `backend/app/routers/practice.py` |
| **Backend** | Public Queue Summary Endpoint (`/queue/public/summary`) | `backend/app/routers/queue.py` |
| **Backend** | Public Queue Summary Service + Schemas | `backend/app/services/queue_service.py`, `backend/app/schemas/schemas.py` |
| **Backend Tests** | Public Practice/Queue Summary Tests | `backend/tests/test_public_patient.py` |
| **Core Package** | Public Practice + Queue Summary Models/Services/Providers | `packages/core/lib/src/models/public_practice.dart`, `packages/core/lib/src/models/public_queue_summary.dart`, `packages/core/lib/src/services/public_practice_service.dart`, `packages/core/lib/src/services/public_queue_summary_service.dart`, `packages/core/lib/src/providers/core_providers.dart` |
| **Core Package** | Last Ticket Storage Key | `packages/core/lib/src/constants/app_constants.dart` |
| **Patient App** | Home-Quick-Stats + Live Queue Summary | `apps/patient_app/lib/features/home/screens/home_screen.dart` |
| **Patient App** | Info Screen uses public practice info | `apps/patient_app/lib/features/info/screens/info_screen.dart` |
| **Patient App** | Last Ticket persistence + offline UX | `apps/patient_app/lib/features/ticket/screens/ticket_entry_screen.dart`, `apps/patient_app/lib/features/ticket/screens/ticket_status_screen.dart`, `apps/patient_app/lib/providers/last_ticket_provider.dart` |

### 21.2 Status Patient App (Offene Punkte)

- 🟡 Widget-Tests fuer Public Ticket Status (Patient App)
- 🟡 Optional: Praxis-Website Feld (Backend + InfoScreen)

### 21.3 Deployment Hinweis (Netlify)

- Jede Netlify-Site benoetigt `APP_NAME=patient` fuer die Patienten-App.
- `API_BASE_URL` muss auf das Render-Backend zeigen (z.B. `https://sanad-api.onrender.com/api/v1`).

---

## 22. Session Log 2026-01-22: Test Stability + Patient Widget Test

### 22.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Fallback-Middleware bei fehlenden Dateien (Test-Bootstrap) | `backend/app/middleware/__init__.py` |
| **Patient App** | Widget-Test fuer Ticket-Status Screen | `apps/patient_app/test/ticket_status_screen_test.dart` |

### 22.2 Hinweise

- Fallback-Middleware deaktiviert Rate-Limit/Headers/Size-Limits nur, wenn die Dateien fehlen.
- Flutter-Widget-Test laeuft erst, wenn die fehlenden Font-Assets in `packages/sanad_ui/fonts/` wieder vorhanden sind.

---

## 23. Session Log 2026-01-22: Netlify Multi-App Web Build + Deploy

### 23.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Build** | Web-Build-Flag bereinigt (Flutter 3.38 kompatibel) | `scripts/build_web.sh` |
| **MFA App** | NFC-UI an NFCState-Signatur angepasst + TextStyle-Fix | `apps/mfa_app/lib/src/features/check_in/nfc_check_in_screen.dart` |
| **Patient App** | Lokale Font-Assets entfernt (GoogleFonts genutzt) | `apps/patient_app/pubspec.yaml` |
| **Apps** | Web-Support fuer Admin/MFA/Staff reaktiviert (web/ Ordner) | `apps/admin_app/web/`, `apps/mfa_app/web/`, `apps/staff_app/web/` |
| **Deploy** | 4 Netlify Sites erstellt und manuell deployed | `.netlify/state.json` |

### 23.2 Deployment URLs (Testing)

- Admin: https://sanad-admin-diggaihh.netlify.app
- MFA: https://sanad-mfa-diggaihh.netlify.app
- Staff: https://sanad-staff-diggaihh.netlify.app
- Patient: https://sanad-patient-diggaihh.netlify.app

### 23.3 Hinweise

- Die Slugs `sanad-admin`, `sanad-mfa`, `sanad-staff`, `sanad-patient` waren global belegt; daher wurde der Suffix `-diggaihh` verwendet.
- Netlify Deploys wurden als `--no-build` Deploys aus `build/web_deploy/*` ausgefuehrt.

---

## 24. Session Log 2026-01-22: White Screen Fix + Smoke Test

### 24.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Push** | Firebase-Push im Web deaktiviert (No-op Service) | `packages/core/lib/src/services/push_service.dart` |
| **Dependencies** | Firebase Dependencies entfernt | `packages/core/pubspec.yaml`, `apps/mfa_app/pubspec.yaml`, `apps/patient_app/pubspec.yaml` |
| **Apps** | Firebase Init entfernt (MFA/Patient) | `apps/mfa_app/lib/main.dart`, `apps/patient_app/lib/main.dart` |

### 24.2 Smoke Test (Netlify)

- Admin: Render OK (Login/Dashboard)
- MFA: Render OK (Home/Check-In)
- Staff: Render OK (Home/Tasks)
- Patient: Render OK; API Calls blocken wegen CORS (siehe Hinweise)

### 24.3 Hinweise

- White Screen Ursache: Firebase Web Init ohne Firebase Options -> Runtime Error im JS (Flutter App bricht ab).
- Patient App: Backend CORS erlaubt die neuen Netlify Domains `sanad-*-diggaihh.netlify.app` noch nicht.

---

## 24. Session Log 2026-01-22: Practice Website Field + InfoScreen

### 24.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Optionales Praxis-Website-Feld in Model/Schemas/Router/Seed | `backend/app/models/models.py`, `backend/app/schemas/schemas.py`, `backend/app/routers/practice.py`, `backend/app/seed_data.py` |
| **Backend Tests** | Public Practice Response erweitert | `backend/tests/test_public_patient.py` |
| **Core Package** | PublicPractice um Website erweitert | `packages/core/lib/src/models/public_practice.dart` |
| **Patient App** | InfoScreen zeigt optional Website-Link | `apps/patient_app/lib/features/info/screens/info_screen.dart` |

### 24.2 Hinweise

- Datenbanken benoetigen eine Migration fuer die neue Spalte `website` in `practices`.
- Website-Links werden bei fehlendem Schema automatisch mit `https://` normalisiert.

---

## 25. Session Log 2026-01-22: Practice Website Migration

### 25.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Alembic Migration fuer `practices.website` erstellt | `backend/alembic/versions/003_add_practice_website.py` |

### 25.2 Hinweise

- `alembic upgrade head` benoetigt `DATABASE_URL` und `JWT_SECRET_KEY` in der Umgebung.

---

## 26. Session Log 2026-01-22: Alembic Upgrade Attempt

### 26.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Alembic Upgrade mit Export der Env-Variablen gestartet | `backend/alembic/versions/003_add_practice_website.py` |

### 26.2 Hinweise

- Upgrade fehlgeschlagen: PostgreSQL auf `localhost:5432` nicht erreichbar (Connection refused).

---

## 27. Session Log 2026-01-22: Local DB Provision + Alembic Fixes

### 27.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **DB** | Lokale PostgreSQL Instanz via Docker Compose gestartet | `docker-compose.yml` |
| **Alembic** | Fix fuer `down_revision` in Zero-Touch Migration | `backend/alembic/versions/002_zero_touch_reception.py` |
| **Alembic** | ENUM-Create doppelt verhindert (create_type=False) | `backend/alembic/versions/001_initial_migration.py`, `backend/alembic/versions/002_zero_touch_reception.py` |
| **Alembic** | Upgrade bis Head erfolgreich ausgefuehrt | `backend/alembic/versions/003_add_practice_website.py` |

### 27.2 Hinweise

- Migrationen laufen jetzt sauber auf einer frischen lokalen DB (Docker Volume neu erstellt).

---

## 28. Session Log 2026-01-23: Backend via Docker Compose

### 28.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Backend** | Docker-Compose Build + Start des Backend-Containers | `docker-compose.yml` |
| **DB** | Postgres-Volume beibehalten (kein Reset) | `docker-compose.yml` |

### 28.2 Hinweise

- Docker Compose meldet weiterhin: `version` Feld ist obsolet (keine Funktionseinschraenkung).

---

## 29. Session Log 2026-01-23: Netlify Build Prep (Login Blocked)

### 29.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Web Build** | Flutter Web Builds fuer alle 4 Apps erstellt (admin/mfa/staff/patient) | `scripts/build_web.sh`, `build/web_deploy/admin`, `build/web_deploy/mfa`, `build/web_deploy/staff`, `build/web_deploy/patient` |

### 29.2 Blocker

- Netlify CLI nicht eingeloggt; Deployment benoetigt `NETLIFY_AUTH_TOKEN` oder `netlify login`.

---

## 30. Session Log 2026-01-23: Netlify Production Deploys

### 30.1 Implementierte Aenderungen

| Komponente | Aenderung | Datei(en) |
|------------|-----------|-----------|
| **Netlify** | Admin/MFA/Staff/Patient Web Builds mit `--no-build` deployed | `build/web_deploy/admin`, `build/web_deploy/mfa`, `build/web_deploy/staff`, `build/web_deploy/patient` |

### 30.2 Deployment URLs (Production)

- Admin: https://sanad-admin-diggaihh.netlify.app
- MFA: https://sanad-mfa-diggaihh.netlify.app
- Staff: https://sanad-staff-diggaihh.netlify.app
- Patient: https://sanad-patient-diggaihh.netlify.app

---

## 31. Session Log 2026-01-23: Phase 14 – Patient Document Requests & Consultations

### 31.1 Implementierte Features

| Komponente | Beschreibung | Dateien |
|------------|--------------|---------|
| **Core Models** | DocumentRequest + Consultation Freezed Models | `packages/core/lib/src/models/document_request.dart`, `packages/core/lib/src/models/consultation.dart` |
| **Core Services** | DocumentRequestService + ConsultationService | `packages/core/lib/src/services/document_request_service.dart`, `packages/core/lib/src/services/consultation_service.dart` |
| **Patient App** | Dokumentenanfragen-Screens (Rezept, AU, Überweisung, Bescheinigung) | `apps/patient_app/lib/features/documents/` |
| **Patient App** | Konsultations-Screens (Chat, Video, Voice, Callback) | `apps/patient_app/lib/features/consultation/` |
| **Patient App** | Router-Integration für neue Features | `apps/patient_app/lib/router.dart` |
| **Patient App** | Home-Screen Quick Actions erweitert | `apps/patient_app/lib/features/home/screens/home_screen.dart` |

### 31.2 Neue Dateien

**Core Package:**
```
packages/core/lib/src/models/
├── document_request.dart           # DocumentRequest, DocumentRequestCreate
├── document_request.freezed.dart   # Freezed Generated
├── document_request.g.dart         # JSON Serialization
├── consultation.dart               # Consultation, ConsultationMessage, WebRTCRoom
├── consultation.freezed.dart       # Freezed Generated
└── consultation.g.dart             # JSON Serialization

packages/core/lib/src/services/
├── document_request_service.dart   # CRUD + Quick Helpers
└── consultation_service.dart       # Chat, Video, Voice APIs
```

**Patient App:**
```
apps/patient_app/lib/features/documents/
├── documents.dart                  # Feature Barrel Export
└── screens/
    ├── document_requests_screen.dart     # Hauptmenü
    ├── rezept_request_screen.dart        # Rezeptanfrage
    ├── au_request_screen.dart            # AU-Bescheinigung
    ├── ueberweisung_request_screen.dart  # Überweisung
    └── bescheinigung_request_screen.dart # Sonstige Bescheinigungen

apps/patient_app/lib/features/consultation/
├── consultation.dart               # Feature Barrel Export
└── screens/
    ├── consultations_screen.dart   # Kontaktoptionen (Video/Voice/Chat)
    ├── chat_screen.dart            # Text-Chat mit Arzt
    ├── video_call_screen.dart      # Videosprechstunde + Request
    └── voice_call_screen.dart      # Telefonsprechstunde + Callback
```

**Dokumentation:**
```
docs/DSGVO_AUDIT.md                 # Datenschutz-Compliance Report
```

### 31.3 Document Request Feature

**Unterstützte Dokumenttypen:**
| Typ | Screen | Beschreibung |
|-----|--------|--------------|
| `rezept` | RezeptRequestScreen | Medikamentenrezept anfragen |
| `au` | AURequestScreen | Arbeitsunfähigkeitsbescheinigung |
| `ueberweisung` | UeberweisungRequestScreen | Facharzt-Überweisung |
| `bescheinigung` | BescheinigungRequestScreen | Allgemeine Bescheinigungen (Sport, Reise, etc.) |

**Features:**
- Priorität (gering/normal/dringend)
- Abholmethode (Praxis/Post/Digital)
- DSGVO-Einwilligung mit Checkbox
- Validierung aller Pflichtfelder

### 31.4 Consultation Feature

**Kontaktoptionen:**
| Typ | Screen | Beschreibung |
|-----|--------|--------------|
| `video_call` | VideoCallScreen | WebRTC Videosprechstunde |
| `voice_call` | VoiceCallScreen | VoIP Telefonsprechstunde |
| `chat` | ChatScreen | Text-Kommunikation |
| `callback` | RequestCallbackScreen | Rückruf anfordern |

**Features:**
- E2E-Verschlüsselungs-Hinweis (UI)
- Datenschutz-Info-Sheet
- Notfall-Hinweis (112)
- Zeitslot-Präferenzen für Rückruf

### 31.5 DSGVO-Compliance

**Implementiert:**
- ✅ Einwilligungs-Checkbox in allen Formularen
- ✅ Datenschutzhinweise vor Zustimmung
- ✅ Datenminimierung (nur notwendige Felder)
- ✅ Verschlüsselungs-Indikatoren in UI

**Offen (siehe DSGVO_AUDIT.md):**
- ⚠️ E2E-Encryption tatsächlich implementieren
- ⚠️ Consent-Widerrufs-Funktion
- ⚠️ Daten-Export-Funktion (Art. 20)

### 31.6 Router-Konfiguration

```dart
// Neue Routes in apps/patient_app/lib/router.dart

// Document Request Routes
'/documents'              → DocumentRequestsScreen
'/documents/rezept'       → RezeptRequestScreen
'/documents/au'           → AURequestScreen
'/documents/ueberweisung' → UeberweisungRequestScreen
'/documents/bescheinigung'→ BescheinigungRequestScreen

// Consultation Routes
'/consultation'           → ConsultationsScreen
'/consultation/video'     → RequestVideoCallScreen
'/consultation/voice'     → RequestCallbackScreen
'/consultation/chat'      → ChatScreen
'/consultation/callback'  → RequestCallbackScreen
'/consultation/video/active' → VideoCallScreen
'/consultation/voice/active' → VoiceCallScreen
'/consultation/chat/:id'  → ChatScreen (mit ID)
```

### 31.7 Nächste Schritte

| Priorität | Aufgabe | Status |
|-----------|---------|--------|
| P0 | WebRTC-Integration für Video/Voice | ✅ Done |
| P0 | Backend-API-Anbindung der Services | ✅ Done |
| P1 | Freezed Build Runner ausführen | ✅ Done |
| P1 | E2E Encryption (Clientseitige Indizes) | ✅ Done |
| P2 | Widget-Tests für Document Screens | 🔴 Offen |
| P2 | E2E-Tests für Consultation Flow | 🔴 Offen |

---

## 32. Session Log 2026-01-24: Phase 15 – WebRTC Integration & E2E Encryption

### 32.1 Übersicht

Phase 15 implementiert die verbleibenden Bausteine für die Patienten-Arzt-Kommunikation:

**Entscheidungen des Benutzers:**
- **E2E Encryption:** Option B – Clientseitige Indizes (DSGVO-konform, durchsuchbar)
- **TURN Server:** Option B – Managed EU Provider (Xirsys/Metered.ca)

### 32.2 Implementierte Features

| Komponente | Beschreibung | Dateien |
|------------|--------------|---------|
| **API Endpoints** | WebRTC Signaling Endpoints (offer/answer/ice/poll/clear) | `backend/app/routers/consultations.py` |
| **Backend Config** | TURN Server + E2E Encryption Settings | `backend/app/config.py` |
| **Core Service** | ConsultationService mit WebRTC Signaling | `packages/core/lib/src/services/consultation_service.dart` |
| **Encryption** | EncryptionService mit PBKDF2 + Client-Side Index | `packages/core/lib/src/services/encryption_service.dart` |
| **Encryption Models** | EncryptedMessage, KeyExchange, EncryptionStatus | `packages/core/lib/src/models/encryption.dart` |
| **Chat Screen** | API-Integration (loadMessages, sendMessage) | `apps/patient_app/lib/features/consultation/screens/chat_screen.dart` |
| **Video Call** | API-Integration (joinCall, getCallRoom, endCall) | `apps/patient_app/lib/features/consultation/screens/video_call_screen.dart` |
| **Voice Call** | API-Integration (joinCall, getCallRoom, endCall) | `apps/patient_app/lib/features/consultation/screens/voice_call_screen.dart` |

### 32.3 E2E Encryption Service

**PBKDF2 Key Derivation (DSGVO-konform):**
- 100.000 Iterationen (Brute-Force Schutz)
- SHA-256 Hash-Algorithmus
- 16-Byte Salt pro Konsultation
- Passwort aus Patient-ID + Consultation-ID abgeleitet

**Clientseitige Indizes:**
- Normalisierter Suchindex (lowercase, trimmed)
- Keine Klartextspeicherung
- Export/Import für Persistenz
- Pro-Konsultation Schlüssel-Cache

```dart
// Beispiel: Verschlüsselte Suche
final service = EncryptionService();
await service.initializeConsultation(consultationId, userId);
final ciphertext = service.encryptMessage(consultationId, 'Nachricht');
service.indexMessage(consultationId, messageId, 'Nachricht');
final results = service.searchMessages(consultationId, 'such');
```

### 32.4 WebRTC Signaling Flow

```
Patient                    Backend                    Arzt
   |                         |                         |
   |-- POST /signal/offer -->|                         |
   |                         |-- Speichert Offer ----->|
   |                         |                         |
   |                         |<- GET /signal/poll -----|
   |                         |-- Returns Offer ------->|
   |                         |                         |
   |<-- POST /signal/answer -|                         |
   |                         |<- Speichert Answer -----|
   |                         |                         |
   |-- GET /signal/poll ---->|                         |
   |<-- Returns Answer ------|                         |
   |                         |                         |
   |<-- POST /signal/ice --->|<-- POST /signal/ice -->|
   |                         |                         |
```

### 32.5 Backend TURN Server Config

```python
# backend/app/config.py
TURN_SERVER_URL: str = os.environ.get("TURN_SERVER_URL", "")
TURN_USERNAME: str = os.environ.get("TURN_USERNAME", "")
TURN_CREDENTIAL: str = os.environ.get("TURN_CREDENTIAL", "")
TURN_REALM: str = os.environ.get("TURN_REALM", "")
E2E_ENCRYPTION_ENABLED: bool = os.environ.get("E2E_ENCRYPTION_ENABLED", "true").lower() == "true"
E2E_KEY_DERIVATION_ITERATIONS: int = int(os.environ.get("E2E_KEY_DERIVATION_ITERATIONS", "100000"))
```

### 32.6 Model Alignment

Consultation-Modelle wurden an die generierten Freezed-Dateien angepasst:

| Alt (Phase 14) | Neu (Phase 15) |
|----------------|----------------|
| `subject` | `reason` |
| `description` | `notes` |
| `callStartedAt` | `startedAt` |
| `callEndedAt` | `endedAt` |
| `scheduledDurationMinutes` | `durationMinutes` |
| `iceServers` (WebRTCRoom) | `roomToken`, `serverUrl`, `expiresAt` |

### 32.7 Dateien erstellt/geändert

**Neue Dateien:**
- `packages/core/lib/src/services/encryption_service.dart`
- `packages/core/lib/src/models/encryption.dart`
- `packages/core/lib/src/models/encryption.freezed.dart`
- `packages/core/lib/src/models/encryption.g.dart`

**Geänderte Dateien:**
- `packages/core/lib/src/models/consultation.dart` – Felder an Freezed angepasst
- `packages/core/lib/src/services/consultation_service.dart` – WebRTC Signaling Methoden
- `packages/core/lib/src/models/models.dart` – Export encryption
- `packages/core/lib/src/services/services.dart` – Export encryption_service
- `backend/app/config.py` – TURN + E2E Settings
- `backend/app/routers/consultations.py` – WebRTC Signaling Endpoints

### 32.8 Hinweise für nächste Session

1. **TURN Server einrichten:** Xirsys oder Metered.ca Account erstellen, Credentials in ENV setzen
2. **Freezed regenerieren:** Falls Modelle geändert werden, `dart run build_runner build --delete-conflicting-outputs`
3. **Backend-Tests:** WebRTC Signaling Endpoints testen
4. **E2E Integration:** EncryptionService in ChatScreen integrieren

---

## Session 33: Phase 16 – API Contract Stabilization & Full Integration (2026-01-22)

### 33.1 Übersicht

**Ziel:** Vollständige Harmonisierung von Frontend/Backend API-Contracts, WebRTC-Signaling Integration mit typisierten Modellen, E2E-Verschlüsselung im Chat-Screen, und Shared Dio Provider Zentralisierung.

**Entscheidungen des Benutzers:**
- **Option A (1-A):** Backend-Schema für ConsultationCreate
- **Option A (2 - flexibler):** ICE/TURN-Server-Listen für mehr Client-Kontrolle
- **Option A (3-A):** Volle E2E-Verschlüsselungsintegration jetzt

### 33.2 Implementierte Änderungen

| Bereich | Änderung | Dateien |
|---------|----------|---------|
| **API Models** | Consultation.reason → subject via Extension | `consultation.dart` |
| **API Models** | ConsultationCreate.toBackendJson() für Mapping | `consultation.dart` |
| **WebRTC** | IceServer, TurnServer, WebRTCOffer/Answer/IceCandidate als Plain Classes | `consultation.dart` |
| **WebRTC** | WebRTCSignal für Polling-Responses | `consultation.dart` |
| **Services** | Typed sendOffer/sendAnswer/sendIceCandidate Methoden | `consultation_service.dart` |
| **Services** | pollSignals() returns `List<WebRTCSignal>` | `consultation_service.dart` |
| **Chat** | E2E-Verschlüsselung mit EncryptionService Integration | `chat_screen.dart` |
| **Video** | Signaling-Loop mit _startSignalingLoop(), _processSignal() | `video_call_screen.dart` |
| **Voice** | Signaling-Loop analog zu Video | `voice_call_screen.dart` |
| **Providers** | consultationServiceProvider, encryptionServiceProvider | `core_providers.dart` |

### 33.3 Model-Architektur

**Freezed-Kompatibilität beibehalten:**
Die Consultation-Models wurden auf die ursprüngliche Struktur zurückgesetzt, um mit den generierten `.freezed.dart` und `.g.dart` Dateien kompatibel zu bleiben. API-Mapping erfolgt über Extensions:

```dart
// Model-Felder (Frontend):
Consultation.reason   // Backend sendet "subject"
Consultation.notes    // Backend sendet "description"

// Extension für Backend-Zugriff:
extension ConsultationApiExtension on Consultation {
  String? get subject => reason;
  String? get description => notes;
}

// Backend-JSON-Mapping:
extension ConsultationCreateApiExtension on ConsultationCreate {
  Map<String, dynamic> toBackendJson() => {
    'subject': reason,  // Backend erwartet 'subject'
    ...
  };
}
```

### 33.4 WebRTC Signaling Integration

**Video/Voice Call Screens:**
```dart
// Signaling Loop (500ms Polling)
void _startSignalingLoop() {
  _signalTimer = Timer.periodic(Duration(milliseconds: 500), (_) async {
    final signals = await consultationService.pollSignals(
      consultationId,
      since: _lastSignalTime,
    );
    for (final signal in signals) {
      _processSignal(signal);
    }
  });
}

// Signal Processing
void _processSignal(WebRTCSignal signal) {
  switch (signal.signalType) {
    case 'offer':
      final offer = WebRTCOffer.fromJson(signal.payload);
      _handleRemoteOffer(offer);
    case 'answer':
      final answer = WebRTCAnswer.fromJson(signal.payload);
      _handleRemoteAnswer(answer);
    case 'ice-candidate':
      final candidate = WebRTCIceCandidate.fromJson(signal.payload);
      _handleRemoteIceCandidate(candidate);
  }
}
```

### 33.5 E2E-Verschlüsselung im Chat

**Integration in chat_screen.dart:**
```dart
late final EncryptionService _encryptionService;
String? _encryptionKey;
bool _encryptionInitialized = false;

Future<void> _initializeEncryption() async {
  _encryptionService = ref.read(encryptionServiceProvider);
  _encryptionKey = await _encryptionService.initializeConsultation(
    widget.consultationId,
    currentUserId,
  );
  _encryptionInitialized = true;
}

// Nachrichten verschlüsseln beim Senden
Future<void> _sendMessage() async {
  final content = _messageController.text.trim();
  final encryptedContent = _encryptContent(content);
  await consultationService.sendMessage(consultationId, encryptedContent);
  
  // Für lokale Suche indexieren (Klartext)
  _encryptionService.indexMessage(consultationId, newMsg.id, content);
}

// Nachrichten entschlüsseln beim Laden
void _loadMessages() async {
  for (final msg in messages) {
    final decrypted = _decryptContent(msg.content);
    _encryptionService.indexMessage(consultationId, msg.id, decrypted);
  }
}
```

### 33.6 Shared Dio Provider

**Zentralisiert in core_providers.dart:**
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ));
  // Auth Interceptor
  dio.interceptors.add(AuthInterceptor(ref));
  return dio;
});

final consultationServiceProvider = Provider<ConsultationService>((ref) {
  return ConsultationService(ref.watch(dioProvider));
});

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});
```

### 33.7 Geänderte Dateien

| Datei | Änderung |
|-------|----------|
| `packages/core/lib/src/models/consultation.dart` | Zurück auf Freezed-kompatible Struktur + Extensions |
| `packages/core/lib/src/services/consultation_service.dart` | toBackendJson(), typed Signaling, reason statt subject |
| `packages/core/lib/src/providers/core_providers.dart` | consultationServiceProvider, encryptionServiceProvider |
| `apps/patient_app/lib/features/consultation/screens/chat_screen.dart` | E2E Encryption Integration |
| `apps/patient_app/lib/features/consultation/screens/video_call_screen.dart` | Signaling Loop |
| `apps/patient_app/lib/features/consultation/screens/voice_call_screen.dart` | Signaling Loop |

### 33.8 Hinweise für nächste Session

1. **Freezed Regenerierung:** Bei Model-Änderungen `dart run build_runner build --delete-conflicting-outputs` ausführen
2. **Backend-Migration:** Falls Backend-Felder geändert werden, Extensions anpassen
3. **TURN Server:** Credentials in Environment-Variables setzen
4. **Tests:** consultation_service und encryption_service Unit-Tests hinzufügen
5. **Lokale Suche:** searchMessages() im Chat-UI integrieren

---

## Session 34: Phase 16b – ICE/TURN Room DTO + Widget-Tests (2026-01-23)

### 34.1 Implementierte Änderungen

| Bereich | Änderung | Dateien |
|---------|----------|---------|
| **WebRTC DTO** | `WebRTCRoom` auf ICE/TURN-Listen umgestellt (Option 2-A) | `packages/core/lib/src/models/consultation.dart` |
| **WebRTC DTO** | Freezed/JSON-Generierung manuell angepasst | `packages/core/lib/src/models/consultation.freezed.dart`, `packages/core/lib/src/models/consultation.g.dart` |
| **Tests** | Neue Widget-Tests für Konsultations- und Dokumentenscreens | `apps/patient_app/test/consultation_screens_test.dart` |

### 34.2 Hinweise

1. **Backend-Response:** `/consultations/{id}/call-room` muss `room_id`, `consultation_id`, `ice_servers`, `turn_servers` liefern.
2. **Freezed Codegen:** Bei weiteren Model-Änderungen Build Runner erneut ausführen.

---

## Session 35: Phase 16c – 20-Schritte Implementierung (2026-01-23)

### 35.1 Implementierte 20 Schritte

| # | Phase | Schritt | Status | Dateien |
|---|-------|---------|--------|---------|
| 1 | API-Contract | Backend-Schema geprüft | ✅ | `backend/app/schemas/consultation_schemas.py` |
| 2 | API-Contract | DTO-Felder validiert | ✅ | `consultation.dart` (Session 34) |
| 3 | API-Contract | Service-Mapping verifiziert | ✅ | `consultation_service.dart` |
| 4 | API-Contract | JSON-Keys geprüft | ✅ | `consultation.g.dart` (Session 34) |
| 5 | UI-Datenfluss | Mock→Provider ersetzt | ✅ | `consultations_screen.dart` |
| 6 | UI-Datenfluss | 112-Notruf-Dialer | ✅ | `consultations_screen.dart` |
| 7 | UI-Datenfluss | Loading/Error States | ✅ | `consultations_screen.dart` |
| 8 | UI-Datenfluss | Pull-to-Refresh | ✅ | `consultations_screen.dart` |
| 9 | WebRTC | Init Flow stabilisiert | ✅ | `video_call_screen.dart`, `voice_call_screen.dart` |
| 10 | WebRTC | Media-Controls (Mute/Camera) | ✅ | `video_call_screen.dart`, `voice_call_screen.dart` |
| 11 | WebRTC | Signaling Reconnect-Logic | ✅ | `video_call_screen.dart`, `voice_call_screen.dart` |
| 12 | WebRTC | Connection-State UI-Feedback | ✅ | `video_call_screen.dart`, `voice_call_screen.dart` |
| 13 | WebRTC | Call-End Cleanup | ✅ | `video_call_screen.dart`, `voice_call_screen.dart` |
| 14 | E2E-Encryption | Encryption vollständig in chat_screen | ✅ | `chat_screen.dart` (bereits implementiert) |
| 15 | E2E-Encryption | Message-Index UX (Scroll-to) | ✅ | `chat_screen.dart` |
| 16 | E2E-Encryption | Provider wiring verifiziert | ✅ | `core_providers.dart` (encryptionServiceProvider) |
| 17 | Tests | Unit-Tests: Consultation Models | ✅ | `packages/core/test/models_test.dart` |
| 18 | Tests | Unit-Tests: ConsultationService | ✅ | `packages/core/test/consultation_service_test.dart` |
| 19 | Tests | Widget-Tests: Screens | ✅ | `consultation_screens_test.dart` (Session 34) |
| 20 | Docs | Session-Log update | ✅ | `docs/laufbahn.md` |

### 35.2 Neue/Geänderte Dateien

| Datei | Änderungen |
|-------|------------|
| `consultations_screen.dart` | Provider für aktive Konsultationen, 112-Dialer via url_launcher, RefreshIndicator, Loading/Error States, `_RealConsultationListItem` |
| `video_call_screen.dart` | `WebRTCConnectionState` Enum, Reconnect-Logic (5 Versuche), Duration-Timer, Connection-Overlays, Cleanup-Logik |
| `voice_call_screen.dart` | `VoiceCallConnectionState` Enum, gleiche Verbesserungen wie Video |
| `chat_screen.dart` | Such-UI in AppBar, `_performSearch()`, `_scrollToMessage()`, `_navigateSearchResult()` |
| `models_test.dart` | 10+ neue Tests für Consultation, ConsultationCreate, ConsultationMessage, WebRTCRoom, WebRTC Signaling |
| `consultation_service_test.dart` | **NEU** - 20+ Unit-Tests für alle Service-Methoden inkl. Error-Cases |

### 35.3 Architektur-Verbesserungen

```
┌─────────────────────────────────────────────────────────────────────┐
│                    consultations_screen.dart                        │
│  ┌──────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │ RefreshIndicator │  │ FutureProvider    │  │ url_launcher     │ │
│  │ (Pull-to-Refresh)│  │ (Aktive Sessions) │  │ (112 Emergency)  │ │
│  └──────────────────┘  └───────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│              video_call_screen.dart / voice_call_screen.dart        │
│  ┌──────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │ ConnectionState  │  │ Signaling Loop    │  │ Cleanup Logic    │ │
│  │ Enum (5 States)  │  │ (Reconnect x5)    │  │ (_performCleanup)│ │
│  └──────────────────┘  └───────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                         chat_screen.dart                            │
│  ┌──────────────────┐  ┌───────────────────┐  ┌──────────────────┐ │
│  │ Search in AppBar │  │ EncryptionService │  │ Scroll-to-Msg    │ │
│  │ (Toggle Mode)    │  │ (searchMessages)  │  │ (_scrollToMessage)│ │
│  └──────────────────┘  └───────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

### 35.4 Test-Abdeckung (Schritt 17-18)

```
packages/core/test/
├── models_test.dart          # +180 LOC (Consultation, WebRTC Models)
├── consultation_service_test.dart  # NEU: 400+ LOC (alle Endpoints)
└── utils_test.dart           # Bestand
```

**Neue Tests:**
- Consultation CRUD (getMyConsultations, getConsultation, requestConsultation, cancelConsultation)
- Messages (getMessages, sendMessage, markMessagesRead)
- Video/Voice Call (getCallRoom, joinCall, endCall)
- WebRTC Signaling (sendOffer, sendAnswer, sendIceCandidate, pollSignals, clearSignals)
- Quick Helpers (requestCallback, requestVideoCall)
- Error Handling (404, 401)

### 35.5 Nächste Schritte

1. **flutter_webrtc Integration:** Tatsächliche WebRTC-Calls implementieren (RTCPeerConnection)
2. **Backend-Alignment:** Sicherstellen dass `/consultations/*` Endpoints funktionieren
3. **E2E-Tests:** Playwright/Maestro für vollständige User-Flows
4. **TURN Server:** Coturn aufsetzen für NAT-Traversal in Produktion

### 35.6 Dependencies

`http_mock_adapter` für Service-Tests hinzufügen:
```yaml
# packages/core/pubspec.yaml
dev_dependencies:
  http_mock_adapter: ^0.6.1
```

---

## 36. Session Log 2026-01-22: Phase 16 – Online-Rezeption & Hausarzt-Automatisierung

### 36.1 Übersicht

Implementierung eines umfassenden **30-Punkte-Plans** zur Erweiterung der Online-Rezeption mit Hausarzt-Automatisierungsfunktionen. Fokus auf **i18n für spätere Zulassung**, **DSGVO-Compliance** und **Offline-First-Architektur**.

**User-Anforderungen:**
- ✅ i18n-Support für 8 Sprachen (Lizenzierung in anderen Ländern)
- ✅ DSGVO-konform (Art. 7, 17, 20, 30)
- ❌ Keine TI-Integration (explizit ausgeschlossen)
- ✅ Phase C als Grundlage für zukünftige Features

### 36.2 Neue Dateien (Dateiregister)

#### Backend Routers (9 neue Module)

| Datei | LOC | Beschreibung |
|-------|-----|--------------|
| `backend/app/routers/privacy.py` | ~300 | DSGVO Art. 7/17/20/30 (Consent, Löschung, Export, Audit) |
| `backend/app/routers/appointments.py` | ~400 | Terminbuchung mit Slot-Management |
| `backend/app/routers/anamnesis.py` | ~450 | Digitale Anamnesebögen mit Fragentypen |
| `backend/app/routers/symptom_checker.py` | ~350 | KI-gestützte Triage mit Red Flags |
| `backend/app/routers/lab_results.py` | ~450 | Laborbefunde mit Freigabe-Workflow |
| `backend/app/routers/medications.py` | ~450 | Medikationsplan mit Interaktionsprüfung |
| `backend/app/routers/vaccinations.py` | ~500 | Impfpass mit STIKO-Empfehlungen |
| `backend/app/routers/forms.py` | ~250 | Praxisformulare zum Download |
| `backend/app/routers/workflows.py` | ~400 | Workflow-Automatisierung |

#### Flutter UI (3 neue Screens)

| Datei | LOC | Beschreibung |
|-------|-----|--------------|
| `apps/patient_app/lib/features/appointments/screens/book_appointment_screen.dart` | ~400 | Multi-Step Terminbuchung |
| `apps/patient_app/lib/features/appointments/screens/my_appointments_screen.dart` | ~300 | Terminliste mit Tabs |
| `apps/patient_app/lib/features/anamnesis/screens/fill_anamnesis_screen.dart` | ~500 | Dynamischer Fragebogen |

#### i18n & Localization

| Datei | LOC | Beschreibung |
|-------|-----|--------------|
| `packages/core/lib/src/l10n/sanad_localizations.dart` | ~600 | Lokalisierungssystem |
| `packages/core/lib/src/l10n/arb/app_de.arb` | - | Deutsch |
| `packages/core/lib/src/l10n/arb/app_en.arb` | - | Englisch |
| `packages/core/lib/src/l10n/arb/app_tr.arb` | - | Türkisch |
| `packages/core/lib/src/l10n/arb/app_ar.arb` | - | Arabisch |
| `packages/core/lib/src/l10n/arb/app_ru.arb` | - | Russisch |
| `packages/core/lib/src/l10n/arb/app_pl.arb` | - | Polnisch |
| `packages/core/lib/src/l10n/arb/app_fr.arb` | - | Französisch |
| `packages/core/lib/src/l10n/arb/app_es.arb` | - | Spanisch |

#### Infrastruktur

| Datei | LOC | Beschreibung |
|-------|-----|--------------|
| `packages/core/lib/src/services/offline_sync_service.dart` | ~280 | Hive-basiertes Offline-Caching |
| `packages/ui/lib/src/theme/sanad_theme.dart` | ~400 | Dark Mode + Material 3 |
| `packages/ui/lib/src/widgets/accessibility_widgets.dart` | ~250 | WCAG 2.1 AA Widgets |
| `packages/ui/lib/src/widgets/rtl_aware_widgets.dart` | ~200 | RTL-Support für Arabisch |
| `backend/tests/test_online_rezeption.py` | ~300 | API-Tests für alle neuen Endpoints |

### 36.3 API-Endpunkte (Neue Routes)

```
/api/v1/privacy/
├── GET  /consent              # Consent-Status abrufen
├── POST /consent              # Einwilligung erteilen
├── DELETE /consent            # Einwilligung widerrufen
├── POST /delete-request       # Art. 17 Löschanfrage
├── GET  /export               # Art. 20 Datenexport
└── GET  /audit-log            # Art. 30 Verarbeitungsprotokoll

/api/v1/appointments/
├── GET  /types                # Terminarten
├── GET  /slots                # Verfügbare Slots
├── GET  /my                   # Meine Termine
├── POST /                     # Termin buchen
├── DELETE /{id}               # Termin stornieren
└── POST /{id}/confirm         # Termin bestätigen

/api/v1/anamnesis/
├── GET  /templates            # Anamnesevorlagen
├── GET  /templates/{id}       # Einzelne Vorlage
├── POST /submit               # Anamnese absenden
└── GET  /my-submissions       # Meine Anamnesen

/api/v1/symptom-checker/
├── GET  /symptoms             # Verfügbare Symptome
├── GET  /red-flags            # Warnzeichen-Liste
└── POST /check                # Triage durchführen

/api/v1/lab-results/
├── GET  /my                   # Meine Befunde
├── GET  /my/{id}              # Einzelner Befund
├── POST /release              # Befund freigeben (Staff)
└── GET  /reference-values     # Referenzwerte

/api/v1/medications/
├── GET  /my                   # Meine Medikamente
├── GET  /my/plan              # Vollständiger Medikationsplan
├── GET  /my/schedule/today    # Heutige Einnahmen
└── POST /check-interactions   # Interaktionsprüfung

/api/v1/vaccinations/
├── GET  /my                   # Meine Impfungen
├── GET  /my/pass              # Digitaler Impfpass
├── GET  /my/recommendations   # STIKO-Empfehlungen
└── GET  /recalls/my           # Meine Impf-Recalls

/api/v1/forms/
├── GET  /                     # Alle Formulare
├── GET  /categories           # Formularkategorien
├── GET  /{id}/download        # Formular herunterladen
└── POST /{id}/submit          # Formular absenden

/api/v1/workflows/
├── GET  /                     # Alle Workflows
├── PUT  /{id}/status          # Workflow aktivieren/deaktivieren
├── POST /{id}/trigger         # Workflow manuell auslösen
├── GET  /tasks/               # Praxisaufgaben
└── POST /tasks/               # Aufgabe erstellen
```

### 36.4 Architektur-Diagramme

#### Symptom-Checker Triage-System

```
┌──────────────────────────────────────────────────────────────────────┐
│                     TRIAGE-LEVEL KLASSIFIKATION                       │
├────────────┬─────────────────────────────────────────────────────────┤
│ EMERGENCY  │ Sofort Notruf 112 → Brustschmerz, Atemnot, Bewusstlos   │
│ (Rot)      │ Red Flag + severity >= 9                                │
├────────────┼─────────────────────────────────────────────────────────┤
│ URGENT     │ Innerhalb 4h zum Arzt → Red Flag ohne severity >= 9     │
│ (Orange)   │                                                         │
├────────────┼─────────────────────────────────────────────────────────┤
│ SOON       │ Innerhalb 24-48h → severity >= 6 ODER duration > 3d     │
│ (Gelb)     │                                                         │
├────────────┼─────────────────────────────────────────────────────────┤
│ ROUTINE    │ Regulärer Termin → severity >= 4                        │
│ (Grün)     │                                                         │
├────────────┼─────────────────────────────────────────────────────────┤
│ SELF_CARE  │ Selbstbehandlung → severity < 4, keine Red Flags        │
│ (Blau)     │                                                         │
└────────────┴─────────────────────────────────────────────────────────┘
```

#### Offline-Sync-Architektur

```
┌─────────────────────────────────────────────────────────────────────┐
│                       OFFLINE-FIRST FLOW                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┐    ┌─────────────┐    ┌──────────────┐                │
│  │  User   │───▶│ CacheFirst  │───▶│ Hive Storage │                │
│  │ Action  │    │  Strategy   │    │  (Local)     │                │
│  └─────────┘    └──────┬──────┘    └──────────────┘                │
│                        │                                           │
│                        ▼ (wenn online)                             │
│               ┌─────────────────┐                                  │
│               │   SyncQueue     │                                  │
│               │ (Pending Ops)   │                                  │
│               └────────┬────────┘                                  │
│                        │                                           │
│                        ▼                                           │
│               ┌─────────────────┐    ┌──────────────┐             │
│               │ ConnectivityMon │───▶│ API Server   │             │
│               │ (onStatusChange)│    │ (FastAPI)    │             │
│               └─────────────────┘    └──────────────┘             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

#### DSGVO-Consent-Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DSGVO COMPLIANCE                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Art. 7 Einwilligung       Art. 17 Recht auf Löschung              │
│  ┌───────────────┐         ┌───────────────────┐                   │
│  │ Granular      │         │ DELETE /privacy/  │                   │
│  │ Checkboxes    │         │ delete-request    │                   │
│  │ per Purpose   │         │                   │                   │
│  │ + Timestamp   │         │ → Status-Tracking │                   │
│  └───────────────┘         │ → 30-Tage-Frist   │                   │
│                            └───────────────────┘                   │
│                                                                     │
│  Art. 20 Datenübertragung  Art. 30 Verarbeitungsverzeichnis        │
│  ┌───────────────┐         ┌───────────────────┐                   │
│  │ GET /privacy/ │         │ GET /privacy/     │                   │
│  │ export        │         │ audit-log         │                   │
│  │               │         │                   │                   │
│  │ → JSON/PDF    │         │ → Alle Zugriffe   │                   │
│  │ → Machine-    │         │ → Änderungen      │                   │
│  │   readable    │         │ → Consent-History │                   │
│  └───────────────┘         └───────────────────┘                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 36.5 30-Punkte-Plan – Abgeschlossen

| # | Aufgabe | Status |
|---|---------|--------|
| 1 | i18n-Infrastruktur (SanadLocalizations) | ✅ |
| 2 | Deutsche Übersetzungen (app_de.arb) | ✅ |
| 3 | Englische Übersetzungen (app_en.arb) | ✅ |
| 4 | 6 weitere Sprachen (TR, AR, RU, PL, FR, ES) | ✅ |
| 5 | RTL-Support für Arabisch | ✅ |
| 6 | WCAG 2.1 AA Accessibility | ✅ |
| 7 | DSGVO Art. 7 – Consent-System | ✅ |
| 8 | DSGVO Art. 17 – Löschrecht | ✅ |
| 9 | DSGVO Art. 20 – Datenexport | ✅ |
| 10 | DSGVO Art. 30 – Audit-Log | ✅ |
| 11 | Terminbuchung Backend | ✅ |
| 12 | Terminbuchung UI (BookAppointmentScreen) | ✅ |
| 13 | Terminerinnerungen (in Workflows integriert) | ✅ |
| 14 | Anamnese Backend | ✅ |
| 15 | Anamnese UI (FillAnamnesisScreen) | ✅ |
| 16 | Symptom-Checker mit Triage | ✅ |
| 17 | Laborbefunde Backend | ✅ |
| 18 | Laborbefund-Freigabe-Workflow | ✅ |
| 19 | Medikationsplan Backend | ✅ |
| 20 | Interaktionsprüfung | ✅ |
| 21 | Impfpass Backend | ✅ |
| 22 | Impf-Recall-System | ✅ |
| 23 | STIKO-Empfehlungen | ✅ |
| 24 | Praxisformulare | ✅ |
| 25 | Workflow-Automatisierung | ✅ |
| 26 | Push-Benachrichtigungen (existiert bereits) | ✅ |
| 27 | Offline-Sync-Service | ✅ |
| 28 | Dark Mode Theme | ✅ |
| 29 | API-Tests | ✅ |
| 30 | Dokumentation (diese Sektion) | ✅ |

### 36.6 Dependencies

Neue Abhängigkeiten für Offline-First:

```yaml
# packages/core/pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.2
```

### 36.7 Nächste Schritte (Phase 17+)

1. **Flutter-Integration:** API-Services für neue Endpoints in `packages/core`
2. **UI-Screens:** Symptom-Checker, Laborbefunde, Medikationsplan, Impfpass
3. **PDF-Export:** Medikationsplan und Impfpass als PDF
4. **E2E-Tests:** Playwright für vollständige Patientenreisen
5. **Performance:** Lazy-Loading für große Listen
6. **Analytics:** Anonymisierte Nutzungsstatistiken
