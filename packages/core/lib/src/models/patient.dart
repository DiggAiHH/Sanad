import 'package:freezed_annotation/freezed_annotation.dart';
import 'user.dart';

part 'patient.freezed.dart';
part 'patient.g.dart';

/// Insurance type
enum InsuranceType {
  @JsonValue('public')
  public, // Gesetzlich
  @JsonValue('private')
  private, // Privat
  @JsonValue('self_pay')
  selfPay,
}

/// Patient model
@freezed
class Patient with _$Patient {
  const factory Patient({
    required String id,
    required User user,
    required DateTime dateOfBirth,
    String? insuranceNumber,
    InsuranceType? insuranceType,
    String? insuranceProvider,
    String? emergencyContactName,
    String? emergencyContactPhone,
    @Default([]) List<String> allergies,
    @Default([]) List<String> medications,
    String? notes,
    @Default(false) bool hasConsentForms,
    DateTime? lastVisit,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
}

extension PatientExtension on Patient {
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
