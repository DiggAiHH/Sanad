# 🔧 Netlify Multi-App Deployment Fix

**Problem:** Nur Admin-App ist erreichbar, andere Apps (MFA/Staff/Patient) zeigen 404 oder Admin-Content.

**Root Cause:** Netlify-Sites nutzen alle das gleiche `publish` Directory oder haben kein `APP_NAME` gesetzt.

---

## ✅ Lösung: 4 separate Netlify-Sites mit korrekter Konfiguration

### Schritt 1: Netlify-Sites erstellen/prüfen

Du brauchst **4 unabhängige Sites** auf Netlify:

| Site Name | APP_NAME | Publish Directory | URL |
|-----------|----------|-------------------|-----|
| sanad-admin | `admin` | `build/web_deploy/admin` | sanad-admin.netlify.app |
| sanad-mfa | `mfa` | `build/web_deploy/mfa` | sanad-mfa.netlify.app |
| sanad-staff | `staff` | `build/web_deploy/staff` | sanad-staff.netlify.app |
| sanad-patient | `patient` | `build/web_deploy/patient` | sanad-patient.netlify.app |

---

### Schritt 2: Pro Site konfigurieren

#### In Netlify Dashboard für JEDE Site:

**Build settings:**
- Build command: `bash scripts/netlify_build.sh`
- Publish directory: `build/web_deploy/<APP_NAME>` ← **unterschiedlich pro Site!**
- Base directory: `/`

**Environment variables** (Site settings → Environment variables):

| Variable | Wert (pro Site anpassen) | Beispiel |
|----------|--------------------------|----------|
| `APP_NAME` | `admin`, `mfa`, `staff`, `patient` | **Admin-Site:** `admin` |
| `API_BASE_URL` | `https://sanad-api.onrender.com/api/v1` | Gleich für alle |
| `ENABLE_DEMO_MODE` | `true` | Gleich für alle |
| `ENABLE_ANALYTICS` | `false` | Optional |
| `ENABLE_PUSH_NOTIFICATIONS` | `false` | Optional (später `true`) |

---

### Schritt 3: Trigger Redeploy

**Option A: Via Netlify Dashboard**
1. Gehe zu jeder Site → **Deploys**
2. Klicke **Trigger deploy** → **Deploy site**
3. Warte bis Build durchläuft (~3-5 Min)

**Option B: Via CLI (empfohlen)**
```bash
# Terminal
cd /workspaces/Sanad

# Alle Apps lokal bauen
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"
bash scripts/build_web.sh

# Einzeln deployen
bash scripts/deploy_netlify.sh admin
bash scripts/deploy_netlify.sh mfa
bash scripts/deploy_netlify.sh staff
bash scripts/deploy_netlify.sh patient

# Oder alle auf einmal
bash scripts/deploy_netlify.sh all
```

---

## 🧪 Verification Checklist

Nach Deployment teste **jede Site einzeln**:

### ✅ Admin App
```
URL: https://sanad-admin.netlify.app
- [ ] Login-Screen erscheint (nicht 404)
- [ ] Titel: "Sanad Admin Dashboard"
- [ ] Login mit admin@sanad.de funktioniert
```

### ✅ MFA App
```
URL: https://sanad-mfa.netlify.app
- [ ] Zeigt MFA Home-Screen (nicht Admin-Dashboard!)
- [ ] "Check-in" Button sichtbar
- [ ] Login mit mfa@sanad.de funktioniert
```

### ✅ Staff App
```
URL: https://sanad-staff.netlify.app
- [ ] Zeigt Staff Home-Screen
- [ ] "Team Chat" Navigation sichtbar
- [ ] Login mit arzt@sanad.de funktioniert
```

### ✅ Patient App
```
URL: https://sanad-patient.netlify.app
- [ ] Zeigt Patient Welcome-Screen
- [ ] "Ticket-Nummer eingeben" sichtbar
- [ ] Kein Login nötig oder mit patient@example.de
```

---

## 🐛 Troubleshooting

### Problem: Alle Sites zeigen Admin-App

**Diagnose:**
```bash
# Check Build-Output lokal
ls -la build/web_deploy/
# Erwartung: 4 Ordner (admin, mfa, staff, patient)
# Wenn nur "admin" existiert → APP_NAME fehlt im Build
```

**Fix:**
1. Netlify Dashboard → Jede Site → Environment Variables
2. Sicherstellen `APP_NAME` ist gesetzt
3. Trigger Redeploy

---

### Problem: Build schlägt fehl "Flutter not found"

**Ursache:** Netlify Build-Image hat kein Flutter vorinstalliert

**Fix (2 Optionen):**

**Option A: Lokale Builds + CLI Deploy**
```bash
# Lokal bauen (erfordert Flutter)
bash scripts/build_web.sh

# Mit CLI deployen (kein Flutter auf Netlify nötig)
netlify deploy --dir=build/web_deploy/admin --prod --site=sanad-admin
netlify deploy --dir=build/web_deploy/mfa --prod --site=sanad-mfa
# etc.
```

**Option B: Netlify Build Plugin (fortgeschritten)**
```toml
# netlify.toml erweitern
[[plugins]]
  package = "netlify-plugin-flutter"
```

---

### Problem: "Network Error" beim API-Call

**Ursache:** CORS oder Backend offline

**Diagnose:**
```bash
# Backend Health Check
curl https://sanad-api.onrender.com/health

# Erwartung: {"status": "healthy"}
# Wenn Timeout → Render Backend schläft (Cold Start)
```

**Fix:**
- Warte 30-60s beim ersten Request
- Prüfe CORS in [backend/app/config.py](../backend/app/config.py):
  ```python
  NETLIFY_DOMAINS = [
      "https://sanad-admin.netlify.app",
      "https://sanad-mfa.netlify.app",
      "https://sanad-staff.netlify.app",
      "https://sanad-patient.netlify.app",
  ]
  ```

---

## 📋 Site-Konfiguration Template

Kopiere folgende Config für jede Site (angepasst):

### sanad-admin

```yaml
Build Command: bash scripts/netlify_build.sh
Publish Directory: build/web_deploy/admin
Environment:
  APP_NAME: admin
  API_BASE_URL: https://sanad-api.onrender.com/api/v1
  ENABLE_DEMO_MODE: true
```

### sanad-mfa

```yaml
Build Command: bash scripts/netlify_build.sh
Publish Directory: build/web_deploy/mfa
Environment:
  APP_NAME: mfa
  API_BASE_URL: https://sanad-api.onrender.com/api/v1
  ENABLE_DEMO_MODE: true
```

### sanad-staff

```yaml
Build Command: bash scripts/netlify_build.sh
Publish Directory: build/web_deploy/staff
Environment:
  APP_NAME: staff
  API_BASE_URL: https://sanad-api.onrender.com/api/v1
  ENABLE_DEMO_MODE: true
```

### sanad-patient

```yaml
Build Command: bash scripts/netlify_build.sh
Publish Directory: build/web_deploy/patient
Environment:
  APP_NAME: patient
  API_BASE_URL: https://sanad-api.onrender.com/api/v1
  ENABLE_DEMO_MODE: true
```

---

## 🚀 Quick Deploy Command

```bash
# Alle 4 Apps in einem Rutsch deployen
cd /workspaces/Sanad
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"

# Build
bash scripts/build_web.sh

# Deploy (setzt voraus: netlify CLI installiert + eingeloggt)
for app in admin mfa staff patient; do
  netlify deploy \
    --dir="build/web_deploy/$app" \
    --prod \
    --site="sanad-$app" \
    --message="Fix multi-app deployment"
done
```

---

**Letzte Aktualisierung:** 2026-01-14  
**Weitere Hilfe:** [docs/NETLIFY_DEPLOY.md](NETLIFY_DEPLOY.md)
