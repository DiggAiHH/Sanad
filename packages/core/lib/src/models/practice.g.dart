// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PracticeImpl _$$PracticeImplFromJson(Map<String, dynamic> json) =>
    _$PracticeImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      postalCode: json['postalCode'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      logoUrl: json['logoUrl'] as String?,
      specializations: (json['specializations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      settings:
          PracticeSettings.fromJson(json['settings'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PracticeImplToJson(_$PracticeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'postalCode': instance.postalCode,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'website': instance.website,
      'logoUrl': instance.logoUrl,
      'specializations': instance.specializations,
      'settings': instance.settings,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PracticeSettingsImpl _$$PracticeSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$PracticeSettingsImpl(
      qrCodeEnabled: json['qrCodeEnabled'] as bool? ?? true,
      nfcEnabled: json['nfcEnabled'] as bool? ?? true,
      defaultAppointmentDuration:
          (json['defaultAppointmentDuration'] as num?)?.toInt() ?? 30,
      openingTime: json['openingTime'] as String? ?? '08:00',
      closingTime: json['closingTime'] as String? ?? '18:00',
      workingDays: (json['workingDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5],
      defaultLanguage: json['defaultLanguage'] as String? ?? 'de',
      patientEducationEnabled: json['patientEducationEnabled'] as bool? ?? true,
      videoContentEnabled: json['videoContentEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$PracticeSettingsImplToJson(
        _$PracticeSettingsImpl instance) =>
    <String, dynamic>{
      'qrCodeEnabled': instance.qrCodeEnabled,
      'nfcEnabled': instance.nfcEnabled,
      'defaultAppointmentDuration': instance.defaultAppointmentDuration,
      'openingTime': instance.openingTime,
      'closingTime': instance.closingTime,
      'workingDays': instance.workingDays,
      'defaultLanguage': instance.defaultLanguage,
      'patientEducationEnabled': instance.patientEducationEnabled,
      'videoContentEnabled': instance.videoContentEnabled,
    };
