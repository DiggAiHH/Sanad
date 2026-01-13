import '../voice_strings.dart';

/// Vietnamese voice strings implementation (Tiếng Việt)
class VoiceStringsVi extends VoiceStrings {
  const VoiceStringsVi();

  @override
  String get languageCode => 'vi';

  // ============== TICKET STATUS ==============

  @override
  String ticketStatus({
    required String ticketNumber,
    required int position,
    required int waitMinutes,
  }) {
    return 'Số vé của bạn là $ticketNumber. '
        'Bạn đang ở vị trí $position. '
        'Thời gian chờ ước tính: $waitMinutes phút.';
  }

  @override
  String ticketCalled({
    required String ticketNumber,
    required String room,
  }) {
    return 'Chú ý! Số $ticketNumber của bạn đã được gọi! '
        'Vui lòng đến $room.';
  }

  @override
  String waitTime({required int minutes}) {
    return 'Thời gian chờ ước tính: $minutes phút.';
  }

  @override
  String position({required int position}) {
    return 'Bạn đang ở vị trí $position trong hàng đợi.';
  }

  // ============== QUEUE ANNOUNCEMENTS ==============

  @override
  String patientCall({
    required String ticketNumber,
    required String room,
  }) {
    return 'Số $ticketNumber, vui lòng đến $room.';
  }

  @override
  String queueStatus({
    required int waitingCount,
    required int avgWaitMinutes,
  }) {
    return '$waitingCount bệnh nhân đang chờ. '
        'Thời gian chờ trung bình: $avgWaitMinutes phút.';
  }

  // ============== COMMANDS ==============

  @override
  List<String> get statusCommands => [
        'trạng thái',
        'trạng thái của tôi',
        'tình trạng vé',
        'kiểm tra',
      ];

  @override
  List<String> get waitTimeCommands => [
        'thời gian chờ',
        'bao lâu',
        'khi nào đến lượt',
        'còn bao lâu',
      ];

  @override
  List<String> get positionCommands => [
        'vị trí',
        'vị trí của tôi',
        'tôi ở đâu',
        'thứ tự',
      ];

  @override
  List<String> get cancelCommands => [
        'hủy',
        'hủy bỏ',
        'xóa vé',
        'không muốn chờ',
      ];

  @override
  List<String> get helpCommands => [
        'trợ giúp',
        'giúp đỡ',
        'tôi nói gì',
        'lệnh',
      ];

  @override
  List<String> get nextPatientCommands => [
        'bệnh nhân tiếp theo',
        'tiếp theo',
        'gọi',
        'gọi tiếp',
      ];

  @override
  List<String> get patientDoneCommands => [
        'bệnh nhân xong',
        'xong',
        'hoàn thành',
        'kết thúc',
      ];

  // ============== UI STRINGS ==============

  @override
  String get holdToSpeak => 'Giữ để nói';

  @override
  String get listening => 'Đang nghe...';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get speakNow => 'Nói ngay bây giờ';

  @override
  String get voiceEnabled => 'Chức năng giọng nói đã bật';

  @override
  String get voiceDisabled => 'Chức năng giọng nói đã tắt';

  @override
  String get noMicrophonePermission =>
      'Cần quyền truy cập microphone. Vui lòng cho phép trong cài đặt.';

  @override
  String get speechRecognitionUnavailable =>
      'Nhận dạng giọng nói không khả dụng trên thiết bị này.';

  @override
  String get couldNotUnderstand => 'Không hiểu. Vui lòng thử lại.';

  @override
  String get commandNotRecognized =>
      'Lệnh không được nhận dạng. Nói "trợ giúp" để xem các tùy chọn.';

  @override
  String get ticketCancelled => 'Vé của bạn đã bị hủy.';

  @override
  String get confirmCancel => 'Bạn có chắc muốn hủy vé không?';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  // ============== HELP ==============

  @override
  String get helpMessage =>
      'Bạn có thể nói: trạng thái, thời gian chờ, vị trí, hủy hoặc trợ giúp.';

  @override
  String get staffHelpMessage =>
      'Bạn có thể nói: bệnh nhân tiếp theo, bệnh nhân xong hoặc tổng quan.';
}
