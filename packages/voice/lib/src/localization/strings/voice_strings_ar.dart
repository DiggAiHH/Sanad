import '../voice_strings.dart';

/// Arabic voice strings implementation (العربية)
class VoiceStringsAr extends VoiceStrings {
  const VoiceStringsAr();

  @override
  String get languageCode => 'ar';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    final waitText = waitMinutes == 1 ? 'دقيقة' : 'دقائق';
    return 'رقم تذكرتك $ticketNumber. '
        'أنت في المركز $position. '
        'وقت الانتظار المتوقع: $waitMinutes $waitText.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'انتباه! تم استدعاء رقمك $ticketNumber! '
        'يرجى التوجه إلى $room.';
  }

  @override
  String waitTime({required int minutes}) {
    final text = minutes == 1 ? 'دقيقة' : 'دقائق';
    return 'وقت الانتظار المتوقع: $minutes $text.';
  }

  @override
  String position({required int position}) {
    return 'أنت في المركز $position في قائمة الانتظار.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'الرقم $ticketNumber، يرجى التوجه إلى $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    final patientText = waitingCount == 1 ? 'مريض ينتظر' : 'مرضى ينتظرون';
    final minText = avgWaitMinutes == 1 ? 'دقيقة' : 'دقائق';
    return '$waitingCount $patientText. '
        'متوسط وقت الانتظار: $avgWaitMinutes $minText.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'الحالة',
        'حالتي',
        'ما هي حالتي',
        'حالة التذكرة',
      ];

  @override
  List<String> get waitTimeCommands => [
        'وقت الانتظار',
        'كم الوقت',
        'متى دوري',
        'كم باقي',
      ];

  @override
  List<String> get positionCommands => [
        'الموقع',
        'موقعي',
        'أين أنا',
        'ترتيبي',
      ];

  @override
  List<String> get cancelCommands => [
        'إلغاء',
        'ألغِ التذكرة',
        'لا أريد الانتظار',
        'احذف',
      ];

  @override
  List<String> get helpCommands => [
        'مساعدة',
        'ماذا أقول',
        'الأوامر',
        'خيارات',
      ];

  @override
  List<String> get nextPatientCommands => [
        'المريض التالي',
        'التالي',
        'استدعاء',
        'استدعِ التالي',
      ];

  @override
  List<String> get patientDoneCommands => [
        'المريض انتهى',
        'انتهى',
        'إنهاء',
        'تم',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'اضغط مع الاستمرار للتحدث';

  @override
  String get listening => 'جارٍ الاستماع...';

  @override
  String get processing => 'جارٍ المعالجة...';

  @override
  String get speakNow => 'تحدث الآن';

  @override
  String get voiceEnabled => 'تم تفعيل الصوت';

  @override
  String get voiceDisabled => 'تم إلغاء تفعيل الصوت';

  @override
  String get noMicrophonePermission =>
      'مطلوب إذن الميكروفون. يرجى السماح في الإعدادات.';

  @override
  String get speechRecognitionUnavailable =>
      'التعرف على الكلام غير متاح على هذا الجهاز.';

  @override
  String get couldNotUnderstand => 'لم أستطع الفهم. يرجى المحاولة مرة أخرى.';

  @override
  String get commandNotRecognized => 'الأمر غير معروف. قل "مساعدة" للخيارات.';

  @override
  String get ticketCancelled => 'تم إلغاء تذكرتك.';

  @override
  String get confirmCancel => 'هل أنت متأكد أنك تريد إلغاء تذكرتك؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'يمكنك قول: الحالة، وقت الانتظار، الموقع، إلغاء، أو مساعدة.';

  @override
  String get staffHelpMessage =>
      'يمكنك قول: المريض التالي، المريض انتهى، أو نظرة عامة.';
}
