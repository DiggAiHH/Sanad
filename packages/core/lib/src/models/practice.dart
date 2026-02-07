import 'package:freezed_annotation/freezed_annotation.dart';

part 'practice.freezed.dart';
part 'practice.g.dart';

/// Medical practice/clinic model
@freezed
class Practice with _$Practice {
  const factory Practice({
    required String id,
    required String name,
    required String address,
    required String city,
    required String postalCode,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    @Default([]) List<String> specializations,
    required PracticeSettings settings,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Practice;

  factory Practice.fromJson(Map<String, dynamic> json) =>
      _$PracticeFromJson(json);
}

/// Practice configuration settings
@freezed
class PracticeSettings with _$PracticeSettings {
  const factory PracticeSettings({
    @Default(true) bool qrCodeEnabled,
    @Default(true) bool nfcEnabled,
    @Default(30) int defaultAppointmentDuration,
    @Default('08:00') String openingTime,
    @Default('18:00') String closingTime,
    @Default([1, 2, 3, 4, 5]) List<int> workingDays, // 1=Mon, 7=Sun
    @Default('de') String defaultLanguage,
    @Default(true) bool patientEducationEnabled,
    @Default(true) bool videoContentEnabled,
  }) = _PracticeSettings;

  factory PracticeSettings.fromJson(Map<String, dynamic> json) =>
      _$PracticeSettingsFromJson(json);
}
