import '../voice_strings.dart';

/// Russian voice strings implementation (Русский)
class VoiceStringsRu extends VoiceStrings {
  const VoiceStringsRu();

  @override
  String get languageCode => 'ru';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = _getMinuteWord(waitMinutes);
    return 'Ваш номер талона $ticketNumber. '
        'Вы на $position позиции. '
        'Ориентировочное время ожидания: $waitMinutes $waitText.';
  }

  String _getMinuteWord(int minutes) {
    if (minutes % 10 == 1 && minutes % 100 != 11) {
      return 'минута';
    } else if ([2, 3, 4].contains(minutes % 10) &&
        ![12, 13, 14].contains(minutes % 100)) {
      return 'минуты';
    } else {
      return 'минут';
    }
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Внимание! Ваш номер $ticketNumber вызван! '
        'Пожалуйста, пройдите в $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = _getMinuteWord(minutes);
    return 'Ориентировочное время ожидания: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'Вы на $position позиции в очереди.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Номер $ticketNumber, пожалуйста, пройдите в $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = _getPatientWord(waitingCount);
    final minText = _getMinuteWord(avgWaitMinutes);
    return '$waitingCount $patientText ожидает. '
        'Среднее время ожидания: $avgWaitMinutes $minText.';
  }

  String _getPatientWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'пациент';
    } else if ([2, 3, 4].contains(count % 10) &&
        ![12, 13, 14].contains(count % 100)) {
      return 'пациента';
    } else {
      return 'пациентов';
    }
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'статус',
        'мой статус',
        'какой статус',
        'состояние талона',
      ];

  @override
  List<String> get waitTimeCommands => [
        'время ожидания',
        'сколько ждать',
        'когда моя очередь',
        'как долго',
      ];

  @override
  List<String> get positionCommands => [
        'позиция',
        'моя позиция',
        'где я',
        'какая очередь',
      ];

  @override
  List<String> get cancelCommands => [
        'отмена',
        'отменить',
        'удалить талон',
        'не хочу ждать',
      ];

  @override
  List<String> get helpCommands => [
        'помощь',
        'что сказать',
        'команды',
        'опции',
      ];

  @override
  List<String> get nextPatientCommands => [
        'следующий пациент',
        'следующий',
        'вызвать',
        'вызвать следующего',
      ];

  @override
  List<String> get patientDoneCommands => [
        'пациент готов',
        'готово',
        'завершить',
        'выполнено',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Удерживайте для разговора';

  @override
  String get listening => 'Слушаю...';

  @override
  String get processing => 'Обработка...';

  @override
  String get speakNow => 'Говорите сейчас';

  @override
  String get voiceEnabled => 'Голосовая функция включена';

  @override
  String get voiceDisabled => 'Голосовая функция выключена';

  @override
  String get noMicrophonePermission =>
      'Требуется разрешение на микрофон. Разрешите в настройках.';

  @override
  String get speechRecognitionUnavailable =>
      'Распознавание речи недоступно на этом устройстве.';

  @override
  String get couldNotUnderstand => 'Не удалось распознать. Попробуйте снова.';

  @override
  String get commandNotRecognized =>
      'Команда не распознана. Скажите "помощь" для опций.';

  @override
  String get ticketCancelled => 'Ваш талон отменен.';

  @override
  String get confirmCancel => 'Вы уверены, что хотите отменить талон?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Вы можете сказать: статус, время ожидания, позиция, отмена или помощь.';

  @override
  String get staffHelpMessage =>
      'Вы можете сказать: следующий пациент, пациент готов или обзор.';
}
