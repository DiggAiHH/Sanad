import '../voice_strings.dart';

/// Polish voice strings implementation (Polski)
class VoiceStringsPl extends VoiceStrings {
  const VoiceStringsPl();

  @override
  String get languageCode => 'pl';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = _getMinuteWord(waitMinutes);
    return 'Twój numer biletu to $ticketNumber. '
        'Jesteś na pozycji $position. '
        'Szacowany czas oczekiwania: $waitMinutes $waitText.';
  }

  String _getMinuteWord(int minutes) {
    if (minutes == 1) {
      return 'minuta';
    } else if ([2, 3, 4].contains(minutes % 10) &&
        ![12, 13, 14].contains(minutes % 100)) {
      return 'minuty';
    } else {
      return 'minut';
    }
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Uwaga! Twój numer $ticketNumber został wywołany! '
        'Proszę udać się do $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = _getMinuteWord(minutes);
    return 'Szacowany czas oczekiwania: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Jesteś na pozycji $position w kolejce.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Numer $ticketNumber, proszę do $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = _getPatientWord(waitingCount);
    final minText = _getMinuteWord(avgWaitMinutes);
    return '$waitingCount $patientText czeka. '
        'Średni czas oczekiwania: $avgWaitMinutes $minText.';
  }

  String _getPatientWord(int count) {
    if (count == 1) {
      return 'pacjent';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'pacjentów';
    } else {
      return 'pacjentów';
    }
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'status',
        'mój status',
        'jaki jest mój status',
        'status biletu',
      ];

  @override
  List<String> get waitTimeCommands => [
        'czas oczekiwania',
        'ile czekać',
        'kiedy moja kolej',
        'jak długo',
      ];

  @override
  List<String> get positionCommands => [
        'pozycja',
        'moja pozycja',
        'gdzie jestem',
        'która kolejka',
      ];

  @override
  List<String> get cancelCommands => [
        'anuluj',
        'anulować',
        'usuń bilet',
        'nie chcę czekać',
      ];

  @override
  List<String> get helpCommands => [
        'pomoc',
        'co mogę powiedzieć',
        'komendy',
        'opcje',
      ];

  @override
  List<String> get nextPatientCommands => [
        'następny pacjent',
        'następny',
        'wywołaj',
        'wywołaj następnego',
      ];

  @override
  List<String> get patientDoneCommands => [
        'pacjent gotowy',
        'gotowe',
        'zakończ',
        'wykonane',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Przytrzymaj, aby mówić';

  @override
  String get listening => 'Słucham...';

  @override
  String get processing => 'Przetwarzanie...';

  @override
  String get speakNow => 'Mów teraz';

  @override
  String get voiceEnabled => 'Funkcja głosowa włączona';

  @override
  String get voiceDisabled => 'Funkcja głosowa wyłączona';

  @override
  String get noMicrophonePermission =>
      'Wymagane uprawnienie do mikrofonu. Zezwól w ustawieniach.';

  @override
  String get speechRecognitionUnavailable =>
      'Rozpoznawanie mowy niedostępne na tym urządzeniu.';

  @override
  String get couldNotUnderstand => 'Nie zrozumiałem. Spróbuj ponownie.';

  @override
  String get commandNotRecognized =>
      'Nierozpoznane polecenie. Powiedz "pomoc" dla opcji.';

  @override
  String get ticketCancelled => 'Twój bilet został anulowany.';

  @override
  String get confirmCancel => 'Czy na pewno chcesz anulować bilet?';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Możesz powiedzieć: status, czas oczekiwania, pozycja, anuluj lub pomoc.';

  @override
  String get staffHelpMessage =>
      'Możesz powiedzieć: następny pacjent, pacjent gotowy lub przegląd.';
}
