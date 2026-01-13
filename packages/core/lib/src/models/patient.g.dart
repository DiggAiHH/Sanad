// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) => _$PatientImpl(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      insuranceNumber: json['insuranceNumber'] as String?,
      insuranceType: $enumDecodeNullable(_$InsuranceTypeEnumMap, json['insuranceType']),
      insuranceProvider: json['insuranceProvider'] as String?,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      medications: (json['medications'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      notes: json['notes'] as String?,
      hasConsentForms: json['hasConsentForms'] as bool? ?? false,
      lastVisit: json['lastVisit'] == null ? null : DateTime.parse(json['lastVisit'] as String),
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user.toJson(),
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'insuranceNumber': instance.insuranceNumber,
      'insuranceType': _$InsuranceTypeEnumMap[instance.insuranceType],
      'insuranceProvider': instance.insuranceProvider,
      'emergencyContactName': instance.emergencyContactName,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'allergies': instance.allergies,
      'medications': instance.medications,
      'notes': instance.notes,
      'hasConsentForms': instance.hasConsentForms,
      'lastVisit': instance.lastVisit?.toIso8601String(),
    };

const _$InsuranceTypeEnumMap = {
  InsuranceType.public: 'public',
  InsuranceType.private: 'private',
  InsuranceType.selfPay: 'self_pay',
};
