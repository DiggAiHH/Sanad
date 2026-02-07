import '../voice_strings.dart';

/// English voice strings implementation
class VoiceStringsEn extends VoiceStrings {
  const VoiceStringsEn();

  @override
  String get languageCode => 'en';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minute' : 'minutes';
    return 'Your ticket number is $ticketNumber. '
        'You are at position $position. '
        'Estimated wait time: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Attention! Your number $ticketNumber has been called! '
        'Please proceed to $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minute' : 'minutes';
    return 'Estimated wait time: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'You are at position $position in the queue.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Number $ticketNumber, please proceed to $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'patient waiting' : 'patients waiting';
    final minText = avgWaitMinutes == 1 ? 'minute' : 'minutes';
    return '$waitingCount $patientText. '
        'Average wait time: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'status',
        'my status',
        'what is my status',
        'ticket status',
      ];

  @override
  List<String> get waitTimeCommands => [
        'wait time',
        'how long',
        'how much longer',
        'when is my turn',
      ];

  @override
  List<String> get positionCommands => [
        'position',
        'my position',
        'what position',
        'where am i',
      ];

  @override
  List<String> get cancelCommands => [
        'cancel',
        'delete ticket',
        'stop waiting',
        'leave queue',
      ];

  @override
  List<String> get helpCommands => [
        'help',
        'what can i say',
        'commands',
        'options',
      ];

  @override
  List<String> get nextPatientCommands => [
        'next patient',
        'next',
        'call next',
        'call the next one',
      ];

  @override
  List<String> get patientDoneCommands => [
        'patient done',
        'done',
        'finish',
        'complete',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Hold to speak';

  @override
  String get listening => 'Listening...';

  @override
  String get processing => 'Processing...';

  @override
  String get speakNow => 'Speak now';

  @override
  String get voiceEnabled => 'Voice features enabled';

  @override
  String get voiceDisabled => 'Voice features disabled';

  @override
  String get noMicrophonePermission =>
      'Microphone permission required. Please allow in settings.';

  @override
  String get speechRecognitionUnavailable =>
      'Speech recognition not available on this device.';

  @override
  String get couldNotUnderstand =>
      'I did not understand that. Please try again.';

  // ============== SETTINGS ==============

  @override
  String get voiceSettingsTitle => 'Voice Features';

  @override
  String get enableVoice => 'Enable voice features';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get selectVoice => 'Select voice';

  @override
  String get speechRate => 'Speech rate';

  @override
  String get volume => 'Volume';

  @override
  String get testAnnouncement => 'Play test announcement';

  // ============== ACCESSIBILITY ==============

  @override
  String ticketStatusSemantic({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Ticket $ticketNumber, position $position, '
        'wait time $waitMinutes minutes';
  }
}
