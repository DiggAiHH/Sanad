# Firebase & Authentication Clarification

## 🚫 FIREBASE AUTH IST **NICHT** IN VERWENDUNG

### Aktuelles Authentication-System
- **JWT Token-basierte Authentifizierung** (backend/app/services/auth_service.py)
- Passwort-Hashing mit `bcrypt`
- Session-Management über HTTP-Only Cookies (optional)
- **KEINE Abhängigkeit von Firebase Authentication**

### Login-Flow
```
User → POST /api/v1/auth/login → Backend (JWT generieren) → Frontend (Token speichern)
```

**Implementierung:**
- Backend: `backend/app/routers/auth.py`
- Service: `backend/app/services/auth_service.py`
- Schemas: `backend/app/schemas/schemas.py` (LoginRequest, TokenResponse)

---

## 📱 Firebase Cloud Messaging (FCM) - **OPTIONAL GEPLANT**

### Was ist geplant?
- **Push Notifications** für:
  - Neue Tickets in der Warteschlange
  - Task-Zuweisungen
  - Chat-Nachrichten
  - Dringende Ereignisse

### Warum Firebase?
- Firebase Cloud Messaging (FCM) ist **NUR für Push Notifications**
- Kostenlos bis 500.000 Messages/Monat
- Plattformübergreifend (iOS, Android, Web)

### Was wird **NICHT** verwendet?
- ❌ Firebase Authentication (JWT bereits implementiert)
- ❌ Firebase Realtime Database (PostgreSQL bereits implementiert)
- ❌ Firebase Storage (Nicht benötigt)

---

## 🔧 Firebase Setup - Nur für Push Notifications

### Schritt 1: Firebase-Projekt erstellen
```bash
# 1. Gehe zu [https://console.firebase.google.com](https://console.firebase.google.com)
# 2. Neues Projekt erstellen "Sanad Medical"
# 3. Google Analytics OPTIONAL (kann deaktiviert werden)
```

### Schritt 2: Flutter-Apps konfigurieren
```bash
# FlutterFire CLI installieren
dart pub global activate flutterfire_cli

# Firebase für alle 4 Apps konfigurieren
cd /workspaces/Sanad
flutterfire configure \
  --project=sanad-medical \
  --out=packages/core/lib/firebase_options.dart \
  --platforms=web
```

### Schritt 3: FCM-Token abrufen (Frontend)
```dart
// packages/core/lib/src/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }

  void listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Show in-app notification
      print('Push: ${message.notification?.title}');
    });
  }
}
```

### Schritt 4: Backend FCM-Integration
```python
# backend/requirements.txt
firebase-admin==6.5.0

# backend/app/services/push_service.py
import firebase_admin
from firebase_admin import credentials, messaging

cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)

async def send_push_notification(fcm_token: str, title: str, body: str):
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        token=fcm_token,
    )
    response = messaging.send(message)
    return response
```

---

## 🔐 Secrets Management für FCM

### Backend (Render.com)
```bash
# Render Dashboard → Environment Variables
FIREBASE_PROJECT_ID=sanad-medical
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xyz@sanad-medical.iam.gserviceaccount.com
```

### Frontend (Netlify)
```bash
# Netlify Dashboard → Build Environment Variables
FIREBASE_API_KEY=AIzaSy...
FIREBASE_PROJECT_ID=sanad-medical
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:web:abc123
```

---

## ⚠️ Wichtige Hinweise

### Was funktioniert OHNE Firebase?
✅ **Alle Core-Funktionen:**
- Login (JWT)
- User Management
- Ticket-System
- Queue-Management
- Task-Management
- Chat (WebSocket/Polling)

### Was benötigt Firebase?
🔔 **Nur Push Notifications:**
- Background notifications (App geschlossen)
- Benachrichtigungen auf iOS/Android

### Alternative zu Firebase FCM
Falls Firebase vermieden werden soll:
- **WebSockets** (für Echtzeit-Updates im Frontend)
- **Server-Sent Events (SSE)** (für Live-Updates)
- **Browser Notifications API** (nur wenn App geöffnet)

```dart
// Ohne Firebase: Browser Notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

await flutterLocalNotificationsPlugin.show(
  0,
  'Neues Ticket',
  'B001 - Fatima Al-Hassan wartet',
  NotificationDetails(),
);
```

---

## 🎯 Zusammenfassung

| Feature | Technologie | Status |
|---------|------------|--------|
| **Authentication** | JWT + bcrypt | ✅ Implementiert |
| **Database** | PostgreSQL | ✅ Implementiert |
| **Push Notifications** | FCM (optional) | 🔄 Geplant |
| **Realtime Updates** | WebSocket (alternative) | 🔄 Optional |

**Fazit:** Firebase Authentication ist **NICHT** erforderlich. Firebase Cloud Messaging (FCM) ist nur für Push Notifications geplant und **OPTIONAL**. Das System funktioniert vollständig ohne Firebase.
