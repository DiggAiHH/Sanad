import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User roles in the Sanad system
enum UserRole {
  @JsonValue('admin')
  admin,
  @JsonValue('doctor')
  doctor,
  @JsonValue('mfa')
  mfa, // Medizinische Fachassistentin
  @JsonValue('staff')
  staff,
  @JsonValue('patient')
  patient,
}

/// Base user model for all Sanad apps
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? phoneNumber,
    String? avatarUrl,
    required String practiceId,
    @Default(true) bool isActive,
    DateTime? lastLoginAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Extension for display name
extension UserExtension on User {
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}
