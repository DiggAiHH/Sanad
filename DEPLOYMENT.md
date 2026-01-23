# ==============================================================================
# 🚀 SANAD - Deployment-Anleitung (Railway + Netlify)
# ==============================================================================
#
# Diese Anleitung bringt alle 4 Apps + Backend öffentlich online:
# - Backend: Railway (kostenloses/kleines Hobby-Tier)
# - Flutter Web Apps: Netlify (kostenlos)
#
# Geschätzte Zeit: ~30 Minuten
# ==============================================================================

## ✅ Bevorzugter Weg: Railway (Backend) + Netlify (Frontend)

### 1) Backend auf Railway deployen
1. https://railway.app öffnen und anmelden
2. "New Project" → "Deploy from GitHub Repo"
3. Repo `DiggAiHH/Sanad` auswählen
4. Service Root auf `backend/` setzen (oder Dockerfile im Root angeben)
5. Environment Variables setzen:
   - `DATABASE_URL` (Railway Postgres Plugin liefert diese URL)
   - `JWT_SECRET_KEY` (starkes Secret, keine Defaults)
   - `CORS_ORIGINS` (kommasepariert, z.B. Netlify Domains)
   - optional: `SEED_ON_STARTUP=true` für Demo-Daten
6. Deploy starten → Domain notieren, z.B. `https://sanad-api-production.up.railway.app`

### 2) Frontend auf Netlify deployen
Pro App eine eigene Netlify Site erstellen (monorepo-ready).

1. Netlify → "Add new site" → "Import from Git"
2. Repo `DiggAiHH/Sanad` wählen
3. Build Einstellungen (wie in `netlify.toml`):
   - Build command: `bash scripts/netlify_build.sh`
   - Publish directory: `build/web_deploy/admin` (wird pro App gesetzt)
4. Environment Variables je Site setzen:
   - `APP_NAME` = `admin` | `mfa` | `staff` | `patient`
   - `API_BASE_URL` = `https://<railway-domain>/api/v1`

### 3) CORS auf Backend prüfen
Stelle sicher, dass deine Netlify URLs in `CORS_ORIGINS` oder `NETLIFY_DOMAINS` enthalten sind.

---

# ==============================================================================
# Legacy: Render + Cloudflare Pages (Alternative)
# ==============================================================================

## 📋 Voraussetzungen

- GitHub Account (bereits vorhanden: DiggAiHH/Sanad)
- Render.com Account (kostenlos erstellen)
- Cloudflare Account (kostenlos erstellen)

---

## 🔧 SCHRITT 1: Backend auf Render.com deployen

### 1.1 Render Account erstellen
1. Gehe zu https://render.com
2. "Get Started for Free" klicken
3. Mit GitHub anmelden (empfohlen)

### 1.2 Blueprint deployen
1. Gehe zu https://dashboard.render.com/blueprints
2. Klicke "New Blueprint Instance"
3. Verbinde dein GitHub Repo `DiggAiHH/Sanad`
4. Render findet automatisch die `render.yaml` Datei
5. Klicke "Apply"

### 1.3 Warten auf Deployment
- PostgreSQL Datenbank wird erstellt (~2-3 Min)
- Backend wird gebaut und gestartet (~5-10 Min)
- URL wird angezeigt: `https://sanad-api.onrender.com`

### 1.4 Backend testen
Öffne im Browser:
```
https://sanad-api.onrender.com/health
https://sanad-api.onrender.com/docs
```

### 1.5 Demo-Login testen (API Docs)
In `/docs` -> POST `/api/v1/auth/login`:
```json
{
  "email": "admin@sanad.de",
  "password": "Admin123!"
}
```

Weitere Test-Accounts:
| Rolle  | Email           | Passwort   |
|--------|-----------------|------------|
| Admin  | admin@sanad.de  | Admin123!  |
| Arzt   | arzt@sanad.de   | Arzt123!   |
| MFA    | mfa@sanad.de    | Mfa123!    |
| Staff  | staff@sanad.de  | Staff123!  |

---

## 🌐 SCHRITT 2: Flutter Web Apps bauen

### 2.1 Flutter installieren (falls nicht vorhanden)
```bash
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable ~/.flutter
export PATH="$HOME/.flutter/bin:$PATH"
flutter precache --web

# Windows (PowerShell)
git clone https://github.com/flutter/flutter.git -b stable $env:USERPROFILE\.flutter
$env:PATH += ";$env:USERPROFILE\.flutter\bin"
flutter precache --web
```

### 2.2 Projekt vorbereiten
```bash
cd /workspaces/Sanad

# Melos installieren
dart pub global activate melos

# Dependencies holen
melos bootstrap

# Web Support für alle Apps aktivieren
cd apps/admin_app && flutter create --platforms=web . && cd ../..
cd apps/mfa_app && flutter create --platforms=web . && cd ../..
cd apps/staff_app && flutter create --platforms=web . && cd ../..
cd apps/patient_app && flutter create --platforms=web . && cd ../..
```

### 2.3 Apps bauen
```bash
# API URL setzen (ersetze mit deiner Render URL!)
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"

# Admin App
cd apps/admin_app
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
cd ../..

# MFA App
cd apps/mfa_app
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
cd ../..

# Staff App
cd apps/staff_app
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
cd ../..

# Patient App
cd apps/patient_app
flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL
cd ../..
```

---

## ☁️ SCHRITT 3: Cloudflare Pages deployen

### 3.1 Cloudflare Account erstellen
1. Gehe zu https://dash.cloudflare.com/sign-up
2. Kostenlosen Account erstellen
3. Email verifizieren

### 3.2 Admin App deployen
1. Gehe zu https://dash.cloudflare.com → "Workers & Pages"
2. Klicke "Create" → "Pages" → "Upload assets"
3. Projektname: `sanad-admin`
4. Ziehe den Ordner `apps/admin_app/build/web` hinein
5. Klicke "Deploy"
6. URL: `https://sanad-admin.pages.dev` ✅

### 3.3 Weitere Apps deployen (wiederholen)

| App     | Ordner                       | URL                           |
|---------|------------------------------|-------------------------------|
| Admin   | apps/admin_app/build/web     | sanad-admin.pages.dev        |
| MFA     | apps/mfa_app/build/web       | sanad-mfa.pages.dev          |
| Staff   | apps/staff_app/build/web     | sanad-staff.pages.dev        |
| Patient | apps/patient_app/build/web   | sanad-patient.pages.dev      |

---

## 🔗 FINALE URLs (nach Deployment)

| Service  | URL                                          |
|----------|----------------------------------------------|
| API      | https://sanad-api.onrender.com               |
| API Docs | https://sanad-api.onrender.com/docs          |
| Admin    | https://sanad-admin.pages.dev                |
| MFA      | https://sanad-mfa.pages.dev                  |
| Staff    | https://sanad-staff.pages.dev                |
| Patient  | https://sanad-patient.pages.dev              |

---

## 🔐 Test-Logins für alle Apps

| App      | Email           | Passwort   | Rolle                |
|----------|-----------------|------------|----------------------|
| Admin    | admin@sanad.de  | Admin123!  | Administrator        |
| MFA      | mfa@sanad.de    | Mfa123!    | Med. Fachangestellte |
| Staff    | arzt@sanad.de   | Arzt123!   | Arzt                 |
| Staff    | staff@sanad.de  | Staff123!  | Pflegepersonal       |
| Patient  | (Ticket-Nummer) | -          | Ticket eingeben      |

---

## ⚠️ Wichtige Hinweise

### Render Free Tier
- Spinnt nach 15 Min Inaktivität runter (erster Request dauert ~30s)
- 750h/Monat kostenlos (reicht für Demo)
- PostgreSQL: 256MB, 90 Tage Retention

### Cloudflare Pages Free Tier
- Unbegrenzte Bandbreite
- Automatisches HTTPS
- Keine Einschränkungen für statische Sites

### Bei Problemen
1. Backend-Logs in Render Dashboard prüfen
2. Browser Console (F12) für Frontend-Fehler
3. CORS: Stelle sicher, dass alle Cloudflare URLs in `render.yaml` → `CORS_ORIGINS` stehen

---

## 🔄 Updates deployen

### Backend aktualisieren
```bash
git add .
git commit -m "Backend update"
git push origin main
# Render deployed automatisch
```

### Frontend aktualisieren
1. Apps neu bauen (siehe Schritt 2.3)
2. In Cloudflare Dashboard → Project → "Create deployment"
3. Neuen Build-Ordner hochladen

---

## 📞 Support

Bei Fragen zum Deployment einfach fragen!
