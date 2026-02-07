import '../voice_strings.dart';

/// Ukrainian voice strings implementation (Українська)
class VoiceStringsUk extends VoiceStrings {
  const VoiceStringsUk();

  @override
  String get languageCode => 'uk';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = _getMinuteWord(waitMinutes);
    return 'Ваш номер талона $ticketNumber. '
        'Ви на $position позиції. '
        'Орієнтовний час очікування: $waitMinutes $waitText.';
  }

  String _getMinuteWord(int minutes) {
    if (minutes % 10 == 1 && minutes % 100 != 11) {
      return 'хвилина';
    } else if ([2, 3, 4].contains(minutes % 10) &&
        ![12, 13, 14].contains(minutes % 100)) {
      return 'хвилини';
    } else {
      return 'хвилин';
    }
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Увага! Ваш номер $ticketNumber викликано! '
        'Будь ласка, пройдіть до $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = _getMinuteWord(minutes);
    return 'Орієнтовний час очікування: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Ви на $position позиції в черзі.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Номер $ticketNumber, будь ласка, пройдіть до $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = _getPatientWord(waitingCount);
    final minText = _getMinuteWord(avgWaitMinutes);
    return '$waitingCount $patientText очікує. '
        'Середній час очікування: $avgWaitMinutes $minText.';
  }

  String _getPatientWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'пацієнт';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'пацієнти';
    } else {
      return 'пацієнтів';
    }
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'статус',
        'мій статус',
        'який статус',
        'стан талона',
      ];

  @override
  List<String> get waitTimeCommands => [
        'час очікування',
        'скільки чекати',
        'коли моя черга',
        'як довго',
      ];

  @override
  List<String> get positionCommands => [
        'позиція',
        'моя позиція',
        'де я',
        'яка черга',
      ];

  @override
  List<String> get cancelCommands => [
        'скасувати',
        'відмінити',
        'видалити талон',
        'не хочу чекати',
      ];

  @override
  List<String> get helpCommands => [
        'допомога',
        'що сказати',
        'команди',
        'опції',
      ];

  @override
  List<String> get nextPatientCommands => [
        'наступний пацієнт',
        'наступний',
        'викликати',
        'викликати наступного',
      ];

  @override
  List<String> get patientDoneCommands => [
        'пацієнт готовий',
        'готово',
        'завершити',
        'виконано',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Утримуйте для розмови';

  @override
  String get listening => 'Слухаю...';

  @override
  String get processing => 'Обробка...';

  @override
  String get speakNow => 'Говоріть зараз';

  @override
  String get voiceEnabled => 'Голосову функцію увімкнено';

  @override
  String get voiceDisabled => 'Голосову функцію вимкнено';

  @override
  String get noMicrophonePermission =>
      'Потрібен дозвіл на мікрофон. Дозвольте в налаштуваннях.';

  @override
  String get speechRecognitionUnavailable =>
      'Розпізнавання мовлення недоступне на цьому пристрої.';

  @override
  String get couldNotUnderstand => 'Не вдалося розпізнати. Спробуйте знову.';

  @override
  String get commandNotRecognized =>
      'Команду не розпізнано. Скажіть "допомога" для опцій.';

  @override
  String get ticketCancelled => 'Ваш талон скасовано.';

  @override
  String get confirmCancel => 'Ви впевнені, що хочете скасувати талон?';

  @override
  String get yes => 'Так';

  @override
  String get no => 'Ні';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Ви можете сказати: статус, час очікування, позиція, скасувати або допомога.';

  @override
  String get staffHelpMessage =>
      'Ви можете сказати: наступний пацієнт, пацієнт готовий або огляд.';
}
