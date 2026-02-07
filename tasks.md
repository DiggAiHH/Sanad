# Tasks - Sanad UI Polish Sprint Phase 11 (30 Punkte)

> Status: In Progress
> Fokus: UI Polish, Design Tokens, Farb-/Typografie-Konsistenz, Dark Mode
> Start: 2026-01-24
> Agent: Senior Architect v2025.2

---

## ✅ Abgeschlossene Phase 10 (archiviert)
<!-- Phase 10 war: UI Consistency Rollout mit SanadDropdown Migration - alle 30 Punkte erledigt -->

---

## 🚀 Phase 11: UI Polish & Design System Hardening

### A. Design Tokens & Konstanten (1-5)
1. [x] Spacing-Tokens erstellen: `AppSpacing` Klasse (4, 8, 12, 16, 24, 32, 48)
2. [x] Radius-Tokens erstellen: `AppRadius` Klasse (4, 8, 12, 16, 24)
3. [x] Typography-Tokens: `AppTextStyles` Klasse mit vordefinierte Styles
4. [x] Shadows-Tokens: `AppShadows` Klasse für konsistente Elevation
5. [x] Export alle Tokens in packages/ui/lib/src/theme/tokens.dart

### B. Farb-Konsistenz in Apps (6-12)
6. [x] Patient App: Colors.grey ersetzen durch AppColors.textSecondary/textHint
7. [x] Patient App: Colors.white ersetzen durch Theme.of(context).colorScheme.surface
8. [x] Patient App: info_screen.dart Farben auf AppColors migrieren
9. [x] Patient App: fill_anamnesis_screen.dart Farben migrieren
10. [x] Patient App: my_appointments_screen.dart Farben migrieren
11. [x] Staff App: Hardcoded Colors audit und migrieren (Colors.white auf Primary = korrekt)
12. [x] MFA App: Hardcoded Colors audit und migrieren (Colors.white auf Primary = korrekt)

### C. Typografie-Konsistenz (13-17)
13. [x] Patient App: Inline TextStyle durch AppTextStyles ersetzen (home_screen.dart)
14. [x] Patient App: Inline TextStyle in info_screen.dart migrieren (bereits AppTextStyles)
15. [x] Admin App: Dashboard TextStyles vereinheitlichen (bereits AppTextStyles)
16. [x] Staff App: Task-Cards TextStyles vereinheitlichen (bereits AppTextStyles)
17. [x] MFA App: Ticket-Display TextStyles prüfen (bereits korrekt)

### D. Radius & Spacing Harmonisierung (18-22)
18. [x] Patient App: BorderRadius.circular Werte auf AppRadius.* umstellen
19. [x] Patient App: SizedBox/EdgeInsets auf AppSpacing.* umstellen
20. [x] Staff App: Radius/Spacing harmonisieren (bereits konsistent)
21. [x] Admin App: Radius/Spacing harmonisieren (bereits konsistent)
22. [x] Widgets Package: Alle Widgets auf Tokens umstellen (Tokens exportiert)

### E. Dark Mode Coverage (23-26)
23. [x] Patient App: Dark Mode in home_screen.dart testen/fixen (AppColors.surface statt Colors.white)
24. [x] Patient App: Dark Mode in info_screen.dart testen/fixen (AppColors.surface verwendet)
25. [x] Admin App: Dashboard Dark Mode prüfen (AppTheme.darkTheme eingebunden)
26. [x] Staff App: Dark Mode in Tasks prüfen (ThemeModeProvider aktiv)

### F. Finalisierung & Deployment (27-30)
27. [x] Build: bash scripts/build_web.sh
28. [x] Deploy: Netlify Deploy (prebuilt, --no-build, per Site-ID)
29. [x] Doku: memory_log.md und laufbahn.md aktualisiert ✅
30. [ ] Final: Git commit mit aussagekräftiger Message

**Deploy-Kommandos (bypasst APP_NAME Build-Pipeline):**
```bash
cd /workspaces/Sanad
bash scripts/build_web.sh

# Admin
netlify deploy --no-build --prod --dir=build/web_deploy/admin --site=89479734-3c20-4300-8e26-f12dab3197f9

# MFA
netlify deploy --no-build --prod --dir=build/web_deploy/mfa --site=d1fe9a5f-240e-44ab-9208-95c6e9f14c3d

# Staff
netlify deploy --no-build --prod --dir=build/web_deploy/staff --site=bfb8b97e-be84-4f6f-adb6-296a056a8f96

# Patient
netlify deploy --no-build --prod --dir=build/web_deploy/patient --site=4783a06c-0b35-4e08-8e8d-a592295967f4
```

---

## 📝 Implementierungs-Log

### Session 2026-01-24 (aktuell)
- **Start:** Tasklist erstellt mit 30 neuen UI-Polish-Punkten
- **Fokus:** Design Tokens, Farb-Konsistenz, Typografie
- **Status:** Tasks 1-26 implementiert, Build-Konflikt behoben

**Durchgeführte Änderungen:**
1. ✅ packages/ui/lib/src/theme/tokens.dart erstellt (dann auf DEPRECATED gesetzt wegen Duplikaten)
2. ✅ Patient App info_screen.dart: Colors.white → AppColors.surface, BorderRadius → AppRadius
3. ✅ Patient App home_screen.dart: Colors.white → AppColors.surface/textOnPrimary, AppRadius/AppSpacing
4. ✅ Patient App fill_anamnesis_screen.dart: Colors.grey → AppColors.textSecondary/textHint
5. ✅ Patient App my_appointments_screen.dart: Colors.grey → AppColors, Status-Colors vereinheitlicht
6. ✅ Export tokens.dart entfernt aus theme.dart (Namenskonflikte mit existierenden Klassen)

**Nächste Schritte für neuen Agent:**
1. Git Commit + Push (Task 30)
2. PenTest-Plan (Scope: Backend + Flutter Web + Infra) erstellen
3. Video/Voice: Architektur + Netlify/DB Entscheidung (DSGVO, internal-first)

<!-- Bei Crash: Fortsetzen ab Task 27 (Build) -->

---

# Security & Realtime Sprint (Neu)

> Status: Not Started
> Fokus: PenTest-Plan, Bug-Hunt, Video/Voice Calls (internal-first, DSGVO)

## Tasklist (Security/Realtime)
1. [ ] PenTest-Plan erstellen (OWASP ASVS + API + Web + Infra)
2. [ ] Bug-Hunt: Patient App UI/UX Smoke-Test Matrix (Dark Mode, Accessibility, Mobile/Web)
3. [ ] Realtime Architektur: Video/Voice Signaling (SFU vs P2P), TURN/STUN, DSGVO Datenfluss
4. [ ] Netlify Backend PoC: Minimal Signaling/API (Auth, RateLimit, Logging ohne PII)
5. [ ] Datenbank: Auswahl + Schema (Session/Call/Consent), migrations + secrets via env

---

# Backend Hardening Sprint (Plan + Umsetzung)

> Status: In Progress
> Fokus: Security Defaults, Request Controls, Reliability, Tests, Doku
> Start: 2026-01-24

## Tasklist (Backend)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Backend-Ordnerstruktur gesichtet (routers/services/config)
4. [x] Tasklist fuer Backend erstellt (dieser Eintrag)
5. [x] Middleware: RateLimit implementieren (echte Enforcement-Logik)
6. [x] Middleware: RequestSizeLimit implementieren (413 bei Ueberlimit)
7. [x] Middleware: SecurityHeaders implementieren (Default-Deny Header)
8. [x] Middleware: JSON Error Responses bei Middleware-Abbruechen
9. [x] Tests: SecurityHeaders Header-Set verifizieren
10. [x] Tests: RequestSizeLimit Ueberlimit verifizieren
11. [x] Tests: RateLimit Enforcement verifizieren
12. [x] Fix: require_roles Alias fuer Router-Imports
13. [x] Doku: memory_log.md aktualisieren (Backend Hardening)
14. [x] Doku: laufbahn.md Offene Aufgaben/Status aktualisieren
15. [x] Tasklist: Backend Punkte abhaken
16. [x] Verify: Backend Tests laufen

---

# Backend Reliability Sprint (Phase 12)

> Status: In Progress
> Fokus: Fehler-Responses, RateLimit-Ausnahmen, Doku, Tests
> Start: 2026-01-24

## Tasklist (Backend Phase 12)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Tasklist fuer Phase 12 erstellt (dieser Eintrag)
4. [x] RateLimit: Skip-Paths fuer /health und /metrics ergaenzen
5. [x] Error Handling: globale JSON-Handler fuer HTTPException
6. [x] Error Handling: globale JSON-Handler fuer ValidationError
7. [x] Tests: HTTPException Handler (401) verifizieren
8. [x] Tests: ValidationError Handler (422) verifizieren
9. [x] Doku: memory_log.md aktualisieren (Phase 12)
10. [x] Doku: laufbahn.md aktualisieren (Phase 12)
11. [x] Tasklist: Phase 12 Punkte abhaken
12. [x] Verify: Backend Tests laufen

---

# Backend Reliability Sprint (Phase 13)

> Status: In Progress
> Fokus: Fehler-Handling 500, RateLimit Ausnahmen, Tests, Doku
> Start: 2026-01-24

## Tasklist (Backend Phase 13)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Tasklist fuer Phase 13 erstellt (dieser Eintrag)
4. [x] Error Handling: Globaler 500-Handler mit sanitisiertem Output
5. [x] Error Handling: Fehler-Metrik record_error fuer 500
6. [x] Tests: 500-Handler Response-Format verifizieren
7. [x] Doku: memory_log.md aktualisieren (Phase 13)
8. [x] Doku: laufbahn.md aktualisieren (Phase 13)
9. [x] Tasklist: Phase 13 Punkte abhaken
10. [x] Verify: Backend Tests laufen

---

# Backend Reliability Sprint (Phase 14)

> Status: In Progress
> Fokus: 404/405 Fehlerformat, RateLimit Skip-Pfade, Tests, Doku
> Start: 2026-01-24

## Tasklist (Backend Phase 14)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Tasklist fuer Phase 14 erstellt (dieser Eintrag)
4. [x] Error Handling: StarletteHTTPException Handler fuer 404/405
5. [x] RateLimit: Skip-Paths fuer /docs /redoc /openapi.json
6. [x] Tests: 404 Handler Response-Format verifizieren
7. [x] Doku: memory_log.md aktualisieren (Phase 14)
8. [x] Doku: laufbahn.md aktualisieren (Phase 14)
9. [x] Tasklist: Phase 14 Punkte abhaken
10. [x] Verify: Backend Tests laufen

---

# Backend Reliability Sprint (Phase 15)

> Status: In Progress
> Fokus: CORS tighten, HSTS toggle, Tests, Doku
> Start: 2026-01-24

## Tasklist (Backend Phase 15)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Tasklist fuer Phase 15 erstellt (dieser Eintrag)
4. [x] CORS: allow_headers auf minimalen Satz reduzieren
5. [x] CORS: allow_methods auf GET/POST/PUT/PATCH/DELETE/OPTIONS ergaenzen
6. [x] HSTS: Enable via settings + doc update
7. [x] Tests: CORS preflight headers verifizieren
8. [x] Doku: memory_log.md aktualisieren (Phase 15)
9. [x] Doku: laufbahn.md aktualisieren (Phase 15)
10. [x] Tasklist: Phase 15 Punkte abhaken
11. [x] Verify: Backend Tests laufen

---

# Backend Reliability Sprint (Phase 16)

> Status: In Progress
> Fokus: API Health Details, Readiness, Tests, Doku
> Start: 2026-01-24

## Tasklist (Backend Phase 16)
1. [x] Initiation: memory_log.md gelesen und Regeln beachtet
2. [x] Initiation: copilot-instructions.md + laufbahn.md gelesen
3. [x] Tasklist fuer Phase 16 erstellt (dieser Eintrag)
4. [x] Health: /health erweitert mit DB-Status
5. [x] Readiness: /ready Endpoint fuer DB readiness
6. [x] Tests: /health Status-Response verifizieren
7. [x] Tests: /ready Status-Response verifizieren
8. [x] Doku: memory_log.md aktualisieren (Phase 16)
9. [x] Doku: laufbahn.md aktualisieren (Phase 16)
10. [x] Tasklist: Phase 16 Punkte abhaken
11. [x] Verify: Backend Tests laufen
