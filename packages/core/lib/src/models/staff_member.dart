import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'staff_member.freezed.dart';
part 'staff_member.g.dart';

/// Staff member specialization
enum Specialization {
  @JsonValue('general')
  general,
  @JsonValue('cardiology')
  cardiology,
  @JsonValue('dermatology')
  dermatology,
  @JsonValue('orthopedics')
  orthopedics,
  @JsonValue('pediatrics')
  pediatrics,
  @JsonValue('neurology')
  neurology,
  @JsonValue('ophthalmology')
  ophthalmology,
  @JsonValue('other')
  other,
}

/// Staff member model (Doctor, MFA, etc.)
@freezed
class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String id,
    required User user,
    String? title, // Dr., Prof., etc.
    Specialization? specialization,
    String? roomNumber,
    @Default(true) bool acceptingPatients,
    @Default([]) List<String> qualifications,
    String? bio,
    @Default(true) bool isAvailable,
    DateTime? availableFrom,
    DateTime? availableUntil,
  }) = _StaffMember;

  factory StaffMember.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberFromJson(json);
}

extension StaffMemberExtension on StaffMember {
  String get displayName {
    final t = title ?? '';
    return '$t ${user.fullName}'.trim();
  }
}
