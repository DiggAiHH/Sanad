# 🛤️ LAUFBAHN – Sanad Agent Handoff Log

> **Letzte Aktualisierung:** 2026-01-24
> **Agent-Version:** Senior Architect Agent v2025.2
> **Status:** 🟡 Phase 14: UI Polish Sprint (Build ausstehend)

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

### Phase 0-8: Siehe vorherige Logs (laufbahn.md)

### Phase 9: Design System & UI Overhaul ✅ (NEU)

| Aktion | Status | Notizen |
|--------|--------|---------|
| Color Palette Audit | ✅ | WCAG Kontrast Probleme behoben |
| Global AppTheme | ✅ | inputDecorationTheme, switchTheme, dropdownMenuTheme hinzugefügt |
| `SanadToggle` Component | ✅ | Standardisierter Switch mit Label |
| `SanadDropdown` Component | ✅ | Standardisierter Dropdown mit Styling |
| Admin App Refactoring | ✅ | Settings & Users Screen migriert |
| Staff App Refactoring | ✅ | Tasks Screen migriert |

### Phase 11: Backend Hardening ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| RateLimit Middleware | ✅ | In-memory Sliding Window, 429 Responses |
| RequestSizeLimit Middleware | ✅ | 413 Responses mit JSON Fehler |
| SecurityHeaders Middleware | ✅ | Default-Deny Header gesetzt |
| require_roles Alias | ✅ | Router-Import Bugfix |
| Backend Tests | ✅ | 3 neue Tests (Headers/Size/Rate) |

### Phase 12: Backend Reliability ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| RateLimit Skip-Paths | ✅ | /health und /metrics ausgenommen |
| Error Handler HTTPException | ✅ | JSON Fehlerformat mit correlation_id |
| Error Handler Validation | ✅ | JSON Fehlerformat mit detail[] |
| Backend Tests | ✅ | 2 neue Handler-Tests |

### Phase 13: Backend Reliability ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| Error Handler 500 | ✅ | Sanitized 500 Payload + correlation_id |
| Error Metrics | ✅ | record_error bei 500 |
| Backend Tests | ✅ | 1 neuer 500-Handler Test |

### Phase 14: Backend Reliability ✅

| Aktion | Status | Notizen |
|--------|--------|---------|
| Starlette HTTP Handler | ✅ | 404/405 JSON Error Payloads |
| RateLimit Skip-Pfade | ✅ | /docs, /redoc, /openapi.json ausgenommen |
| Backend Tests | ✅ | 1 neuer 404-Handler Test |

### Phase 14: UI Polish Sprint ⏳ (In Progress)

| Aktion | Status | Notizen |
|--------|--------|---------|
| Design Tokens Audit | ✅ | Existierende Tokens in theme_extensions.dart identifiziert |
| Farb-Migration Patient App | ✅ | Colors.white/grey → AppColors.surface/textSecondary |
| BorderRadius Migration | ✅ | BorderRadius.circular → AppRadius.small/medium/large |
| Spacing Migration | ✅ | EdgeInsets.all → AppSpacing.cardPadding |
| Shadows Migration | ✅ | Inline BoxShadow → AppShadows.small |
| tokens.dart Konflikt | ✅ | DEPRECATED gesetzt, Export entfernt |
| Build | ⏳ | Ausstehend |
| Deploy | ⏳ | Ausstehend |

**Geänderte Dateien in Phase 14:**
- `apps/patient_app/lib/features/home/screens/home_screen.dart`
- `apps/patient_app/lib/features/info/screens/info_screen.dart`
- `apps/patient_app/lib/features/anamnesis/screens/fill_anamnesis_screen.dart`
- `apps/patient_app/lib/features/appointments/screens/my_appointments_screen.dart`
- `packages/ui/lib/src/theme/tokens.dart` (DEPRECATED)
- `packages/ui/lib/src/theme/theme.dart` (Export entfernt)

---

## 4. Dateiregister

### 4.3 UI Package Updates

```
packages/ui/lib/src/
├── theme/
│   ├── app_colors.dart           # Updated (Contrast Fix)
│   └── app_theme.dart            # Updated (New Themes)
└── widgets/
    └── inputs/
        ├── sanad_toggle.dart     # NEU
        └── sanad_dropdown.dart   # NEU
```

---

## 5. Offene Aufgaben

### 5.1 Design System Rollout

| Priorität | Aufgabe | Beschreibung | Status |
|-----------|---------|--------------|--------|
| P1 | **Refactor Patient App** | `DropdownButtonFormField` ersetzen | ✅ Abgeschlossen |
| P2 | **Refactor MFA App** | Prüfen auf inkonsistente Inputs | ✅ Abgeschlossen |
| P3 | **Icon Consistency** | Sicherstellen, dass alle Icons Material Symbols verwenden | ✅ Geprüft |

### 5.2 UI Polish Phase 14 (Aktuell)

| Priorität | Aufgabe | Beschreibung | Status |
|-----------|---------|--------------|--------|
| P1 | **Build ausführen** | `bash scripts/build_web.sh` | ⏳ Ausstehend |
| P2 | **Netlify Deploy** | `netlify deploy --prod --dir=build/web_deploy` | ⏳ Ausstehend |
| P3 | **Git Commit** | Änderungen committen und pushen | ⏳ Ausstehend |

---

## 6. Annahmen & Risiken

- tokens.dart wurde auf DEPRECATED gesetzt da Namenskonflikte mit existierenden Klassen (AppSpacing, AppRadius, AppShadows, AppTextStyles) in theme_extensions.dart und app_text_styles.dart bestanden.

---

## 7. Fortsetzungsanleitung

**Für neuen Agent:**

1. Diese Datei lesen (laufbahn.md)
2. tasks.md lesen (aktuelle Phase 14 Tasks)
3. Build ausführen: `bash scripts/build_web.sh`
4. Falls Build erfolgreich: `netlify deploy --prod --dir=build/web_deploy`
5. Git commit und push
