# 🚂 Railway Backend Deployment Guide

## Prerequisites
- GitHub Account (Repo: DiggAiHH/Sanad)
- Railway Account (https://railway.app)

---

## Step 1: Create Railway Project

1. Go to [railway.app](https://railway.app) and login
2. Click **"New Project"** → **"Deploy from GitHub Repo"**
3. Select `DiggAiHH/Sanad` repository
4. Click **"Add service"** to configure

---

## Step 2: Add PostgreSQL Database

1. In your project, click **"+ New"** → **"Database"** → **"PostgreSQL"**
2. Railway auto-generates `DATABASE_URL` — no config needed
3. Wait for database to provision (~30 seconds)

---

## Step 3: Configure Backend Service

1. Click **"+ New"** → **"GitHub Repo"** → select `DiggAiHH/Sanad`
2. **Settings → General:**
   - Root Directory: `backend/`
   - Build: Leave on Dockerfile (auto-detected)
3. **Settings → Networking:**
   - Click "Generate Domain" to get public URL
   - Example: `sanad-api-production.up.railway.app`

---

## Step 4: Environment Variables

In your backend service, go to **Variables** tab and add:

| Variable | Value | Required |
|----------|-------|----------|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` (Railway reference) | ✅ |
| `JWT_SECRET_KEY` | Generate 32+ char secret: `openssl rand -base64 32` | ✅ |
| `CORS_ORIGINS` | `https://sanad-admin-diggaihh.netlify.app,https://sanad-mfa-diggaihh.netlify.app,https://sanad-staff-diggaihh.netlify.app,https://sanad-patient-diggaihh.netlify.app` | ✅ |
| `DEBUG` | `false` | ❌ |
| `SEED_ON_STARTUP` | `true` | ❌ |
| `ENABLE_HSTS` | `true` | ❌ |

**Note:** Railway auto-links the PostgreSQL reference (`${{Postgres.DATABASE_URL}}`).

---

## Step 5: Deploy & Verify

1. Railway auto-deploys on push to `main`
2. Check **Deployments** tab for build logs
3. Once deployed, verify:
   ```bash
   curl https://<your-railway-domain>/health
   # Expected: {"status":"healthy","version":"1.0.0"}
   ```
4. View API docs: `https://<your-railway-domain>/docs`

---

## Step 6: Run Alembic Migrations (if needed)

Railway runs the Dockerfile which starts uvicorn directly.
Migrations should run via `init_db()` on startup, but if you need manual:

1. Go to your backend service → **Settings** → **Start command**
2. Temporarily change to:
   ```bash
   alembic upgrade head && uvicorn app.main:app --host 0.0.0.0 --port $PORT
   ```
3. Or use Railway CLI:
   ```bash
   railway run alembic upgrade head
   ```

---

## Step 7: Update Netlify Frontend

After Railway backend is live, update each Netlify site:

1. Go to Netlify Dashboard → Site settings → Environment variables
2. Set/Update:
   - `API_BASE_URL` = `https://<your-railway-domain>/api/v1`
3. Trigger redeploy: **Deploys** → **Trigger deploy** → **Deploy site**

---

## Troubleshooting

### Build Fails
- Check Railway logs: service → **Deployments** → click failed deploy
- Verify Dockerfile path is `backend/Dockerfile`
- Root directory must be `backend/`

### Database Connection Error
- Ensure `DATABASE_URL` references PostgreSQL service correctly
- Railway format: `postgresql://user:pass@host:port/db` (auto-converted to asyncpg in code)

### CORS Errors
- Add your exact Netlify URLs to `CORS_ORIGINS`
- Include trailing domains without trailing slash

### Health Check Fails
- Endpoint: `/health`
- Ensure app starts on `$PORT` (Railway injects this)

---

## Live URLs (after deployment)

| Service | URL |
|---------|-----|
| Backend API | `https://<name>.up.railway.app` |
| API Docs | `https://<name>.up.railway.app/docs` |
| Health Check | `https://<name>.up.railway.app/health` |

---

## Demo Credentials (after SEED_ON_STARTUP=true)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@sanad.de | Admin123! |
| Arzt | arzt@sanad.de | Arzt123! |
| MFA | mfa@sanad.de | Mfa123! |
| Staff | staff@sanad.de | Staff123! |
