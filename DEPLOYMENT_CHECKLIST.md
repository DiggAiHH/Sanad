# Netlify Deployment Checklist

## Pre-Deployment Steps

### ✅ Code Quality
- [x] All apps build successfully without errors
- [x] Error boundaries added to all apps
- [x] Removed unused dependencies
- [x] Added _redirects files for SPA routing
- [x] Environment variable templates created

### ✅ Configuration Files
- [x] netlify-reception.toml configured
- [x] netlify-doctor.toml configured
- [x] netlify-patient.toml configured
- [x] netlify-dashboard.toml configured

## Deployment Instructions

### Option 1: Deploy via Netlify Dashboard (Recommended)

#### 1. Create 4 Sites on Netlify

Log in to [Netlify](https://app.netlify.com/) and create 4 new sites:

**Site 1: Reception App**
- Site name: `sanad-reception` (or your choice)
- Build settings:
  - Base directory: `apps/reception`
  - Build command: `npm install && npm run build`
  - Publish directory: `apps/reception/build`

**Site 2: Doctor Portal**
- Site name: `sanad-doctor`
- Build settings:
  - Base directory: `apps/doctor`
  - Build command: `npm install && npm run build`
  - Publish directory: `apps/doctor/build`

**Site 3: Patient Portal**
- Site name: `sanad-patient`
- Build settings:
  - Base directory: `apps/patient`
  - Build command: `npm install && npm run build`
  - Publish directory: `apps/patient/build`

**Site 4: Master Dashboard**
- Site name: `sanad-dashboard`
- Build settings:
  - Base directory: `apps/dashboard`
  - Build command: `npm install && npm run build`
  - Publish directory: `apps/dashboard/build`

#### 2. Configure Environment Variables (Optional)

For each site in Netlify Dashboard:
1. Go to Site Settings → Build & deploy → Environment
2. Add environment variables if needed:
   - `REACT_APP_API_URL` - Your backend API URL

#### 3. Deploy

Click "Deploy site" for each configuration. Netlify will automatically:
1. Clone your repository
2. Install dependencies
3. Build the application
4. Deploy to production

### Option 2: Deploy via Netlify CLI

```bash
# Install Netlify CLI globally
npm install -g netlify-cli

# Login to Netlify
netlify login

# Deploy each app
cd apps/reception
npm install
npm run build
netlify deploy --prod

cd ../doctor
npm install
npm run build
netlify deploy --prod

cd ../patient
npm install
npm run build
netlify deploy --prod

cd ../dashboard
npm install
npm run build
netlify deploy --prod
```

## Post-Deployment Verification

### Test Each Application

1. **Reception App**: Test QR/NFC simulation
2. **Doctor Portal**: Test patient queue management
3. **Patient Portal**: Test QR code generation
4. **Master Dashboard**: Test system overview

### Check Performance

- Run Lighthouse audit on each app
- Test on mobile devices
- Verify all links and navigation work

### Security

- Ensure HTTPS is enabled (automatic with Netlify)
- Test CORS if using external APIs
- Verify environment variables are not exposed

## Troubleshooting

### Build Fails
- Check build logs in Netlify dashboard
- Ensure all dependencies are in package.json
- Test build locally: `npm run build`

### 404 Errors on Refresh
- Verify _redirects file is in public folder
- Should contain: `/*    /index.html   200`

### Environment Variables Not Working
- Ensure variables start with `REACT_APP_`
- Rebuild after adding/changing variables
- Variables are only available at build time

## Custom Domains (Optional)

To use custom domains:
1. Go to Site Settings → Domain Management
2. Add your custom domain
3. Configure DNS as instructed
4. Wait for SSL certificate (automatic)

Example setup:
- reception.yourdomain.com → Reception App
- doctor.yourdomain.com → Doctor Portal
- patient.yourdomain.com → Patient Portal
- dashboard.yourdomain.com → Master Dashboard

## Monitoring

After deployment:
1. Enable Netlify Analytics (optional)
2. Set up error tracking (e.g., Sentry)
3. Monitor build times and deployment logs
4. Check bandwidth usage

## Continuous Deployment

To enable automatic deployments:
1. Go to Site Settings → Build & deploy
2. Configure build hooks or GitHub integration
3. Set branch to watch (usually `main`)
4. Every push will trigger automatic deployment

## Support

- Netlify Docs: https://docs.netlify.com/
- Netlify Community: https://answers.netlify.com/
- Project Issues: https://github.com/DiggAiHH/Sanad/issues

## Summary

✅ **All 4 applications are production-ready and configured for Netlify deployment!**

The applications include:
- Error boundaries for graceful error handling
- SPA routing configuration
- Environment variable support
- Optimized production builds
- Clean, maintainable code

**Next Steps:**
1. Push all changes to GitHub
2. Create 4 sites on Netlify
3. Configure each site with the settings above
4. Deploy and test!
