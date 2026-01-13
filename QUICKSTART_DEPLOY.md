# 🚀 SANAD - Schnellstart zum Testen

## Option A: Lokales Deployment (5 Min)

```bash
# 1. Im Terminal ausführen:
cd /workspaces/Sanad
docker compose up -d

# 2. Warte ~30 Sekunden, dann teste:
curl http://localhost:8000/health

# 3. Öffne im Browser:
# API Docs: http://localhost:8000/docs
```

**Test-Logins:**
| Email | Passwort | Rolle |
|-------|----------|-------|
| admin@sanad.de | Admin123! | Admin |
| arzt@sanad.de | Arzt123! | Arzt |
| mfa@sanad.de | Mfa123! | MFA |
| staff@sanad.de | Staff123! | Staff |

---

## Option B: Öffentliches Deployment (30 Min)

### Schritt 1: Backend auf Render.com

1. Gehe zu https://render.com → Sign up (kostenlos)
2. Dashboard → "New" → "Blueprint"
3. Verbinde `DiggAiHH/Sanad` Repository
4. Render findet `render.yaml` automatisch
5. Klicke "Apply" → Warte 5-10 Min

**Deine API URL:** `https://sanad-api.onrender.com`

### Schritt 2: Flutter Web Apps bauen

```bash
# Flutter installieren (falls nötig)
git clone https://github.com/flutter/flutter.git -b stable ~/.flutter
export PATH="$HOME/.flutter/bin:$PATH"

# Projekt vorbereiten
cd /workspaces/Sanad
dart pub global activate melos
melos bootstrap

# Web Support aktivieren
cd apps/admin_app && flutter create --platforms=web . && cd ../..
cd apps/mfa_app && flutter create --platforms=web . && cd ../..
cd apps/staff_app && flutter create --platforms=web . && cd ../..
cd apps/patient_app && flutter create --platforms=web . && cd ../..

# Bauen (mit deiner Render URL!)
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"

cd apps/admin_app && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL && cd ../..
cd apps/mfa_app && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL && cd ../..
cd apps/staff_app && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL && cd ../..
cd apps/patient_app && flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL && cd ../..
```

### Schritt 3: Cloudflare Pages deployen

1. Gehe zu https://dash.cloudflare.com → Sign up
2. "Workers & Pages" → "Create" → "Pages" → "Upload assets"
3. Für jede App:
   - Admin: Upload `apps/admin_app/build/web` → Name: `sanad-admin`
   - MFA: Upload `apps/mfa_app/build/web` → Name: `sanad-mfa`
   - Staff: Upload `apps/staff_app/build/web` → Name: `sanad-staff`
   - Patient: Upload `apps/patient_app/build/web` → Name: `sanad-patient`

---

## 🔗 Finale URLs

| Service | URL |
|---------|-----|
| API | https://sanad-api.onrender.com |
| API Docs | https://sanad-api.onrender.com/docs |
| Admin App | https://sanad-admin.pages.dev |
| MFA App | https://sanad-mfa.pages.dev |
| Staff App | https://sanad-staff.pages.dev |
| Patient App | https://sanad-patient.pages.dev |

---

## ⚡ Sofort loslegen

Wenn Docker läuft, kannst du sofort starten:

```bash
docker compose up -d
# Warte 30s
open http://localhost:8000/docs
```

Dann in `/docs`:
1. POST `/api/v1/auth/login` mit `{"email": "admin@sanad.de", "password": "Admin123!"}`
2. Kopiere den `access_token`
3. Klicke "Authorize" oben rechts → Füge Token ein
4. Teste andere Endpoints!
