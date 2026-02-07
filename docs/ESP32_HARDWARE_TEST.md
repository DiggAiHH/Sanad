# ESP32 Hardware-Test Plan

> **Version:** 1.0  
> **Letzte Aktualisierung:** 2026-01-13  
> **Status:** 🟡 Geplant

---

## 1. Übersicht

Dieses Dokument beschreibt den Testplan für die Integration von ESP32-basierten IoT-Geräten mit dem Sanad Zero-Touch Reception System.

### 1.1 Testkomponenten

| Komponente | Hardware | Funktion |
|------------|----------|----------|
| **NFC-Reader** | ESP32 + PN532/RC522 | Patienten-Check-in via NFC-Karte |
| **LED-Controller** | ESP32 + WLED | Wayfinding-Route Anzeige |
| **Display** | ESP32 + TFT/E-Ink | Wartezeit-Anzeige (optional) |

---

## 2. Hardware-Anforderungen

### 2.1 NFC-Reader Setup

```yaml
Hardware:
  - ESP32-WROOM-32 oder ESP32-S3
  - PN532 NFC/RFID Modul (I2C oder SPI)
  - 5V/2A USB-Netzteil
  - 3D-gedrucktes Gehäuse (optional)

Pinout (I2C):
  - SDA: GPIO21
  - SCL: GPIO22
  - VCC: 3.3V
  - GND: GND

Firmware:
  - ESPHome oder Custom Arduino
  - MQTT für Backend-Kommunikation
```

### 2.2 LED-Controller (WLED)

```yaml
Hardware:
  - ESP32 oder ESP8266
  - WS2812B LED-Strip (5V, 60 LEDs/m)
  - 5V Netzteil (mind. 60mA × LED-Anzahl)
  - Level-Shifter 3.3V → 5V (optional)

Pinout:
  - Data: GPIO16 (Standard WLED)
  - Power: 5V direkt am Strip

Firmware:
  - WLED 0.14.x
  - JSON API aktiviert
  - Segments für Zonen konfiguriert
```

---

## 3. Testszenarien

### 3.1 NFC Check-in (Happy Path)

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | NFC-Karte an Reader halten | LED blinkt grün |
| 2 | ESP32 sendet UID an Backend | HTTP 200, Ticket erstellt |
| 3 | Backend triggert Wayfinding | MQTT Message an LED-Controller |
| 4 | LED-Strip zeigt Route | Grüne Animation Richtung Wartebereich |
| 5 | Display zeigt Ticket-Nummer | "A-042 – Wartebereich A" |

### 3.2 NFC Check-in (Unbekannte Karte)

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Unbekannte NFC-Karte scannen | LED blinkt rot |
| 2 | ESP32 sendet UID an Backend | HTTP 404, "Karte nicht registriert" |
| 3 | Display zeigt Fehler | "Bitte am Empfang melden" |

### 3.3 NFC Check-in (Ungültiges Device Secret)

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Request mit falschem Secret | HTTP 401 |
| 2 | ESP32 zeigt Konfigurationsfehler | LED rot, Display: "Gerät nicht autorisiert" |
| 3 | Admin-Alert | Push an Admin-App |

### 3.4 LED Wayfinding Route

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Backend aktiviert Route | MQTT: `sanad/led/{device_id}/route` |
| 2 | WLED empfängt Segment-Daten | Segments 0-5: Grün pulsierend |
| 3 | Animation läuft 30 Sekunden | Dann Fade-out |
| 4 | Neue Route überschreibt alte | Nahtloser Übergang |

### 3.5 Wartezeit-Farben

| Wartezeit | Farbe | WLED Preset |
|-----------|-------|-------------|
| < 5 min | 🟢 Grün | `#00FF00` |
| 5-15 min | 🟡 Gelb | `#FFFF00` |
| 15-30 min | 🟠 Orange | `#FF8000` |
| > 30 min | 🔴 Rot | `#FF0000` |

### 3.6 Offline-Fallback

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Backend nicht erreichbar | ESP32 erkennt Timeout |
| 2 | LED zeigt Offline-Status | Blaues Blinken |
| 3 | Display zeigt Hinweis | "Bitte am Empfang melden" |
| 4 | Retry alle 30 Sekunden | Automatische Reconnection |

---

## 4. API-Endpunkte für ESP32

### 4.1 NFC Check-in

```http
POST /api/nfc/check-in
Content-Type: application/json

{
  "nfc_uid": "04:A3:5B:1A:7C:8D:90",
  "device_id": "uuid-des-readers",
  "device_secret": "64-hex-chars"
}
```

**Response (Success):**
```json
{
  "success": true,
  "ticket_number": "A-042",
  "queue_name": "Allgemein",
  "estimated_wait_minutes": 15,
  "wayfinding_route_id": "uuid-der-route",
  "patient_name": "Max"
}
```

### 4.2 Device Heartbeat

```http
POST /api/led/devices/heartbeat
Content-Type: application/json

{
  "device_serial": "NFC-001",
  "device_secret": "64-hex-chars",
  "firmware_version": "1.2.3",
  "uptime_seconds": 3600,
  "free_memory": 45000
}
```

### 4.3 MQTT Topics

| Topic | Direction | Payload |
|-------|-----------|---------|
| `sanad/device/{id}/status` | Device → Server | `{"online": true, "ip": "..."}` |
| `sanad/led/{id}/route` | Server → Device | `{"segments": [...], "color": "#00FF00"}` |
| `sanad/led/{id}/command` | Server → Device | `{"effect": "pulse", "speed": 50}` |
| `sanad/nfc/{id}/scan` | Device → Server | `{"uid": "...", "timestamp": "..."}` |

---

## 5. ESPHome Beispiel-Konfiguration

### 5.1 NFC-Reader

```yaml
esphome:
  name: sanad-nfc-reader
  platform: ESP32
  board: esp32dev

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

mqtt:
  broker: !secret mqtt_broker
  username: !secret mqtt_user
  password: !secret mqtt_password
  topic_prefix: sanad/nfc/reader-01

pn532_i2c:
  id: pn532_board
  i2c_id: i2c_bus

i2c:
  id: i2c_bus
  sda: GPIO21
  scl: GPIO22

binary_sensor:
  - platform: pn532
    uid: ""  # Match all cards
    name: "NFC Card Detected"
    on_press:
      then:
        - http_request.post:
            url: "http://backend:8000/api/nfc/check-in"
            headers:
              Content-Type: application/json
            json:
              nfc_uid: !lambda 'return id(pn532_board).get_tag();'
              device_id: "uuid-here"
              device_secret: !secret device_secret
```

### 5.2 WLED Integration

```yaml
# WLED ist eigenständige Firmware
# Konfiguration über WLED Web-UI:
# 1. Segments für Zonen erstellen
# 2. Presets für Farben/Effekte
# 3. MQTT aktivieren unter Config → Sync Interfaces

# API-Aufruf für Route-Aktivierung:
# POST http://wled-ip/json/state
{
  "seg": [
    {"id": 0, "col": [[0,255,0]], "fx": 42, "sx": 128}
  ],
  "transition": 7
}
```

---

## 6. Debugging-Checkliste

### 6.1 NFC-Reader

- [ ] PN532 über I2C erreichbar? (`i2cdetect -y 1`)
- [ ] NFC-UID wird korrekt gelesen? (Serial Monitor)
- [ ] HTTP-Request erreicht Backend? (Backend Logs)
- [ ] Device Secret stimmt? (401 vs 200)
- [ ] WiFi/MQTT stabil? (Ping + Reconnect-Counter)

### 6.2 LED-Controller

- [ ] WLED Web-UI erreichbar? (`http://wled-ip`)
- [ ] Segments korrekt konfiguriert? (Test via UI)
- [ ] MQTT-Subscription aktiv? (WLED → Config → Sync)
- [ ] JSON API funktioniert? (curl Test)
- [ ] Stromversorgung ausreichend? (Voltage Drop?)

### 6.3 Backend-Verbindung

- [ ] Backend läuft? (`docker ps`)
- [ ] Mosquitto MQTT läuft? (`docker logs mosquitto`)
- [ ] Firewall-Ports offen? (1883, 8000)
- [ ] Device in DB registriert? (Admin Dashboard)

---

## 7. Metriken & Monitoring

| Metrik | Quelle | Alarm-Schwelle |
|--------|--------|----------------|
| Device Online Status | Heartbeat | Offline > 5 min |
| Check-in Latenz | Backend Logs | > 2 Sekunden |
| MQTT Message Lag | Mosquitto | > 500ms |
| NFC Read Errors | ESP32 Counter | > 5% Fehlerrate |
| LED Controller Response | HTTP | Timeout > 1s |

---

## 8. Sicherheits-Testszenarien

### 8.1 Replay-Attacke

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Gültigen NFC-Check-in abfangen | Request mit UID + Timestamp |
| 2 | Request nach 60s wiederholen | HTTP 400: "Duplicate check-in" |
| 3 | Backend prüft Timestamp | Ablehnung bei > 30s Differenz |

### 8.2 Brute-Force Device Secret

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | 10 Requests mit falschem Secret | HTTP 401 für jeden |
| 2 | 11. Request | HTTP 429: "Too many attempts" |
| 3 | Device-IP in Deny-Liste für 15 min | Automatische Sperre |

### 8.3 Man-in-the-Middle (MQTT)

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Unsignierte Message an WLED | WLED ignoriert (kein Shared Secret) |
| 2 | Backend signiert Commands | HMAC-SHA256 Validierung auf Device |
| 3 | Replay alter Commands | Nonce-Prüfung schlägt fehl |

### 8.4 Denial-of-Service (Schnelle NFC-Scans)

| Schritt | Aktion | Erwartetes Ergebnis |
|---------|--------|---------------------|
| 1 | Gleiche Karte 10× in 5 Sekunden | Nur 1 Check-in akzeptiert |
| 2 | Rate-Limit auf Device-Ebene | Debounce: 3 Sekunden pro Karte |
| 3 | Logging für Abuse-Detektion | Alert bei > 20 Scans/Minute |

---

## 9. Edge Cases & Recovery

### 9.1 Power-Loss während Check-in

| Szenario | Verhalten |
|----------|-----------|
| ESP32 Stromausfall nach NFC-Read | Kein Request gesendet, Patient versucht erneut |
| Stromausfall nach Backend-Response | LED-Animation startet nicht, manuelle Wegweisung |
| **Recovery:** | ESP32 bootet in < 5s, WLED in < 3s |

### 9.2 WiFi-Roaming

| Szenario | Verhalten |
|----------|-----------|
| ESP32 verliert WLAN-Verbindung | Auto-Reconnect innerhalb 10s |
| DHCP IP-Wechsel | Backend akzeptiert neue IP (Device-ID bleibt) |
| **Empfehlung:** | Statische IP für kritische Devices |

### 9.3 Firmware-OTA während Betrieb

| Phase | Verhalten |
|-------|-----------|
| OTA-Start | Neue Scans werden gepuffert (max. 10) |
| OTA-Abschluss | Reboot, Puffer-Verarbeitung |
| OTA-Fehler | Rollback auf vorherige Firmware |

---

## 10. Rollout-Plan

### Phase 1: Labor-Test (Woche 1)

- [ ] 1× NFC-Reader + 1× WLED Controller aufbauen
- [ ] Alle Testszenarien durchspielen
- [ ] Latenz messen (Ziel: < 500ms Check-in)

### Phase 2: Pilot-Praxis (Woche 2-3)

- [ ] Installation in 1 Praxis
- [ ] Schulung MFA-Personal
- [ ] 1 Woche Monitoring

### Phase 3: Rollout (Woche 4+)

- [ ] Weitere Praxen onboarden
- [ ] Fernwartung via OTA-Updates
- [ ] Feedback-Loop etablieren

---

## 11. Kontakt & Support

| Rolle | Verantwortung |
|-------|---------------|
| **IoT-Lead** | Hardware-Beschaffung, Firmware |
| **Backend-Dev** | API, MQTT, Database |
| **MFA-Support** | Schulung, First-Level-Support |

---

*Dokument erstellt von Senior Architect Agent v2025.1*

