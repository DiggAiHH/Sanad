import '../voice_strings.dart';

/// Urdu voice strings implementation (اردو)
class VoiceStringsUr extends VoiceStrings {
  const VoiceStringsUr();

  @override
  String get languageCode => 'ur';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'آپ کا ٹکٹ نمبر $ticketNumber ہے۔ '
        'آپ $position پوزیشن پر ہیں۔ '
        'تخمینی انتظار کا وقت: $waitMinutes منٹ۔';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'توجہ! آپ کا نمبر $ticketNumber بلایا گیا! '
        'براہ کرم $room میں تشریف لائیں۔';
  }

  @override
  String waitTime({required int minutes}) {
    return 'تخمینی انتظار کا وقت: $minutes منٹ۔';
  }

  @override
  String position({required int position}) {
    return 'آپ قطار میں $position پوزیشن پر ہیں۔';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'نمبر $ticketNumber، براہ کرم $room میں آئیں۔';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    return '$waitingCount مریض انتظار میں ہیں۔ '
        'اوسط انتظار کا وقت: $avgWaitMinutes منٹ۔';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'حالت',
        'میری حالت',
        'ٹکٹ کی حالت',
        'کیا ہو رہا ہے',
      ];

  @override
  List<String> get waitTimeCommands => [
        'انتظار کا وقت',
        'کتنا انتظار',
        'میری باری کب',
        'کتنا وقت',
      ];

  @override
  List<String> get positionCommands => [
        'پوزیشن',
        'میری پوزیشن',
        'میں کہاں ہوں',
        'قطار',
      ];

  @override
  List<String> get cancelCommands => [
        'منسوخ',
        'کینسل',
        'ٹکٹ حذف',
        'انتظار نہیں کرنا',
      ];

  @override
  List<String> get helpCommands => [
        'مدد',
        'کیا کہوں',
        'احکامات',
        'اختیارات',
      ];

  @override
  List<String> get nextPatientCommands => [
        'اگلا مریض',
        'اگلا',
        'بلاؤ',
        'اگلے کو بلاؤ',
      ];

  @override
  List<String> get patientDoneCommands => [
        'مریض ہو گیا',
        'ہو گیا',
        'مکمل',
        'تیار',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'بولنے کے لیے دبائے رکھیں';

  @override
  String get listening => 'سن رہا ہوں...';

  @override
  String get processing => 'پروسیسنگ...';

  @override
  String get speakNow => 'ابھی بولیں';

  @override
  String get voiceEnabled => 'آواز فعال ہو گئی';

  @override
  String get voiceDisabled => 'آواز غیر فعال ہو گئی';

  @override
  String get noMicrophonePermission =>
      'مائیکروفون کی اجازت درکار ہے۔ براہ کرم سیٹنگز میں اجازت دیں۔';

  @override
  String get speechRecognitionUnavailable =>
      'اس آلے پر تقریر کی پہچان دستیاب نہیں ہے۔';

  @override
  String get couldNotUnderstand => 'سمجھ نہیں آیا۔ براہ کرم دوبارہ کوشش کریں۔';

  @override
  String get commandNotRecognized =>
      'حکم پہچانا نہیں گیا۔ "مدد" کہیں اختیارات کے لیے۔';

  @override
  String get ticketCancelled => 'آپ کا ٹکٹ منسوخ ہو گیا۔';

  @override
  String get confirmCancel => 'کیا آپ واقعی ٹکٹ منسوخ کرنا چاہتے ہیں؟';

  @override
  String get yes => 'ہاں';

  @override
  String get no => 'نہیں';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'آپ کہہ سکتے ہیں: حالت، انتظار کا وقت، پوزیشن، منسوخ یا مدد۔';

  @override
  String get staffHelpMessage =>
      'آپ کہہ سکتے ہیں: اگلا مریض، مریض ہو گیا یا جائزہ۔';
}
