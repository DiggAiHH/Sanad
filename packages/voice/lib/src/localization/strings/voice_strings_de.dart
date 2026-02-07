import '../voice_strings.dart';

/// German voice strings implementation
class VoiceStringsDe extends VoiceStrings {
  const VoiceStringsDe();

  @override
  String get languageCode => 'de';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'Minute' : 'Minuten';
    return 'Ihre Ticketnummer $ticketNumber. '
        'Sie sind an Position $position. '
        'Geschätzte Wartezeit: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Achtung! Ihre Nummer $ticketNumber wurde aufgerufen! '
        'Bitte begeben Sie sich zu $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'Minute' : 'Minuten';
    return 'Geschätzte Wartezeit: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Sie sind an Position $position in der Warteschlange.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Nummer $ticketNumber, bitte zu $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'Patient wartet' : 'Patienten warten';
    final minText = avgWaitMinutes == 1 ? 'Minute' : 'Minuten';
    return '$waitingCount $patientText. '
        'Durchschnittliche Wartezeit: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'status',
        'mein status',
        'wie ist mein status',
        'ticket status',
      ];

  @override
  List<String> get waitTimeCommands => [
        'wartezeit',
        'wie lange',
        'wie lange noch',
        'wann bin ich dran',
      ];

  @override
  List<String> get positionCommands => [
        'position',
        'meine position',
        'welche position',
        'wo bin ich',
      ];

  @override
  List<String> get cancelCommands => [
        'abbrechen',
        'stornieren',
        'ticket löschen',
        'nicht mehr warten',
      ];

  @override
  List<String> get helpCommands => [
        'hilfe',
        'was kann ich sagen',
        'befehle',
        'optionen',
      ];

  @override
  List<String> get nextPatientCommands => [
        'nächster patient',
        'nächster',
        'aufrufen',
        'nächsten aufrufen',
      ];

  @override
  List<String> get patientDoneCommands => [
        'patient fertig',
        'fertig',
        'abschließen',
        'erledigt',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Halten zum Sprechen';

  @override
  String get listening => 'Höre zu...';

  @override
  String get processing => 'Verarbeite...';

  @override
  String get speakNow => 'Jetzt sprechen';

  @override
  String get voiceEnabled => 'Sprachfunktion aktiviert';

  @override
  String get voiceDisabled => 'Sprachfunktion deaktiviert';

  @override
  String get noMicrophonePermission =>
      'Mikrofonberechtigung erforderlich. Bitte in den Einstellungen erlauben.';

  @override
  String get speechRecognitionUnavailable =>
      'Spracherkennung nicht verfügbar auf diesem Gerät.';

  @override
  String get couldNotUnderstand =>
      'Das habe ich nicht verstanden. Bitte wiederholen.';

  // ============== SETTINGS ==============

  @override
  String get voiceSettingsTitle => 'Sprachfunktionen';

  @override
  String get enableVoice => 'Sprachfunktion aktivieren';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get selectVoice => 'Stimme auswählen';

  @override
  String get speechRate => 'Sprechgeschwindigkeit';

  @override
  String get volume => 'Lautstärke';

  @override
  String get testAnnouncement => 'Test-Ansage abspielen';

  // ============== ACCESSIBILITY ==============

  @override
  String ticketStatusSemantic({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Ticket $ticketNumber, Position $position, '
        'Wartezeit $waitMinutes Minuten';
  }

  @override
  String get commandNotRecognized =>
      'Befehl nicht erkannt. Sagen Sie "Hilfe" für Optionen.';

  @override
  String get ticketCancelled => 'Ihr Ticket wurde storniert.';

  @override
  String get confirmCancel => 'Möchten Sie Ihr Ticket wirklich stornieren?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get helpMessage =>
      'Sie können sagen: Status, Wartezeit, Position, Abbrechen oder Hilfe.';

  @override
  String get staffHelpMessage =>
      'Sie können sagen: Nächster Patient, Patient fertig oder Übersicht.';
}
