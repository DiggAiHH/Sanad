import '../voice_strings.dart';

/// Persian/Farsi voice strings implementation (فارسی)
class VoiceStringsFa extends VoiceStrings {
  const VoiceStringsFa();

  @override
  String get languageCode => 'fa';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'شماره نوبت شما $ticketNumber است. '
        'شما در جایگاه $position هستید. '
        'زمان انتظار تخمینی: $waitMinutes دقیقه.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'توجه! شماره $ticketNumber فراخوانده شد! '
        'لطفاً به $room مراجعه کنید.';
  }

  @override
  String waitTime({required int minutes}) {
    return 'زمان انتظار تخمینی: $minutes دقیقه.';
  }

  @override
  String position({required int position}) {
    return 'شما در جایگاه $position در صف هستید.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'شماره $ticketNumber، لطفاً به $room مراجعه کنید.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    return '$waitingCount بیمار در انتظار. '
        'میانگین زمان انتظار: $avgWaitMinutes دقیقه.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'وضعیت',
        'وضعیت من',
        'وضعیت نوبت',
        'چه خبر',
      ];

  @override
  List<String> get waitTimeCommands => [
        'زمان انتظار',
        'چقدر صبر کنم',
        'کی نوبتم میشه',
        'چقدر مونده',
      ];

  @override
  List<String> get positionCommands => [
        'جایگاه',
        'جایگاه من',
        'کجام',
        'ردیف',
      ];

  @override
  List<String> get cancelCommands => [
        'لغو',
        'کنسل',
        'حذف نوبت',
        'نمیخوام صبر کنم',
      ];

  @override
  List<String> get helpCommands => [
        'کمک',
        'راهنما',
        'چی بگم',
        'دستورات',
      ];

  @override
  List<String> get nextPatientCommands => [
        'بیمار بعدی',
        'بعدی',
        'صدا بزن',
        'فراخوان',
      ];

  @override
  List<String> get patientDoneCommands => [
        'بیمار تمام',
        'تمام',
        'پایان',
        'انجام شد',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'برای صحبت نگه دارید';

  @override
  String get listening => 'در حال گوش دادن...';

  @override
  String get processing => 'در حال پردازش...';

  @override
  String get speakNow => 'الان صحبت کنید';

  @override
  String get voiceEnabled => 'قابلیت صوتی فعال شد';

  @override
  String get voiceDisabled => 'قابلیت صوتی غیرفعال شد';

  @override
  String get noMicrophonePermission =>
      'نیاز به دسترسی میکروفون است. لطفاً در تنظیمات اجازه دهید.';

  @override
  String get speechRecognitionUnavailable =>
      'تشخیص گفتار در این دستگاه در دسترس نیست.';

  @override
  String get couldNotUnderstand => 'متوجه نشدم. لطفاً دوباره تلاش کنید.';

  @override
  String get commandNotRecognized =>
      'دستور شناخته نشد. بگویید "کمک" برای گزینه‌ها.';

  @override
  String get ticketCancelled => 'نوبت شما لغو شد.';

  @override
  String get confirmCancel => 'آیا مطمئنید که می‌خواهید نوبت را لغو کنید؟';

  @override
  String get yes => 'بله';

  @override
  String get no => 'خیر';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'می‌توانید بگویید: وضعیت، زمان انتظار، جایگاه، لغو یا کمک.';

  @override
  String get staffHelpMessage =>
      'می‌توانید بگویید: بیمار بعدی، بیمار تمام یا نمای کلی.';
}
