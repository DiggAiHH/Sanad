# Sanad Healthcare Reception System

A comprehensive healthcare reception management system with **zero human interaction** featuring NFC and QR code technology. Built with React and deployable on Netlify.

## 🏥 System Overview

Sanad consists of four integrated React applications:

### 1. 📱 Reception App
- **Automated patient check-in**
- QR code scanning
- NFC card reading
- Zero human interaction design
- Real-time patient queue display

### 2. 👨‍⚕️ Doctor/Worker Portal
- Patient queue management
- Current patient details
- Medical notes and records
- Appointment management
- Status tracking (waiting, in-progress, completed)

### 3. 👤 Patient Portal
- Personal health dashboard
- Appointment booking and management
- QR code generation for check-in
- Medical records access
- Blood type and health information

### 4. ⚙️ Master Dashboard
- System-wide management
- Staff management
- Device monitoring (kiosks, terminals)
- Analytics and reporting
- System settings and configuration
- Real-time activity monitoring

## 🚀 Technology Stack

- **Frontend:** React 19
- **Styling:** CSS3 with gradients and animations
- **QR Codes:** QR code generation and scanning
- **NFC:** NFC integration ready
- **Deployment:** Netlify
- **Architecture:** Monorepo structure

## 📁 Project Structure

```
sanad/
├── apps/
│   ├── reception/       # Reception kiosk application
│   ├── doctor/          # Doctor/staff portal
│   ├── patient/         # Patient portal
│   └── dashboard/       # Master management dashboard
├── packages/
│   └── shared/          # Shared utilities and components
├── netlify-*.toml       # Netlify configuration files
└── package.json         # Root package configuration
```

## 🛠️ Installation & Setup

### Prerequisites
- Node.js 20.x or higher
- npm 10.x or higher

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/DiggAiHH/Sanad.git
cd Sanad
```

2. Build all applications:
```bash
./build-all.sh
```

Or install dependencies manually for each app:
```bash
cd apps/reception && npm install && npm run build
cd ../doctor && npm install && npm run build
cd ../patient && npm install && npm run build
cd ../dashboard && npm install && npm run build
```
cd ../patient && npm install
cd ../dashboard && npm install
cd ../..
```

## 🏃 Running the Applications

### Run individual apps in development mode:

```bash
# Reception App (Port 3000)
npm run dev:reception

# Doctor Portal (Port 3000)
npm run dev:doctor

# Patient Portal (Port 3000)
npm run dev:patient

# Master Dashboard (Port 3000)
npm run dev:dashboard
```

### Build all applications:

```bash
npm run build:all
```

### Build individual apps:

```bash
npm run build:reception
npm run build:doctor
npm run build:patient
npm run build:dashboard
```

## 🌐 Production Deployment to Netlify

**Ready to deploy!** All applications are production-ready with:
- ✅ Error boundaries for graceful error handling
- ✅ SPA routing configured
- ✅ Environment variable support
- ✅ Optimized production builds

### Quick Deploy (Recommended)

See **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** for complete step-by-step instructions.

#### Method 1: Netlify Dashboard

1. Create 4 new sites on Netlify
2. For each site, configure:

**Reception App**
   - Base directory: `apps/reception`
   - Build command: `npm install && npm run build`
   - Publish directory: `apps/reception/build`

**Doctor Portal**
   - Base directory: `apps/doctor`
   - Build command: `npm install && npm run build`
   - Publish directory: `apps/doctor/build`

**Patient Portal**
   - Base directory: `apps/patient`
   - Build command: `npm install && npm run build`
   - Publish directory: `apps/patient/build`

**Master Dashboard**
   - Base directory: `apps/dashboard`
   - Build command: `npm install && npm run build`
   - Publish directory: `apps/dashboard/build`

#### Method 2: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Deploy each app
cd apps/reception && npm install && npm run build && netlify deploy --prod
cd ../doctor && npm install && npm run build && netlify deploy --prod
cd ../patient && npm install && npm run build && netlify deploy --prod
cd ../dashboard && npm install && npm run build && netlify deploy --prod
```

### Environment Variables

Each app includes an `.env.example` template. Copy to `.env.local` and configure:

```bash
# Example for all apps
REACT_APP_API_URL=https://your-api-url.com
```

In Netlify Dashboard, add these under Site Settings → Environment variables.

### Recommended Site Names:
- `sanad-reception` - Reception kiosk
- `sanad-doctor` - Doctor portal
- `sanad-patient` - Patient portal  
- `sanad-dashboard` - Master dashboard

## ✨ Features

### 🔒 Production Ready
- ✅ **Error Boundaries** - Graceful error handling in all apps
- ✅ **SPA Routing** - Proper _redirects configuration for Netlify
- ✅ **Environment Variables** - Template files for easy configuration
- ✅ **Optimized Builds** - Production-ready, minified bundles
- ✅ **Clean Code** - No unused dependencies, ESLint compliant
- ✅ **Build Script** - Automated `build-all.sh` for all apps

### Reception App Features
- ✅ QR code scanning for instant check-in
- ✅ NFC card reading support
- ✅ Automatic patient verification
- ✅ Real-time check-in status
- ✅ Recent check-ins display
- ✅ Zero human interaction workflow

### Doctor Portal Features
- ✅ Patient queue visualization
- ✅ Priority-based patient sorting
- ✅ Current patient details view
- ✅ Medical notes interface
- ✅ Status management (waiting, in-progress, completed)
- ✅ Call next patient functionality

### Patient Portal Features
- ✅ Personal health dashboard
- ✅ Upcoming appointments view
- ✅ QR code generation for check-in
- ✅ Medical records access
- ✅ Appointment booking interface
- ✅ Blood type and health info display

### Master Dashboard Features
- ✅ System overview with key metrics
- ✅ Staff management and monitoring
- ✅ Device status tracking
- ✅ Analytics and reporting
- ✅ System settings configuration
- ✅ Real-time activity feed
- ✅ Security settings

## 🔐 Security Features

- Two-factor authentication support
- Session timeout configuration
- Secure data handling
- Role-based access control ready

## 📱 Responsive Design

All applications are fully responsive and work on:
- Desktop computers
- Tablets
- Mobile devices
- Kiosk displays

## 🎨 Customization

Each app has its own unique color scheme:
- **Reception:** Purple gradient (#667eea → #764ba2)
- **Doctor:** Blue gradient (#2193b0 → #6dd5ed)
- **Patient:** Pink gradient (#f093fb → #f5576c)
- **Dashboard:** Navy gradient (#1e3c72 → #2a5298)

## 🔧 Configuration

Shared configuration can be found in `packages/shared/src/config.js`:
- API endpoints
- NFC settings
- QR code settings
- Auto check-in configuration

## 📄 License

MIT License

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, please open an issue in the GitHub repository.

---

**Built with ❤️ for modern healthcare management**