# Netlify Deployment Instructions

## Quick Deploy Guide

Since I cannot directly access your Netlify account, please follow these steps to deploy the 4 applications:

## Option 1: Deploy via Netlify Dashboard (Easiest)

### Step 1: Log in to Netlify
1. Go to https://app.netlify.com/
2. Log in with your account (or create one if needed)

### Step 2: Deploy Each Application

You'll create 4 separate sites on Netlify. For each app:

#### Reception App
1. Click "Add new site" → "Import an existing project"
2. Connect to your GitHub repository: `DiggAiHH/Sanad`
3. Select branch: `copilot/add-online-reception-apps`
4. Configure build settings:
   - **Base directory:** `apps/reception`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `apps/reception/build`
5. Click "Deploy site"
6. Suggested site name: `sanad-reception`

#### Doctor Portal
1. Click "Add new site" → "Import an existing project"
2. Connect to your GitHub repository: `DiggAiHH/Sanad`
3. Select branch: `copilot/add-online-reception-apps`
4. Configure build settings:
   - **Base directory:** `apps/doctor`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `apps/doctor/build`
5. Click "Deploy site"
6. Suggested site name: `sanad-doctor`

#### Patient Portal
1. Click "Add new site" → "Import an existing project"
2. Connect to your GitHub repository: `DiggAiHH/Sanad`
3. Select branch: `copilot/add-online-reception-apps`
4. Configure build settings:
   - **Base directory:** `apps/patient`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `apps/patient/build`
5. Click "Deploy site"
6. Suggested site name: `sanad-patient`

#### Master Dashboard
1. Click "Add new site" → "Import an existing project"
2. Connect to your GitHub repository: `DiggAiHH/Sanad`
3. Select branch: `copilot/add-online-reception-apps`
4. Configure build settings:
   - **Base directory:** `apps/dashboard`
   - **Build command:** `npm install && npm run build`
   - **Publish directory:** `apps/dashboard/build`
5. Click "Deploy site"
6. Suggested site name: `sanad-dashboard`

### Step 3: Wait for Builds
Each site will take 2-5 minutes to build and deploy. You'll see the build progress in real-time.

### Step 4: Access Your Apps
Once deployed, you'll get URLs like:
- `https://sanad-reception.netlify.app`
- `https://sanad-doctor.netlify.app`
- `https://sanad-patient.netlify.app`
- `https://sanad-dashboard.netlify.app`

---

## Option 2: Deploy via Netlify CLI

If you prefer using the command line:

### Step 1: Install Netlify CLI
```bash
npm install -g netlify-cli
```

### Step 2: Login to Netlify
```bash
netlify login
```
This will open your browser to authenticate.

### Step 3: Deploy Reception App
```bash
cd /home/runner/work/Sanad/Sanad/apps/reception
npm install
npm run build
netlify deploy --prod
```
Follow the prompts:
- Create a new site or link to existing
- Set publish directory to: `build`
- Confirm deployment

### Step 4: Deploy Doctor Portal
```bash
cd /home/runner/work/Sanad/Sanad/apps/doctor
npm install
npm run build
netlify deploy --prod
```

### Step 5: Deploy Patient Portal
```bash
cd /home/runner/work/Sanad/Sanad/apps/patient
npm install
npm run build
netlify deploy --prod
```

### Step 6: Deploy Master Dashboard
```bash
cd /home/runner/work/Sanad/Sanad/apps/dashboard
npm install
npm run build
netlify deploy --prod
```

---

## Environment Variables (Optional)

If you need to configure API URLs or other settings:

1. Go to each site in Netlify Dashboard
2. Navigate to: Site settings → Build & deploy → Environment
3. Add variables:
   ```
   REACT_APP_API_URL=https://your-api-url.com
   ```
4. Redeploy the site

---

## Troubleshooting

### Build Fails
- Check the build logs in Netlify Dashboard
- Ensure all dependencies are in package.json
- Try building locally first: `npm run build`

### 404 on Page Refresh
- Should not happen - `_redirects` files are already in place
- If it does, check that `_redirects` file is in the build output

### Slow Build Times
- Normal for first build (installs all dependencies)
- Subsequent builds are faster (uses cache)

---

## Custom Domains (Optional)

To use custom domains:
1. Go to Site settings → Domain management
2. Add your custom domain
3. Configure DNS as instructed

Example setup:
- `reception.yourdomain.com`
- `doctor.yourdomain.com`
- `patient.yourdomain.com`
- `dashboard.yourdomain.com`

---

## Next Steps After Deployment

1. ✅ Test each application
2. ✅ Check all features work
3. ✅ Verify QR codes display correctly
4. ✅ Test on mobile devices
5. ✅ Set up custom domains (optional)
6. ✅ Configure backend API when ready

---

**Need help?** Check DEPLOYMENT_CHECKLIST.md for more detailed instructions.
