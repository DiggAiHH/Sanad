# ESP32 Firmware für Zero-Touch Reception

## Übersicht

Dieses Dokument beschreibt die Firmware-Architektur und Verdrahtung für die ESP32-basierten IoT-Geräte im Sanad Zero-Touch Reception System.

## Gerätetypen

| Typ | Funktion | Firmware |
|-----|----------|----------|
| **NFC-Reader** | Patientenidentifikation am Eingang | Custom Arduino/PlatformIO |
| **LED-Controller** | Wegführungs-LEDs (WLED) | WLED Firmware |
| **Display-Controller** | Wartezimmer-Anzeige | ESPHome |

---

## 1. NFC-Reader (ESP32 + PN532)

### 1.1 Hardware-Komponenten

| Komponente | Empfohlenes Modell | Bezugsquelle |
|------------|-------------------|--------------|
| Mikrocontroller | ESP32-WROOM-32D | AliExpress, Amazon |
| NFC-Modul | PN532 NFC RFID | Adafruit, AliExpress |
| Gehäuse | IP65 wasserdicht | 3D-Druck / Kauf |
| Netzteil | 5V 2A USB-C | Standard |

### 1.2 Verdrahtung (SPI-Modus)

```
PN532 Pin    →    ESP32 Pin    Funktion
─────────────────────────────────────────
SCK          →    GPIO 18      Serial Clock
MISO         →    GPIO 19      Master In Slave Out
MOSI         →    GPIO 23      Master Out Slave In
SS (CS)      →    GPIO 5       Chip Select
VCC          →    3.3V         Stromversorgung
GND          →    GND          Masse
IRQ          →    GPIO 4       (Optional) Interrupt
RSTO         →    GPIO 2       (Optional) Reset
```

**Wichtig:** DIP-Schalter auf dem PN532 auf SPI-Modus stellen:
- SEL0: OFF
- SEL1: ON

### 1.3 Arduino-Sketch (PlatformIO)

```cpp
// platformio.ini
// [env:esp32dev]
// platform = espressif32
// board = esp32dev
// framework = arduino
// lib_deps =
//     adafruit/Adafruit PN532@^1.3.0
//     knolleary/PubSubClient@^2.8
//     bblanchon/ArduinoJson@^6.21.0

#include <Arduino.h>
#include <WiFi.h>
#include <PubSubClient.h>
#include <Adafruit_PN532.h>
#include <ArduinoJson.h>

// ============ KONFIGURATION ============
// ⚠️ NIEMALS Secrets hardcoden! Nutze WiFiManager oder NVS.
const char* WIFI_SSID = "";      // Aus NVS laden
const char* WIFI_PASS = "";      // Aus NVS laden
const char* MQTT_SERVER = "";    // Backend-Server IP
const int MQTT_PORT = 1883;
const char* DEVICE_ID = "";      // Aus NVS laden
const char* DEVICE_SECRET = "";  // Aus NVS laden
const char* PRACTICE_ID = "";    // Aus NVS laden

// MQTT Topics
String TOPIC_NFC_SCAN;    // sanad/{practice_id}/nfc/{device_id}/scan
String TOPIC_HEARTBEAT;   // sanad/{practice_id}/device/{device_id}/status
String TOPIC_COMMANDS;    // sanad/{practice_id}/device/{device_id}/commands

// ============ HARDWARE ============
#define PN532_SCK  18
#define PN532_MISO 19
#define PN532_MOSI 23
#define PN532_SS   5

Adafruit_PN532 nfc(PN532_SCK, PN532_MISO, PN532_MOSI, PN532_SS);

WiFiClient espClient;
PubSubClient mqtt(espClient);

// LED für Status-Anzeige
#define STATUS_LED 2

// ============ FUNKTIONEN ============

void setupWiFi() {
  Serial.print("Verbinde mit WiFi...");
  WiFi.begin(WIFI_SSID, WIFI_PASS);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 30) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\n✅ WiFi verbunden: " + WiFi.localIP().toString());
  } else {
    Serial.println("\n❌ WiFi Fehler!");
  }
}

void setupMQTT() {
  // Topics initialisieren
  TOPIC_NFC_SCAN = String("sanad/") + PRACTICE_ID + "/nfc/" + DEVICE_ID + "/scan";
  TOPIC_HEARTBEAT = String("sanad/") + PRACTICE_ID + "/device/" + DEVICE_ID + "/status";
  TOPIC_COMMANDS = String("sanad/") + PRACTICE_ID + "/device/" + DEVICE_ID + "/commands";
  
  mqtt.setServer(MQTT_SERVER, MQTT_PORT);
  mqtt.setCallback(mqttCallback);
}

void mqttReconnect() {
  while (!mqtt.connected()) {
    Serial.print("MQTT Verbindung...");
    
    String clientId = String("nfc-reader-") + DEVICE_ID;
    
    if (mqtt.connect(clientId.c_str())) {
      Serial.println("✅ MQTT verbunden");
      mqtt.subscribe(TOPIC_COMMANDS.c_str());
    } else {
      Serial.print("❌ Fehler: ");
      Serial.println(mqtt.state());
      delay(5000);
    }
  }
}

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  // Kommandos vom Backend verarbeiten
  StaticJsonDocument<256> doc;
  deserializeJson(doc, payload, length);
  
  const char* command = doc["command"];
  
  if (strcmp(command, "reboot") == 0) {
    ESP.restart();
  } else if (strcmp(command, "led_on") == 0) {
    digitalWrite(STATUS_LED, HIGH);
  } else if (strcmp(command, "led_off") == 0) {
    digitalWrite(STATUS_LED, LOW);
  }
}

void sendHeartbeat() {
  StaticJsonDocument<256> doc;
  doc["device_id"] = DEVICE_ID;
  doc["status"] = "online";
  doc["uptime"] = millis() / 1000;
  doc["free_heap"] = ESP.getFreeHeap();
  doc["rssi"] = WiFi.RSSI();
  
  String payload;
  serializeJson(doc, payload);
  mqtt.publish(TOPIC_HEARTBEAT.c_str(), payload.c_str());
}

String bytesToHex(uint8_t* bytes, uint8_t len) {
  String result = "";
  for (uint8_t i = 0; i < len; i++) {
    if (i > 0) result += ":";
    if (bytes[i] < 0x10) result += "0";
    result += String(bytes[i], HEX);
  }
  result.toUpperCase();
  return result;
}

void publishNFCScan(String uid) {
  StaticJsonDocument<256> doc;
  doc["uid"] = uid;
  doc["device_id"] = DEVICE_ID;
  doc["timestamp"] = millis();
  
  String payload;
  serializeJson(doc, payload);
  
  mqtt.publish(TOPIC_NFC_SCAN.c_str(), payload.c_str());
  Serial.println("📤 NFC Scan gesendet: " + uid);
  
  // LED blinken zur Bestätigung
  digitalWrite(STATUS_LED, HIGH);
  delay(200);
  digitalWrite(STATUS_LED, LOW);
}

// ============ SETUP ============

void setup() {
  Serial.begin(115200);
  Serial.println("\n🏥 Sanad NFC-Reader v1.0");
  
  pinMode(STATUS_LED, OUTPUT);
  digitalWrite(STATUS_LED, LOW);
  
  // NFC initialisieren
  nfc.begin();
  uint32_t versiondata = nfc.getFirmwareVersion();
  
  if (!versiondata) {
    Serial.println("❌ PN532 nicht gefunden!");
    while (1) {
      digitalWrite(STATUS_LED, !digitalRead(STATUS_LED));
      delay(100);
    }
  }
  
  Serial.print("✅ PN532 gefunden: ");
  Serial.println((versiondata >> 24) & 0xFF, HEX);
  
  nfc.SAMConfig();
  
  // Netzwerk
  setupWiFi();
  setupMQTT();
  
  Serial.println("🟢 Bereit für NFC-Scans");
}

// ============ LOOP ============

unsigned long lastHeartbeat = 0;
const unsigned long HEARTBEAT_INTERVAL = 30000; // 30 Sekunden

void loop() {
  // MQTT Verbindung aufrechterhalten
  if (!mqtt.connected()) {
    mqttReconnect();
  }
  mqtt.loop();
  
  // Heartbeat senden
  if (millis() - lastHeartbeat > HEARTBEAT_INTERVAL) {
    sendHeartbeat();
    lastHeartbeat = millis();
  }
  
  // NFC Tag lesen
  uint8_t success;
  uint8_t uid[7];
  uint8_t uidLength;
  
  success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 100);
  
  if (success) {
    String uidHex = bytesToHex(uid, uidLength);
    publishNFCScan(uidHex);
    
    // Debounce: 2 Sekunden warten bevor nächster Scan
    delay(2000);
  }
}
```

### 1.4 Provisioning

Für die Ersteinrichtung wird **WiFiManager** empfohlen:

```cpp
#include <WiFiManager.h>

void setup() {
  WiFiManager wm;
  
  // Custom Parameters für MQTT
  WiFiManagerParameter mqtt_server("mqtt", "MQTT Server", "", 40);
  WiFiManagerParameter device_id("device", "Device ID", "", 40);
  
  wm.addParameter(&mqtt_server);
  wm.addParameter(&device_id);
  
  // AP starten wenn keine Verbindung
  if (!wm.autoConnect("Sanad-NFC-Setup")) {
    ESP.restart();
  }
  
  // Parameter in NVS speichern
  // ...
}
```

---

## 2. LED-Controller (ESP32 + WLED)

### 2.1 WLED Installation

1. **Firmware flashen:**
   - Gehe zu https://install.wled.me
   - Wähle "ESP32" und klicke "Install"
   - Verbinde ESP32 via USB

2. **WiFi konfigurieren:**
   - Verbinde mit AP "WLED-AP"
   - Gehe zu 4.3.2.1, konfiguriere WiFi

3. **LED-Strip anschließen:**
   ```
   WS2812B    →    ESP32
   ─────────────────────
   VCC        →    5V (externes Netzteil!)
   GND        →    GND (gemeinsam mit ESP32)
   DIN        →    GPIO 16 (Default WLED)
   ```

### 2.2 WLED Segment-Konfiguration

Im WLED Web-Interface unter "Segments":

| Segment ID | Start LED | End LED | Name | Verwendung |
|------------|-----------|---------|------|------------|
| 0 | 0 | 19 | Eingang | Empfangsbereich |
| 1 | 20 | 49 | Flur-A | Korridor zu Räumen 1-3 |
| 2 | 50 | 79 | Flur-B | Korridor zu Räumen 4-6 |
| 3 | 80 | 99 | Wartebereich | Wartezimmer |

### 2.3 WLED JSON API Beispiele

**Segment grün schalten:**
```bash
curl -X POST http://192.168.1.100/json \
  -H "Content-Type: application/json" \
  -d '{
    "seg": [{
      "id": 1,
      "on": true,
      "bri": 255,
      "col": [[0, 255, 0]],
      "fx": 0
    }]
  }'
```

**Chase-Effekt für Wegführung:**
```bash
curl -X POST http://192.168.1.100/json \
  -d '{
    "seg": [{
      "id": 1,
      "on": true,
      "col": [[0, 255, 0]],
      "fx": 28,
      "sx": 128,
      "ix": 128
    }]
  }'
```

**Wartezeit-Farbe (Rot bei Überlastung):**
```bash
curl -X POST http://192.168.1.100/json \
  -d '{
    "seg": [{
      "id": 3,
      "on": true,
      "col": [[255, 0, 0]],
      "fx": 2
    }]
  }'
```

### 2.4 WLED Effekt-IDs

| ID | Effekt | Verwendung |
|----|--------|------------|
| 0 | Solid | Status-Anzeige |
| 2 | Breathe | Wartebereich (ruhig) |
| 9 | Rainbow | Erfolg/Willkommen |
| 24 | Wipe | Wegführung (Start) |
| 28 | Chase | Wegführung (Animation) |
| 42 | Scanner | Aufmerksamkeit |

---

## 3. ESPHome-Konfiguration (Alternative)

Für Home Assistant Integration:

```yaml
# esphome/nfc_reader.yaml
esphome:
  name: sanad-nfc-empfang
  friendly_name: "Sanad NFC Empfang"

esp32:
  board: esp32dev
  framework:
    type: arduino

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

# NFC via SPI
spi:
  clk_pin: GPIO18
  mosi_pin: GPIO23
  miso_pin: GPIO19

pn532_spi:
  cs_pin: GPIO5
  update_interval: 500ms
  on_tag:
    then:
      - homeassistant.tag_scanned: !lambda 'return x;'
      - light.turn_on:
          id: status_led
          flash_length: 500ms

# Status LED
light:
  - platform: status_led
    name: "Status LED"
    id: status_led
    pin: GPIO2

# API für Home Assistant
api:
  encryption:
    key: !secret api_key

# MQTT (optional)
mqtt:
  broker: !secret mqtt_broker
  username: !secret mqtt_user
  password: !secret mqtt_password
  topic_prefix: sanad/nfc

logger:
  level: INFO
```

---

## 4. Stromversorgung & Schutzschaltung

### 4.1 LED-Strip Stromberechnung

| LEDs | Strom @ Weiß 100% | Empfohlenes Netzteil |
|------|-------------------|---------------------|
| 30 | 1.8A | 5V 3A |
| 60 | 3.6A | 5V 5A |
| 100 | 6.0A | 5V 10A |
| 144 | 8.6A | 5V 10A + Einspeisepunkte |

### 4.2 Best Practices

1. **Kondensator:** 1000µF 16V über Netzteil-Anschluss
2. **Widerstand:** 470Ω in Datenleitung (nah am ESP32)
3. **Einspeisepunkte:** Alle 50 LEDs bei langen Strips
4. **Gemeinsame Masse:** ESP32 GND mit LED-Netzteil verbinden

### 4.3 Schaltplan

```
                    ┌─────────────────┐
    5V 10A PSU  ───►│ +    1000µF    -│──► GND
                    └────────┬────────┘
                             │
                             ▼
    ┌────────────────────────┴────────────────────────────┐
    │                    WS2812B Strip                    │
    │  VCC ◄───────────────────────────────────────────── │
    │  DIN ◄──[470Ω]──GPIO16 (ESP32)                     │
    │  GND ◄─────────────────────────────────────────────│
    └─────────────────────────────────────────────────────┘
                             │
    ESP32 ◄──────────────────┘ (GND verbunden)
      │
      └── 5V USB (separate Stromversorgung)
```

---

## 5. MQTT Topics Übersicht

| Topic | Publisher | Subscriber | Payload |
|-------|-----------|------------|---------|
| `sanad/{practice}/nfc/{device}/scan` | NFC-Reader | Backend | `{"uid": "...", "device_id": "..."}` |
| `sanad/{practice}/led/{device}/command` | Backend | LED-Ctrl | `{"seg": [...]}` |
| `sanad/{practice}/device/{device}/status` | Gerät | Backend | `{"status": "online", ...}` |
| `sanad/{practice}/events` | Backend | Flutter Apps | Event-Broadcast |

---

## 6. Troubleshooting

| Problem | Lösung |
|---------|--------|
| PN532 nicht erkannt | DIP-Schalter auf SPI prüfen, Verdrahtung checken |
| WiFi instabil | Externes Netzteil nutzen (nicht nur USB) |
| LEDs flackern | Kondensator hinzufügen, GND-Verbindung prüfen |
| MQTT Verbindung bricht ab | Heartbeat-Interval reduzieren, QoS=1 nutzen |
| LEDs am Ende dunkler | Einspeisepunkte hinzufügen |

---

## 7. Stückliste für Prototyp

| Komponente | Menge | ~Preis |
|------------|-------|--------|
| ESP32-WROOM-32D | 2 | 12€ |
| PN532 NFC Modul | 1 | 8€ |
| WS2812B 144 LED/m (1m) | 1 | 15€ |
| 5V 10A Netzteil | 1 | 12€ |
| Jumper Wires | 1 Set | 5€ |
| 1000µF Kondensator | 2 | 1€ |
| 470Ω Widerstand | 5 | 0.50€ |
| **Gesamt** | | **~54€** |

---

## 8. Nächste Schritte

1. [ ] ESP32 + PN532 auf Breadboard verdrahten
2. [ ] WiFi + MQTT Verbindung testen
3. [ ] WLED auf zweitem ESP32 installieren
4. [ ] Backend-Integration testen (NFC → Ticket → LED)
5. [ ] Prototyp-Gehäuse designen
6. [ ] Architekturmodell bauen
