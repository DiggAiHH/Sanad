import '../voice_strings.dart';

/// Romanian voice strings implementation (Română)
class VoiceStringsRo extends VoiceStrings {
  const VoiceStringsRo();

  @override
  String get languageCode => 'ro';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'minut' : 'minute';
    return 'Numărul biletului dumneavoastră este $ticketNumber. '
        'Sunteți pe poziția $position. '
        'Timp de așteptare estimat: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Atenție! Numărul dumneavoastră $ticketNumber a fost chemat! '
        'Vă rugăm să vă prezentați la $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'minut' : 'minute';
    return 'Timp de așteptare estimat: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Sunteți pe poziția $position în coadă.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Numărul $ticketNumber, vă rugăm la $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'pacient așteaptă' : 'pacienți așteaptă';
    final minText = avgWaitMinutes == 1 ? 'minut' : 'minute';
    return '$waitingCount $patientText. '
        'Timp mediu de așteptare: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'stare',
        'starea mea',
        'care este starea',
        'stare bilet',
      ];

  @override
  List<String> get waitTimeCommands => [
        'timp de așteptare',
        'cât timp',
        'când îmi vine rândul',
        'cât mai durează',
      ];

  @override
  List<String> get positionCommands => [
        'poziție',
        'poziția mea',
        'unde sunt',
        'ce coadă',
      ];

  @override
  List<String> get cancelCommands => [
        'anulează',
        'anulare',
        'șterge bilet',
        'nu vreau să aștept',
      ];

  @override
  List<String> get helpCommands => [
        'ajutor',
        'ce pot spune',
        'comenzi',
        'opțiuni',
      ];

  @override
  List<String> get nextPatientCommands => [
        'următorul pacient',
        'următorul',
        'cheamă',
        'cheamă următorul',
      ];

  @override
  List<String> get patientDoneCommands => [
        'pacient gata',
        'gata',
        'finalizare',
        'terminat',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Țineți apăsat pentru a vorbi';

  @override
  String get listening => 'Ascult...';

  @override
  String get processing => 'Se procesează...';

  @override
  String get speakNow => 'Vorbiți acum';

  @override
  String get voiceEnabled => 'Funcția vocală activată';

  @override
  String get voiceDisabled => 'Funcția vocală dezactivată';

  @override
  String get noMicrophonePermission =>
      'Este necesară permisiunea pentru microfon. Vă rugăm să permiteți în setări.';

  @override
  String get speechRecognitionUnavailable =>
      'Recunoașterea vocală nu este disponibilă pe acest dispozitiv.';

  @override
  String get couldNotUnderstand => 'Nu am înțeles. Vă rugăm să încercați din nou.';

  @override
  String get commandNotRecognized =>
      'Comandă nerecunoscută. Spuneți "ajutor" pentru opțiuni.';

  @override
  String get ticketCancelled => 'Biletul dumneavoastră a fost anulat.';

  @override
  String get confirmCancel => 'Sunteți sigur că doriți să anulați biletul?';

  @override
  String get yes => 'Da';

  @override
  String get no => 'Nu';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Puteți spune: stare, timp de așteptare, poziție, anulează sau ajutor.';

  @override
  String get staffHelpMessage =>
      'Puteți spune: următorul pacient, pacient gata sau prezentare generală.';
}
