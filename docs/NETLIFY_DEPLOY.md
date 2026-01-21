# 🚀 Sanad Netlify Deployment Guide

> **Ziel:** 4 Flutter Web Apps auf Netlify deployen  
> **Backend:** Bleibt auf Render (FastAPI kann nicht auf Netlify laufen)

---

## 📋 Voraussetzungen

1. **Netlify Account** - https://app.netlify.com
2. **Backend deployed** auf Render: `https://sanad-api.onrender.com`
3. **GitHub Repo** verbunden mit Netlify

---

## 🏗️ Deployment-Architektur

```
┌─────────────────────────────────────────────────────────┐
│                     NETLIFY CDN                         │
├─────────────┬─────────────┬─────────────┬──────────────┤
│ sanad-admin │  sanad-mfa  │ sanad-staff │ sanad-patient│
│   .netlify  │   .netlify  │   .netlify  │   .netlify   │
│    .app     │    .app     │    .app     │    .app      │
└──────┬──────┴──────┬──────┴──────┬──────┴───────┬──────┘
       │             │             │              │
       └─────────────┴──────┬──────┴──────────────┘
                            │
                            ▼
                 ┌────────────────────┐
                 │   Render Backend   │
                 │ sanad-api.onrender │
                 │     FastAPI        │
                 └─────────┬──────────┘
                           │
                           ▼
                 ┌────────────────────┐
                 │    PostgreSQL      │
                 │      (Neon)        │
                 └────────────────────┘
```

---

## 🔧 Setup: 4 Netlify Sites erstellen

### Schritt 1: Neues Site erstellen (4x wiederholen)

1. Netlify Dashboard → **Add new site** → **Import an existing project**
2. GitHub verbinden → `DiggAiHH/Sanad` auswählen
3. Build settings:

| Setting | Wert |
|---------|------|
| Base directory | `/` |
| Build command | `bash scripts/netlify_build.sh` |
| Publish directory | `build/web_deploy/admin` ← **pro App anpassen!** |

### Schritt 2: Environment Variables setzen

Für jede Site unter **Site settings → Environment variables**:

| Variable | Admin | MFA | Staff | Patient |
|----------|-------|-----|-------|---------|
| `APP_NAME` | `admin` | `mfa` | `staff` | `patient` |
| `API_BASE_URL` | `https://sanad-api.onrender.com/api/v1` | ← gleich | ← gleich | ← gleich |
| `ENABLE_DEMO_MODE` | `true` | `true` | `true` | `true` |
| `ENABLE_ANALYTICS` | `false` | `false` | `false` | `false` |
| `ENABLE_PUSH_NOTIFICATIONS` | `false` | `false` | `false` | `false` |

### Schritt 3: Publish Directory pro App

| Site Name | APP_NAME | Publish Directory |
|-----------|----------|-------------------|
| sanad-admin | `admin` | `build/web_deploy/admin` |
| sanad-mfa | `mfa` | `build/web_deploy/mfa` |
| sanad-staff | `staff` | `build/web_deploy/staff` |
| sanad-patient | `patient` | `build/web_deploy/patient` |

---

## 🖥️ Alternative: CLI Deployment

Falls Netlify Build-Image kein Flutter hat, lokal bauen und hochladen:

```bash
# 1. Netlify CLI installieren
npm install -g netlify-cli

# 2. Einloggen
netlify login

# 3. Alle Apps lokal bauen
export API_BASE_URL="https://sanad-api.onrender.com/api/v1"
bash scripts/build_web.sh

# 4. Jede App deployen
netlify deploy --dir=build/web_deploy/admin --prod --site=sanad-admin
netlify deploy --dir=build/web_deploy/mfa --prod --site=sanad-mfa
netlify deploy --dir=build/web_deploy/staff --prod --site=sanad-staff
netlify deploy --dir=build/web_deploy/patient --prod --site=sanad-patient
```

---

## 🔐 Backend CORS konfigurieren

Das Backend muss die Netlify-Domains erlauben. In `.env`:

```bash
CORS_ORIGINS=https://sanad-admin.netlify.app,https://sanad-mfa.netlify.app,https://sanad-staff.netlify.app,https://sanad-patient.netlify.app
```

Oder die Standard-Netlify-Domains sind bereits in `config.py` eingetragen.

---

## ⚠️ Bekannte Einschränkungen

| Feature | Netlify Status | Workaround |
|---------|----------------|------------|
| NFC Check-in | ⚠️ Web = Kein NFC | Mobile App notwendig |
| Push Notifications | ⚠️ Web Push möglich | FCM Web konfigurieren |
| QR Scanner | ✅ Funktioniert | Kamera-Berechtigung nötig |
| WebSocket | ✅ Funktioniert | Render backend unterstützt WS |

---

## 🧪 Smoke Test nach Deploy

1. **Admin App** - `https://sanad-admin.netlify.app`
   - [ ] Login-Screen lädt
   - [ ] Demo-Login funktioniert
   - [ ] Dashboard zeigt Statistiken

2. **MFA App** - `https://sanad-mfa.netlify.app`
   - [ ] Home-Screen lädt
   - [ ] Queue-Ansicht funktioniert
   - [ ] QR-Scanner öffnet Kamera

3. **Staff App** - `https://sanad-staff.netlify.app`
   - [ ] Chat-Liste lädt
   - [ ] Team-Übersicht zeigt Mitarbeiter

4. **Patient App** - `https://sanad-patient.netlify.app`
   - [ ] Willkommen-Screen lädt
   - [ ] Ticket-Eingabe funktioniert
   - [ ] Wartezeit wird angezeigt

---

## 🔄 Continuous Deployment

Nach der Ersteinrichtung:
- Jeder Push auf `main` triggert automatisch alle 4 Builds
- Deploy-Previews für Pull Requests aktivieren

---

## 📊 Monitoring

- **Netlify Analytics** - Traffic & Performance
- **Backend Logs** - Render Dashboard
- **Error Tracking** - Sentry (optional, noch nicht integriert)

---

## 🆘 Troubleshooting

### Build schlägt fehl: "Flutter not found"
→ Netlify Build-Image hat kein Flutter vorinstalliert.  
→ Lösung: Lokale Builds + `netlify deploy --dir=...`

### CORS-Fehler im Browser
→ Backend CORS_ORIGINS prüfen  
→ Netlify-Domain muss exakt matchen (mit `https://`)

### App lädt, aber API-Calls scheitern
→ `API_BASE_URL` Environment Variable prüfen  
→ Backend auf Render ist evtl. im Sleep-Modus (erster Request dauert ~30s)

### SPA-Routing funktioniert nicht (404 auf Refresh)
→ `netlify.toml` prüfen: Redirect `/* → /index.html` muss aktiv sein

---

## 📁 Dateistruktur

```
/workspaces/Sanad/
├── netlify.toml                    # Netlify Konfiguration
├── scripts/
│   ├── netlify_build.sh            # Build-Script für Netlify
│   └── build_web.sh                # Lokales Build-Script
└── build/
    └── web_deploy/                 # Build-Output
        ├── admin/
        ├── mfa/
        ├── staff/
        └── patient/
```

---

**Letzte Aktualisierung:** 2026-01-14
