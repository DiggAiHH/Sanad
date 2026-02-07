# Render.com Backend Deployment Guide

## ✅ Vorbereitung abgeschlossen
- [x] `render.yaml` Blueprint erstellt
- [x] CORS für Netlify-Domains konfiguriert (.netlify.app)
- [x] SEED_ON_STARTUP=true gesetzt (Demo-Daten automatisch)
- [x] JWT_SECRET_KEY Auto-Generierung aktiviert
- [x] PostgreSQL-Datenbank (256MB, Frankfurt) konfiguriert

---

## 🚀 Deployment-Schritte

### 1. Render Dashboard öffnen
```
https://dashboard.render.com
```
- Mit GitHub-Account anmelden (empfohlen) oder Email

### 2. Neues Blueprint-Deployment erstellen
1. **Button klicken:** "New" → "Blueprint"
2. **Repository verbinden:**
   - Organisation: `DiggAiHH`
   - Repository: `Sanad`
   - Branch: `main` (oder aktueller Branch)
3. **Blueprint-Datei:** `render.yaml` wird automatisch erkannt
4. **Service-Namen prüfen:**
   - Web Service: `sanad-api`
   - Database: `sanad-db`

### 3. Services Review & Deploy
Render zeigt Preview der Services:

**sanad-api (Web Service):**
- Plan: Free (0$/Monat, 512MB RAM, schlafend nach 15min Inaktivität)
- Region: Frankfurt (eu-central)
- Runtime: Python 3.11
- Build Command: `pip install -r backend/requirements.txt`
- Start Command: `cd backend && uvicorn app.main:app --host 0.0.0.0 --port $PORT`

**sanad-db (PostgreSQL):**
- Plan: Free (256MB Speicher, Frankfurt)
- Version: PostgreSQL 16
- Auto-Backup: Nein (Free-Plan)

**Button klicken:** "Apply" → Deployment startet

---

## 📊 Deployment-Prozess (ca. 5-8 Minuten)

### Phase 1: Database Creation (2-3 Minuten)
```
✓ PostgreSQL-Instanz wird erstellt
✓ DATABASE_URL wird generiert
✓ Verbindung wird getestet
```

### Phase 2: Web Service Build (3-5 Minuten)
```
✓ GitHub-Code wird geklont
✓ Python 3.11 wird installiert
✓ Dependencies (requirements.txt) werden installiert
✓ Build erfolgreich abgeschlossen
```

### Phase 3: Deploy & Start
```
✓ Container wird gestartet
✓ Uvicorn Server läuft auf Port $PORT
✓ Alembic Migrationen werden ausgeführt
✓ SEED_ON_STARTUP=true → Demo-Daten werden erstellt
✓ Health Check erfolgreich
```

---

## 🧪 Deployment verifizieren

### Backend-URL
Render generiert automatisch:
```
https://sanad-api.onrender.com
```

### Health Check
```bash
curl https://sanad-api.onrender.com/health
```
Erwartete Antwort:
```json
{
  "status": "healthy",
  "database": "connected",
  "version": "1.0.0"
}
```

### API-Dokumentation
```
https://sanad-api.onrender.com/docs
```
Zeigt interaktive Swagger-UI mit allen Endpoints.

### Test-Login
```bash
curl -X POST https://sanad-api.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@sanad.de",
    "password": "Admin123!"
  }'
```
Erwartete Antwort:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "...",
    "email": "admin@sanad.de",
    "role": "ADMIN"
  }
}
```

---

## 🔧 Environment Variables (automatisch gesetzt)

### Automatisch generiert:
- `DATABASE_URL` (von sanad-db)
- `JWT_SECRET_KEY` (32-Byte random string)
- `PORT` (dynamisch von Render)

### Bereits in render.yaml definiert:
- `CORS_ORIGINS` (Netlify-Domains)
- `SEED_ON_STARTUP=true`
- `ENV=production`

### Optional hinzufügen (später):
```
LOG_LEVEL=INFO
SENTRY_DSN=https://...  # Error Tracking
FIREBASE_PROJECT_ID=sanad-medical  # Für Push Notifications
```

---

## 📝 Nach dem Deployment

### 1. Backend-URL für Frontend kopieren
```bash
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"
```

### 2. Netlify-Apps neu deployen
Für jede der 4 Apps (admin/mfa/staff/patient):
1. Netlify Dashboard → Site Settings → Environment Variables
2. `API_BASE_URL` aktualisieren: `https://sanad-api.onrender.com/api/v1`
3. Trigger Redeploy → "Trigger deploy" → "Clear cache and deploy site"

### 3. Demo-Credentials testen
Siehe [CREDENTIALS.md](./CREDENTIALS.md) für alle Login-Daten:
- Admin: admin@sanad.de / Admin123!
- Arzt: arzt@sanad.de / Arzt123!
- MFA: mfa@sanad.de / Mfa123!
- Staff: staff@sanad.de / Staff123!
- Patient: patient@example.de / Patient123!

---

## 🐛 Troubleshooting

### Problem: "Build failed"
**Logs prüfen:**
```
Render Dashboard → sanad-api → Logs
```
Häufige Ursachen:
- requirements.txt fehlt Dependencies
- Python-Version inkompatibel (sollte 3.11 sein)

**Lösung:**
```bash
# Lokal testen
cd backend
pip install -r requirements.txt
python -m pytest tests/
```

### Problem: "Service unhealthy"
**Database-Connection prüfen:**
```bash
# Render Dashboard → sanad-db → Connections
# DATABASE_URL sollte gesetzt sein
```

**Logs prüfen:**
```
# Suche nach:
ERROR: Could not connect to database
sqlalchemy.exc.OperationalError
```

**Lösung:**
- Warte 2-3 Minuten (DB-Initialisierung dauert)
- Restart Service: Dashboard → "Manual Deploy" → "Clear build cache & deploy"

### Problem: "JWT_SECRET_KEY not set"
**Environment Variable prüfen:**
```
Render Dashboard → sanad-api → Environment → JWT_SECRET_KEY
```
Sollte automatisch generiert sein (32 Zeichen).

**Manuell setzen:**
```bash
# Python-generiert:
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Problem: "CORS error" im Frontend
**Backend CORS-Domains prüfen:**
```bash
curl https://sanad-api.onrender.com/docs
# Sollte ohne Error laden
```

**Netlify-Domain in CORS hinzufügen:**
```yaml
# render.yaml → envVars → CORS_ORIGINS
value: "https://sanad-admin.netlify.app,https://sanad-mfa.netlify.app,..."
```

---

## ⚠️ Free-Tier Limitierungen

### Render Free Plan:
- ✅ 512MB RAM (ausreichend für FastAPI)
- ✅ 750 Stunden/Monat (>31 Tage)
- ⚠️ **Schläft nach 15 Minuten Inaktivität** (Cold Start: 30-60 Sekunden)
- ⚠️ Öffentlich erreichbar (HTTPS inklusive)

### PostgreSQL Free Plan:
- ✅ 256MB Speicher (~500-1000 Datensätze)
- ✅ Frankfurt Region (niedrige Latenz EU)
- ⚠️ Keine automatischen Backups
- ⚠️ Wird nach 90 Tagen Inaktivität gelöscht

### Workaround für Cold Starts:
```bash
# Cron-Job (alle 10 Minuten ping)
curl https://sanad-api.onrender.com/health
```
Oder Uptime-Monitor nutzen: [UptimeRobot](https://uptimerobot.com) (kostenlos, 5min-Intervall)

---

## 📈 Monitoring & Logs

### Real-Time Logs
```
Render Dashboard → sanad-api → Logs → "Tail Logs"
```
Zeigt Live-Output von Uvicorn.

### Metrics (Free-Tier)
```
Render Dashboard → sanad-api → Metrics
```
- CPU-Auslastung
- Memory-Nutzung
- HTTP-Requests (letzten 48h)

### Datenbank-Monitoring
```
Render Dashboard → sanad-db → Metrics
```
- Verbindungen (max 20 für Free-Plan)
- Storage-Nutzung (max 256MB)

---

## 🎯 Nächste Schritte

1. **Backend deployen** (dieser Guide)
2. **Netlify-Apps konfigurieren** (siehe [NETLIFY_FIX.md](./NETLIFY_FIX.md))
3. **Credentials testen** (siehe [CREDENTIALS.md](./CREDENTIALS.md))
4. **Optional: Firebase FCM** (siehe [FIREBASE_CLARIFICATION.md](./FIREBASE_CLARIFICATION.md))

---

## 🔗 Nützliche Links

- [Render Dashboard](https://dashboard.render.com)
- [Render Docs - Python](https://render.com/docs/deploy-fastapi)
- [Render Free Tier Details](https://render.com/docs/free#free-web-services)
- [PostgreSQL on Render](https://render.com/docs/databases)
