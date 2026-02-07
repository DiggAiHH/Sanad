# 🔐 Sanad Demo-Credentials Cheatsheet

**Letzte Aktualisierung:** 2026-01-14  
**Backend:** [https://sanad-api.onrender.com](https://sanad-api.onrender.com) (nach Render-Deployment)

---

## 📱 Login-Daten pro Rolle

### 🔧 Admin Dashboard
**URL:** [https://sanad-admin.netlify.app](https://sanad-admin.netlify.app)  
**Email:** `admin@sanad.de`  
**Passwort:** `Admin123!`  
**Zugriff:** God Mode - Alle Features

---

### 💉 Arzt/Doctor
**URL:** [https://sanad-staff.netlify.app](https://sanad-staff.netlify.app)  
**Email:** `arzt@sanad.de`  
**Passwort:** `Arzt123!`  
**Zugriff:** Patientenübersicht, Team-Chat, Aufgaben

---

### 🩺 MFA (Medizinische Fachangestellte)
**URL:** [https://sanad-mfa.netlify.app](https://sanad-mfa.netlify.app)  
**Email:** `mfa@sanad.de`  
**Passwort:** `Mfa123!`  
**Zugriff:** Ticket-Vergabe, QR/NFC Check-in, Warteschlange

---

### 👨‍⚕️ Staff/Pflegepersonal
**URL:** [https://sanad-staff.netlify.app](https://sanad-staff.netlify.app)  
**Email:** `staff@sanad.de`  
**Passwort:** `Staff123!`  
**Zugriff:** Team-Chat, Aufgabenverwaltung, Patientenübersicht

---

### 🤒 Patient (Test-User)
**URL:** [https://sanad-patient.netlify.app](https://sanad-patient.netlify.app)  
**Email:** `patient@example.de`  
**Passwort:** `Patient123!`  
**Zugriff:** Wartezeit-Anzeige, Ticket-Status, Gesundheitsinfos

---

## 🧪 Automatisch generierte Test-Daten

Nach Backend-Start (`SEED_ON_STARTUP=true`) sind folgende Demo-Daten verfügbar:

### Praxis
- **Name:** Praxis Dr. Müller
- **Adresse:** Hauptstraße 42, 80331 München
- **Öffnungszeiten:** Mo-Fr: 08:00-18:00, Sa: 09:00-12:00

### Warteschlangen
- **Queue Name:** Allgemeinmedizin
- **Max Tickets:** 50 pro Tag
- **Ø Wartezeit:** 15 Minuten

### Sample Tickets (4 Stück)
1. **A-001** - Max Mustermann - Wartet
2. **A-002** - Lisa Schmidt - In Behandlung
3. **A-003** - Peter Wagner - Abgeschlossen
4. **B-001** - Maria Bauer - Hohe Priorität

### Aufgaben (3 Stück)
1. **Rezept ausstellen** - Dr. Müller zugewiesen
2. **Blutabnahme vorbereiten** - Anna Schmidt (MFA)
3. **Rückruf Patient** - Peter Meyer (Staff)

### Team-Chat
- **Raum:** "Team Allgemeinmedizin"
- **Teilnehmer:** Dr. Müller, Anna Schmidt, Peter Meyer
- **5 Demo-Nachrichten** bereits vorhanden

---

## 🚀 Quick Test-Flow

### 1. Admin-Login
```
1. Öffne [https://sanad-admin.netlify.app](https://sanad-admin.netlify.app)
2. Login: admin@sanad.de / Admin123!
3. Siehst du Dashboard mit 4 Tickets?
   ✅ Backend läuft
   ❌ API_BASE_URL falsch oder Backend offline
```

### 2. MFA Check-in
```
1. Öffne [https://sanad-mfa.netlify.app](https://sanad-mfa.netlify.app)
2. Login: mfa@sanad.de / Mfa123!
3. Klick auf "Check-in" → Manuell
4. Erstelle neues Ticket
   ✅ Ticket erscheint in Queue
```

### 3. Arzt Patientenübersicht
```
1. Öffne https://sanad-staff.netlify.app
2. Login: arzt@sanad.de / Arzt123!
3. Siehst du aktuelle Tickets?
   ✅ WebSocket verbindet
   ❌ CORS-Problem oder WebSocket blockiert
```

### 4. Patient Wartezeit
```
1. Öffne https://sanad-patient.netlify.app
2. (Kein Login nötig oder patient@example.de)
3. Gib Ticket-Nummer ein: A-001
4. Siehst du Status?
   ✅ Public API funktioniert
```

---

## ⚠️ Troubleshooting

### "Falsches Passwort" trotz korrekter Eingabe
- **Ursache:** Backend nicht deployed oder falsche `API_BASE_URL`
- **Lösung:** 
  ```bash
  # Backend Health Check
  curl https://sanad-api.onrender.com/health
  # Erwartung: {"status": "healthy"}
  ```

### "Network Error" beim Login
- **Ursache:** CORS blockiert Request oder Backend schläft (Render Free Tier)
- **Lösung:** 
  - Warte 30-60s beim ersten Request (Cold Start)
  - Prüfe Browser DevTools → Network → CORS-Fehler?

### Keine Demo-Daten sichtbar
- **Ursache:** `SEED_ON_STARTUP=false` oder DB-Fehler
- **Lösung:**
  ```bash
  # Backend Logs auf Render prüfen
  # Erwartung: "🌱 Demo-Daten geladen"
  ```

---

## 🔄 Credentials zurücksetzen

Falls du Passwörter ändern musst:

1. **Backend:**
   ```bash
   cd /workspaces/Sanad/backend
   # In seed_data.py Passwörter anpassen
   # Backend neu deployen auf Render
   ```

2. **Lokal testen:**
   ```bash
   docker-compose down -v
   docker-compose up -d
   # Seeds werden automatisch neu geladen
   ```

---

## 📊 Seed-Datenbank Struktur

| Entität | Anzahl | Details |
|---------|--------|---------|
| Users | 5 | admin, arzt, mfa, staff, patient |
| Practice | 1 | Praxis Dr. Müller |
| Queues | 1 | Allgemeinmedizin |
| Tickets | 4 | A-001 bis B-001 |
| Tasks | 3 | Verschiedene Prioritäten |
| ChatRooms | 1 | Team-Chat |
| ChatMessages | 5 | Demo-Konversation |

---

**🔗 API Dokumentation:** https://sanad-api.onrender.com/docs  
**🐛 Issues:** https://github.com/DiggAiHH/Sanad/issues
