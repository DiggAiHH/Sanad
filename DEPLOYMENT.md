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
