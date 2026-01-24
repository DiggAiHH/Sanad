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
23. [ ] Patient App: Dark Mode in home_screen.dart testen/fixen
24. [ ] Patient App: Dark Mode in info_screen.dart testen/fixen
25. [ ] Admin App: Dashboard Dark Mode prüfen
26. [ ] Staff App: Dark Mode in Tasks prüfen

### F. Finalisierung & Deployment (27-30)
27. [ ] Build: bash scripts/build_web.sh
28. [ ] Deploy: netlify deploy --prod --dir=build/web_deploy
29. [ ] Doku: memory_log.md und laufbahn.md aktualisieren
30. [ ] Final: Git commit mit aussagekräftiger Message

---

## 📝 Implementierungs-Log

### Session 2026-01-24 (aktuell)
- **Start:** Tasklist erstellt mit 30 neuen UI-Polish-Punkten
- **Fokus:** Design Tokens, Farb-Konsistenz, Typografie
- **Status:** Task 1 in Bearbeitung

<!-- Bei Crash: Fortsetzen ab letztem nicht-abgehaktem Task -->

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
