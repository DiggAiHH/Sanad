# Deployment Guide for Sanad Healthcare System

## Overview

This guide explains how to deploy all four Sanad applications to Netlify.

## Prerequisites

- GitHub account with the Sanad repository
- Netlify account (free tier works)
- Node.js and npm installed locally for testing

## Deployment Options

### Option 1: Deploy via Netlify Dashboard (Recommended)

This is the easiest method for deploying all four applications.

#### Step 1: Create Netlify Sites

1. Log in to your [Netlify account](https://app.netlify.com/)
2. Click "Add new site" → "Import an existing project"
3. Choose "Deploy with GitHub"
4. Select the `DiggAiHH/Sanad` repository
5. You will need to create 4 separate sites, one for each app

#### Step 2: Configure Each Site

For each application, use these settings:

**Reception App:**
- Site name: `sanad-reception` (or your preference)
- Base directory: `apps/reception`
- Build command: `npm install && npm run build`
- Publish directory: `apps/reception/build`

**Doctor Portal:**
- Site name: `sanad-doctor`
- Base directory: `apps/doctor`
- Build command: `npm install && npm run build`
- Publish directory: `apps/doctor/build`

**Patient Portal:**
- Site name: `sanad-patient`
- Base directory: `apps/patient`
- Build command: `npm install && npm run build`
- Publish directory: `apps/patient/build`

**Master Dashboard:**
- Site name: `sanad-dashboard`
- Base directory: `apps/dashboard`
- Build command: `npm install && npm run build`
- Publish directory: `apps/dashboard/build`

#### Step 3: Deploy

Click "Deploy site" for each configuration. Netlify will:
1. Clone your repository
2. Install dependencies
3. Build the application
4. Deploy to a unique URL

### Option 2: Deploy via Netlify CLI

#### Step 1: Install Netlify CLI

```bash
npm install -g netlify-cli
```

#### Step 2: Login to Netlify

```bash
netlify login
```

#### Step 3: Deploy Each App

Navigate to the project root and run:

```bash
# Deploy Reception App
cd apps/reception
npm install
npm run build
netlify deploy --prod

# Deploy Doctor Portal
cd ../doctor
npm install
npm run build
netlify deploy --prod

# Deploy Patient Portal
cd ../patient
npm install
npm run build
netlify deploy --prod

# Deploy Master Dashboard
cd ../dashboard
npm install
npm run build
netlify deploy --prod
```

Follow the prompts to create new sites or link to existing ones.

### Option 3: Continuous Deployment

Set up automatic deployments when you push to GitHub:

1. In Netlify Dashboard, go to Site Settings → Build & Deploy
2. Configure build settings as shown in Option 1
3. Enable automatic deploys
4. Set the branch to watch (usually `main` or `master`)

Now every push to your repository will automatically deploy the apps!

## Environment Variables

If you need to configure API endpoints or other environment variables:

1. Go to Site Settings → Build & Deploy → Environment
2. Add variables:
   - `REACT_APP_API_URL` - Your backend API URL
   - Add any other environment-specific variables

These will be available during build time.

## Custom Domains

To use custom domains for your apps:

1. Go to Site Settings → Domain Management
2. Add your custom domain
3. Configure DNS settings as instructed by Netlify
4. Example setup:
   - `reception.yourdomain.com` → Reception App
   - `doctor.yourdomain.com` → Doctor Portal
   - `patient.yourdomain.com` → Patient Portal
   - `dashboard.yourdomain.com` → Master Dashboard

## Post-Deployment

After deployment, you'll receive URLs like:
- `https://sanad-reception.netlify.app`
- `https://sanad-doctor.netlify.app`
- `https://sanad-patient.netlify.app`
- `https://sanad-dashboard.netlify.app`

## Troubleshooting

### Build Fails

If the build fails:
1. Check the build logs in Netlify Dashboard
2. Ensure all dependencies are listed in `package.json`
3. Test the build locally: `npm run build`
4. Check for environment variable issues

### Page Not Found on Refresh

If you get 404 errors when refreshing pages:
1. Ensure the netlify configuration includes redirects
2. Add a `_redirects` file in the public folder:
   ```
   /*    /index.html   200
   ```

### Slow Initial Load

React apps can be slow on first load:
1. Enable Netlify's asset optimization
2. Consider code splitting
3. Use lazy loading for routes

## Security Considerations

1. **Environment Variables**: Never commit sensitive data
2. **HTTPS**: Netlify provides free SSL certificates
3. **Access Control**: Consider adding authentication
4. **CORS**: Configure properly if using a separate backend

## Monitoring

Monitor your deployments:
1. **Build Status**: Check in Netlify Dashboard
2. **Analytics**: Enable Netlify Analytics
3. **Error Tracking**: Consider integrating Sentry or similar
4. **Performance**: Use Lighthouse for performance audits

## Cost Considerations

Netlify Free Tier includes:
- 100 GB bandwidth/month
- 300 build minutes/month
- Unlimited sites
- HTTPS
- Continuous deployment

This should be sufficient for development and small-scale production use.

## Support

For issues:
1. Check [Netlify Documentation](https://docs.netlify.com/)
2. Visit [Netlify Community](https://answers.netlify.com/)
3. Open an issue in the Sanad repository

## Next Steps

After deployment:
1. Test all four applications thoroughly
2. Configure backend API connections
3. Set up monitoring and analytics
4. Configure custom domains
5. Implement authentication
6. Set up automated testing

---

**Happy Deploying! 🚀**
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
