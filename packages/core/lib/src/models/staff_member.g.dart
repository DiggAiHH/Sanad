// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StaffMemberImpl _$$StaffMemberImplFromJson(Map<String, dynamic> json) => _$StaffMemberImpl(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      title: json['title'] as String?,
      specialization: $enumDecodeNullable(_$SpecializationEnumMap, json['specialization']),
      roomNumber: json['roomNumber'] as String?,
      acceptingPatients: json['acceptingPatients'] as bool? ?? true,
      qualifications: (json['qualifications'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      bio: json['bio'] as String?,
      isAvailable: json['isAvailable'] as bool? ?? true,
      availableFrom: json['availableFrom'] == null ? null : DateTime.parse(json['availableFrom'] as String),
      availableUntil: json['availableUntil'] == null ? null : DateTime.parse(json['availableUntil'] as String),
    );

Map<String, dynamic> _$$StaffMemberImplToJson(_$StaffMemberImpl instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user.toJson(),
      'title': instance.title,
      'specialization': _$SpecializationEnumMap[instance.specialization],
      'roomNumber': instance.roomNumber,
      'acceptingPatients': instance.acceptingPatients,
      'qualifications': instance.qualifications,
      'bio': instance.bio,
      'isAvailable': instance.isAvailable,
      'availableFrom': instance.availableFrom?.toIso8601String(),
      'availableUntil': instance.availableUntil?.toIso8601String(),
    };

const _$SpecializationEnumMap = {
  Specialization.general: 'general',
  Specialization.cardiology: 'cardiology',
  Specialization.dermatology: 'dermatology',
  Specialization.orthopedics: 'orthopedics',
  Specialization.pediatrics: 'pediatrics',
  Specialization.neurology: 'neurology',
  Specialization.ophthalmology: 'ophthalmology',
  Specialization.other: 'other',
};
