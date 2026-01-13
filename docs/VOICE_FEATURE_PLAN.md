# 🎙️ Voice Feature Plan - Sanad

> **Status:** ✅ IMPLEMENTIERT - Core Services + 16 Sprachen  
> **Erstellt:** 2026-01-12  
> **Letzte Aktualisierung:** 2026-01-12

---

## 0. Implementierungs-Status

| Komponente | Status | Details |
|------------|--------|---------|
| TTS Service | ✅ Done | `tts_service.dart` - Vollständig |
| STT Service | ✅ Done | `stt_service.dart` - Vollständig |
| Command Parser | ✅ Done | Fuzzy Matching mit Levenshtein |
| Announcement Builder | ✅ Done | SSML Support |
| Voice Strings DE | ✅ Done | Phase 0 |
| Voice Strings EN | ✅ Done | Phase 0 |
| Voice Strings TR | ✅ Done | Phase 0 |
| Voice Strings AR | ✅ Done | Phase 0 (RTL) |
| Voice Strings RU | ✅ Done | Phase 1 (Slavic Plurals) |
| Voice Strings PL | ✅ Done | Phase 1 (Slavic Plurals) |
| Voice Strings FR | ✅ Done | Phase 1 |
| Voice Strings ES | ✅ Done | Phase 1 |
| Voice Strings IT | ✅ Done | Phase 2 |
| Voice Strings PT | ✅ Done | Phase 2 |
| Voice Strings UK | ✅ Done | Phase 2 (Slavic Plurals) |
| Voice Strings FA | ✅ Done | Phase 3 (RTL) |
| Voice Strings UR | ✅ Done | Phase 3 (RTL) |
| Voice Strings VI | ✅ Done | Phase 3 |
| Voice Strings RO | ✅ Done | Phase 3 |
| Voice Strings EL | ✅ Done | Phase 3 |
| Voice Provider | ✅ Done | Riverpod Integration |
| Voice Widgets | ✅ Done | VoiceButton, SpeakButton, WaveformIndicator |
| Unit Tests | ✅ Done | 4 Test-Dateien |
| App Integration | ⏳ Pending | Patient/Staff/Admin App Integration |

---

## 1. Übersicht

Voice-Funktionen für alle Sanad-Apps mit Multi-Language Support.

### Ziel-Apps:
| App | Primäre Voice-Features |
|-----|------------------------|
| **Patient App** | Ticket-Status hören, Sprachbefehle, Barrierefreiheit |
| **Staff App** | Patienten aufrufen, Ansagen, Diktierfunktion |
| **Admin App** | Statistik-Vorlesen, Sprachsteuerung |

---

## 2. Unterstützte Sprachen

### Phase 1 (MVP):
| Sprache | Code | TTS | STT | Priority |
|---------|------|-----|-----|----------|
| 🇩🇪 Deutsch | `de-DE` | ✅ | ✅ | P0 |
| 🇬🇧 Englisch | `en-GB` | ✅ | ✅ | P0 |
| 🇹🇷 Türkisch | `tr-TR` | ✅ | ✅ | P0 |
| 🇸🇦 Arabisch | `ar-SA` | ✅ | ✅ | P0 |

### Phase 2 (Erweiterung):
| Sprache | Code | TTS | STT | Priority |
|---------|------|-----|-----|----------|
| 🇷🇺 Russisch | `ru-RU` | ✅ | ✅ | P1 |
| 🇵🇱 Polnisch | `pl-PL` | ✅ | ✅ | P1 |
| 🇫🇷 Französisch | `fr-FR` | ✅ | ✅ | P1 |
| 🇪🇸 Spanisch | `es-ES` | ✅ | ✅ | P1 |
| 🇮🇹 Italienisch | `it-IT` | ✅ | ✅ | P2 |
| 🇵🇹 Portugiesisch | `pt-PT` | ✅ | ✅ | P2 |
| 🇺🇦 Ukrainisch | `uk-UA` | ✅ | ✅ | P2 |
| 🇮🇷 Farsi/Persisch | `fa-IR` | ✅ | ✅ | P2 |
| 🇵🇰 Urdu | `ur-PK` | ✅ | ✅ | P2 |
| 🇻🇳 Vietnamesisch | `vi-VN` | ✅ | ✅ | P3 |
| 🇷🇴 Rumänisch | `ro-RO` | ✅ | ✅ | P3 |
| 🇬🇷 Griechisch | `el-GR` | ✅ | ✅ | P3 |

---

## 3. Technologie-Stack

### 3.1 Text-to-Speech (TTS)
```
Option A: flutter_tts (Offline, Device-native)
  - Pro: Keine API-Kosten, funktioniert offline
  - Con: Stimmenqualität variiert je nach Gerät

Option B: Google Cloud TTS API
  - Pro: Hochwertige Neural Voices
  - Con: Kosten pro Request, braucht Internet

Option C: Azure Cognitive Services Speech
  - Pro: Exzellente Qualität, SSML Support
  - Con: Kosten, Azure-Abhängigkeit

EMPFEHLUNG: Hybrid-Ansatz
  - Primary: flutter_tts (offline)
  - Fallback: Cloud TTS für bessere Qualität wenn online
```

### 3.2 Speech-to-Text (STT)
```
Option A: speech_to_text (Flutter Plugin)
  - Pro: Native Device Recognition
  - Con: Qualität variiert

Option B: Google Cloud Speech-to-Text
  - Pro: Hohe Genauigkeit, viele Sprachen
  - Con: Kosten, Latenz

Option C: Whisper (OpenAI) via API
  - Pro: Beste Genauigkeit
  - Con: Kosten, nur API

EMPFEHLUNG: 
  - Primary: speech_to_text für kurze Befehle
  - Premium: Whisper API für Diktierfunktion
```

### 3.3 Packages (Flutter)
```yaml
dependencies:
  flutter_tts: ^3.8.5
  speech_to_text: ^6.6.0
  permission_handler: ^11.3.0
  audio_session: ^0.1.18
  
  # Optional für Cloud-Integration
  googleapis: ^12.0.0
  azure_speech_sdk: ^1.0.0  # Wenn verfügbar
```

---

## 4. Feature-Spezifikation

### 4.1 Patient App Voice Features

#### A) Ticket-Status Vorlesen (TTS)
```
Trigger: 
  - Automatisch bei Statusänderung
  - Button "Status vorlesen"
  - Accessibility: Screen Reader Support

Ansagen (Beispiele):
  DE: "Ihre Ticketnummer A-047. Sie sind an Position 3. 
       Geschätzte Wartezeit: 12 Minuten."
  EN: "Your ticket number A-047. You are at position 3. 
       Estimated wait time: 12 minutes."
  TR: "Bilet numaranız A-047. Sırada 3. sıradasınız. 
       Tahmini bekleme süresi: 12 dakika."
  AR: "رقم تذكرتك A-047. أنت في المركز 3. 
       وقت الانتظار المتوقع: 12 دقيقة."
```

#### B) Aufruf-Benachrichtigung (TTS)
```
Trigger: Ticket wird aufgerufen (Push + In-App)

Ansagen:
  DE: "Achtung! Ihre Nummer A-047 wurde aufgerufen! 
       Bitte begeben Sie sich zu Zimmer 3."
  EN: "Attention! Your number A-047 has been called! 
       Please proceed to Room 3."
  ...
  
Audio: 
  - Attention Sound vor Ansage
  - Vibration Pattern: Long-Short-Long
  - Repeat: 2x mit 3s Pause
```

#### C) Sprachbefehle (STT)
```
Befehle:
  "Status" / "Mein Status" → Ticket-Status vorlesen
  "Wartezeit" → Nur Wartezeit ansagen
  "Position" → Nur Position ansagen
  "Abbrechen" / "Stop" → Ticket stornieren (mit Bestätigung)
  "Hilfe" → Verfügbare Befehle auflisten

Aktivierung:
  - Hold-to-Talk Button
  - Wake Word: "Hey Sanad" (Optional, Phase 2)
```

#### D) Accessibility / Barrierefreiheit
```
- VoiceOver (iOS) / TalkBack (Android) Support
- Semantic Labels für alle UI-Elemente
- High Contrast Mode mit Voice Feedback
- Große Touch-Targets für Voice-Buttons
```

---

### 4.2 Staff App Voice Features

#### A) Patienten-Aufruf (TTS)
```
Trigger: Staff drückt "Aufrufen" Button

Ausgabe:
  - Über Lautsprecher im Wartezimmer (Bluetooth/WiFi Speaker)
  - Push an Patient App

Ansage:
  DE: "Nummer A-047, bitte zu Zimmer 3."
  EN: "Number A-047, please proceed to Room 3."
  
SSML-Beispiel:
  <speak>
    <prosody rate="slow" pitch="+10%">
      Nummer <say-as interpret-as="characters">A</say-as>
      <break time="100ms"/>
      <say-as interpret-as="digits">047</say-as>
    </prosody>
    <break time="500ms"/>
    Bitte zu Zimmer 3.
  </speak>
```

#### B) Diktierfunktion für Notizen (STT)
```
Use Case: Arzt/MFA diktiert Patientennotizen

Features:
  - Continuous Recording
  - Medizinische Fachbegriffe (Custom Vocabulary)
  - Interpunktion: "Punkt", "Komma", "Neue Zeile"
  - "Löschen" zum Rückgängigmachen

Sprach-Erkennung:
  - Medizinisches Vokabular pro Sprache
  - ICD-10 Codes
  - Medikamentennamen
```

#### C) Sprachsteuerung Staff-UI (STT)
```
Befehle:
  "Nächster Patient" → Nächstes Ticket aufrufen
  "Patient fertig" → Aktuelles Ticket abschließen
  "Pause" → Queue pausieren
  "Übersicht" → Dashboard-Stats vorlesen
  
Hands-Free Modus:
  - Für Behandlungsräume
  - Wake Word aktiviert
  - Bestätigungs-Sounds
```

---

### 4.3 Admin App Voice Features

#### A) Dashboard-Statistiken vorlesen (TTS)
```
Trigger: "Statistik vorlesen" Button oder Sprachbefehl

Ansage:
  DE: "Aktuelle Übersicht: 
       23 Patienten warten. 
       Durchschnittliche Wartezeit: 18 Minuten.
       5 Mitarbeiter aktiv.
       Queue A hat 12 wartende Patienten."
```

#### B) Sprachbefehle Admin (STT)
```
Befehle:
  "Zeige Queue A" → Navigation zu Queue A
  "Öffne Einstellungen" → Settings öffnen
  "Mitarbeiter Übersicht" → Staff-Liste
  "Export heute" → Tagesreport generieren
```

---

## 5. Architektur

### 5.1 Package-Struktur
```
packages/
├── voice/                          # Neues Voice Package
│   ├── lib/
│   │   ├── src/
│   │   │   ├── tts/
│   │   │   │   ├── tts_service.dart
│   │   │   │   ├── tts_config.dart
│   │   │   │   └── voice_profiles.dart
│   │   │   │
│   │   │   ├── stt/
│   │   │   │   ├── stt_service.dart
│   │   │   │   ├── stt_config.dart
│   │   │   │   ├── command_parser.dart
│   │   │   │   └── medical_vocabulary.dart
│   │   │   │
│   │   │   ├── announcements/
│   │   │   │   ├── announcement_builder.dart
│   │   │   │   ├── announcement_templates.dart
│   │   │   │   └── ssml_builder.dart
│   │   │   │
│   │   │   ├── localization/
│   │   │   │   ├── voice_strings_de.dart
│   │   │   │   ├── voice_strings_en.dart
│   │   │   │   ├── voice_strings_tr.dart
│   │   │   │   ├── voice_strings_ar.dart
│   │   │   │   └── voice_strings.dart
│   │   │   │
│   │   │   └── widgets/
│   │   │       ├── voice_button.dart
│   │   │       ├── speak_button.dart
│   │   │       ├── listen_indicator.dart
│   │   │       └── voice_settings_tile.dart
│   │   │
│   │   └── voice.dart              # Barrel export
│   │
│   ├── test/
│   │   ├── tts_service_test.dart
│   │   ├── stt_service_test.dart
│   │   └── command_parser_test.dart
│   │
│   └── pubspec.yaml
```

### 5.2 Service-Interfaces
```
abstract class TtsService {
  Future<void> speak(String text, {String? languageCode});
  Future<void> speakAnnouncement(Announcement announcement);
  Future<void> stop();
  Future<void> setLanguage(String languageCode);
  Future<void> setVoice(VoiceProfile profile);
  Future<List<VoiceProfile>> getAvailableVoices();
  Stream<TtsState> get stateStream;
}

abstract class SttService {
  Future<void> startListening({String? languageCode});
  Future<void> stopListening();
  Stream<SttResult> get resultStream;
  Stream<SttState> get stateStream;
  Future<bool> hasPermission();
  Future<void> requestPermission();
}

abstract class VoiceCommandService {
  void registerCommand(VoiceCommand command);
  void unregisterCommand(String commandId);
  Stream<VoiceCommandMatch> get commandStream;
}
```

### 5.3 State Management
```
VoiceState {
  ttsState: TtsState (idle, speaking, loading)
  sttState: SttState (idle, listening, processing)
  currentLanguage: String
  selectedVoice: VoiceProfile?
  isEnabled: bool
  volume: double
  speechRate: double
}

VoiceCubit / VoiceNotifier:
  - speak(text)
  - speakTicketStatus(ticket)
  - speakAnnouncement(ticketNumber, room)
  - startListening()
  - stopListening()
  - setLanguage(code)
  - toggleVoice()
```

---

## 6. Lokalisierungs-Strings

### 6.1 Template-Struktur
```dart
// voice_strings.dart
abstract class VoiceStrings {
  String get ticketStatusTemplate;
  String get ticketCalledTemplate;
  String get waitTimeTemplate;
  String get positionTemplate;
  
  // Interpolation
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  });
  
  String ticketCalled({
    required String ticketNumber,
    required String room,
  });
}
```

### 6.2 Beispiel-Implementierung (DE)
```dart
class VoiceStringsDe implements VoiceStrings {
  @override
  String ticketStatus({...}) =>
    'Ihre Ticketnummer $ticketNumber. '
    'Sie sind an Position $position. '
    'Geschätzte Wartezeit: $waitMinutes Minuten.';
    
  @override
  String ticketCalled({...}) =>
    'Achtung! Ihre Nummer $ticketNumber wurde aufgerufen! '
    'Bitte begeben Sie sich zu $room.';
}
```

---

## 7. Berechtigungen

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<queries>
  <intent>
    <action android:name="android.speech.RecognitionService" />
  </intent>
  <intent>
    <action android:name="android.intent.action.TTS_SERVICE" />
  </intent>
</queries>
```

### iOS (Info.plist)
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Für Sprachbefehle und Diktierfunktion</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Für Spracherkennung und Befehle</string>
```

---

## 8. UI-Komponenten

### 8.1 VoiceButton (Hold-to-Talk)
```
Design:
  - Runder Button mit Mikrofon-Icon
  - Animation: Pulsierend während Aufnahme
  - Farbwechsel: Grau → Primary (aktiv) → Rot (Error)
  - Waveform-Visualisierung
  
States:
  - idle: Mikrofon-Icon, "Halten zum Sprechen"
  - listening: Pulsierend, Waveform
  - processing: Spinner
  - error: Rot, Retry-Option
```

### 8.2 SpeakButton (Text vorlesen)
```
Design:
  - Lautsprecher-Icon
  - Toggle: Sprechen/Stop
  
States:
  - idle: Speaker Icon
  - speaking: Animierte Schallwellen, Stop-Icon
```

### 8.3 VoiceSettingsTile
```
Settings UI:
  ┌─────────────────────────────────────┐
  │ 🎙️ Sprachfunktionen                │
  │    ○ Aktiviert                      │
  │                                     │
  │ Sprache: [Deutsch ▼]                │
  │ Stimme:  [Weiblich ▼]               │
  │                                     │
  │ Geschwindigkeit: ━━━━●━━━ 1.0x      │
  │ Lautstärke:      ━━━━━━●━ 80%       │
  │                                     │
  │ [Test-Ansage abspielen]             │
  └─────────────────────────────────────┘
```

---

## 9. Backend-Integration

### 9.1 WebSocket Events (Echtzeit-Aufruf)
```json
{
  "event": "ticket_called",
  "data": {
    "ticket_number": "A-047",
    "room": "Zimmer 3",
    "patient_language": "de-DE",
    "announcement_audio_url": "https://..." // Optional: Pre-rendered
  }
}
```

### 9.2 Ansagen-API (Optional)
```
POST /api/v1/announcements/generate
{
  "template": "ticket_called",
  "language": "de-DE",
  "variables": {
    "ticket_number": "A-047",
    "room": "Zimmer 3"
  },
  "voice": "female_neural"
}

Response:
{
  "audio_url": "https://storage.../announcement_xyz.mp3",
  "text": "Nummer A-047, bitte zu Zimmer 3.",
  "duration_ms": 3200
}
```

---

## 10. Testing-Strategie

### 10.1 Unit Tests
```
□ TtsService: speak, stop, language switching
□ SttService: start/stop, permission handling
□ CommandParser: Command matching, fuzzy matching
□ AnnouncementBuilder: Template interpolation
□ VoiceStrings: All languages, all templates
```

### 10.2 Integration Tests
```
□ TTS → Audio Output (mit Mock)
□ STT → Text Recognition (mit Mock)
□ Full Flow: Button Press → Recognition → Action
```

### 10.3 Device Testing
```
□ Android: Samsung, Pixel, Huawei (verschiedene TTS Engines)
□ iOS: iPhone, iPad
□ Verschiedene Sprachen pro Device
```

---

## 11. Rollout-Phasen

### Phase 1: MVP (2 Wochen)
```
□ TTS Service mit flutter_tts
□ Ticket-Status vorlesen (Patient App)
□ Patienten-Aufruf TTS (Staff App)
□ Sprachen: DE, EN
□ Basic VoiceButton Widget
```

### Phase 2: STT Integration (2 Wochen)
```
□ STT Service mit speech_to_text
□ Sprachbefehle Patient App (Status, Wartezeit)
□ Sprachen: DE, EN, TR, AR
□ Command Parser
```

### Phase 3: Advanced Features (2 Wochen)
```
□ Diktierfunktion Staff App
□ Medizinisches Vokabular
□ Cloud TTS Option (bessere Qualität)
□ Weitere Sprachen (Phase 2 Sprachen)
```

### Phase 4: Polish (1 Woche)
```
□ Accessibility Audit
□ Performance Optimierung
□ Offline-Caching von Ansagen
□ Dokumentation
```

---

## 12. Offene Fragen

| # | Frage | Entscheidung benötigt von |
|---|-------|---------------------------|
| 1 | Cloud TTS Budget? (Google/Azure) | Product Owner |
| 2 | Wake Word gewünscht? ("Hey Sanad") | Product Owner |
| 3 | Lautsprecher-Integration im Wartezimmer? | IT/Hardware |
| 4 | Dialekt-Support? (Schweizerdeutsch, Österreichisch) | Product Owner |
| 5 | HIPAA/DSGVO für Cloud STT? | Legal/Compliance |

---

## 13. Abhängigkeiten

```
Benötigt vor Start:
  ✅ Core Package (Models)
  ✅ UI Package (Widgets)
  ⏳ Lokalisierung (i18n Setup)
  ⏳ Settings-Screen in allen Apps

Externe Abhängigkeiten:
  - flutter_tts Paket
  - speech_to_text Paket
  - (Optional) Cloud API Keys
```

---

## 14. Geschätzte Story Points

| Feature | Story Points | Priorität |
|---------|-------------|-----------|
| TTS Service Setup | 3 | P0 |
| Ticket-Status TTS | 2 | P0 |
| Patienten-Aufruf TTS | 3 | P0 |
| VoiceButton Widget | 2 | P0 |
| SpeakButton Widget | 1 | P0 |
| STT Service Setup | 5 | P1 |
| Sprachbefehle Patient | 3 | P1 |
| Diktierfunktion Staff | 8 | P2 |
| Cloud TTS Integration | 5 | P2 |
| Medical Vocabulary | 5 | P2 |
| Weitere Sprachen (8) | 8 | P2 |
| **TOTAL** | **45 SP** | - |

---

**📌 REMINDER: Dies ist NUR ein Plan. Kein Code wurde geschrieben.**

**Nächster Schritt:** Dieser Plan wird von einem separaten Agent ausgeführt.
