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

### Installation

1. Clone the repository:
```bash
git clone https://github.com/DiggAiHH/Sanad.git
cd Sanad
```

2. Install dependencies for all apps:
```bash
npm install
cd apps/reception && npm install
cd ../doctor && npm install
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

## 🌐 Deployment to Netlify

Each application can be deployed separately to Netlify:

### Method 1: Netlify CLI

```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy Reception App
netlify deploy --config=netlify-reception.toml --prod

# Deploy Doctor Portal
netlify deploy --config=netlify-doctor.toml --prod

# Deploy Patient Portal
netlify deploy --config=netlify-patient.toml --prod

# Deploy Master Dashboard
netlify deploy --config=netlify-dashboard.toml --prod
```

### Method 2: Netlify Dashboard

1. Create 4 new sites on Netlify
2. For each site:
   - Connect your GitHub repository
   - Set build command: `npm run build`
   - Set publish directory: `apps/[app-name]/build`
   - Deploy!

### Recommended Site Names:
- `sanad-reception` - Reception kiosk
- `sanad-doctor` - Doctor portal
- `sanad-patient` - Patient portal  
- `sanad-dashboard` - Master dashboard

## ✨ Features

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