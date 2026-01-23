// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DocumentRequestImpl _$$DocumentRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentRequestImpl(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      practiceId: json['practice_id'] as String,
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['document_type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: $enumDecode(_$DocumentRequestStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(
              _$DocumentRequestPriorityEnumMap, json['priority']) ??
          DocumentRequestPriority.normal,
      deliveryMethod: $enumDecodeNullable(
              _$DeliveryMethodEnumMap, json['delivery_method']) ??
          DeliveryMethod.pickup,
      medicationName: json['medication_name'] as String?,
      medicationDosage: json['medication_dosage'] as String?,
      medicationQuantity: (json['medication_quantity'] as num?)?.toInt(),
      referralSpecialty: json['referral_specialty'] as String?,
      referralReason: json['referral_reason'] as String?,
      preferredDoctor: json['preferred_doctor'] as String?,
      auStartDate: json['au_start_date'] == null
          ? null
          : DateTime.parse(json['au_start_date'] as String),
      auEndDate: json['au_end_date'] == null
          ? null
          : DateTime.parse(json['au_end_date'] as String),
      auReason: json['au_reason'] as String?,
      purpose: json['purpose'] as String?,
      additionalNotes: json['additional_notes'] as String?,
      staffNotes: json['staff_notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      processedById: json['processed_by_id'] as String?,
      processedAt: json['processed_at'] == null
          ? null
          : DateTime.parse(json['processed_at'] as String),
      readyAt: json['ready_at'] == null
          ? null
          : DateTime.parse(json['ready_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$DocumentRequestImplToJson(
        _$DocumentRequestImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'practice_id': instance.practiceId,
      'document_type': _$DocumentTypeEnumMap[instance.documentType]!,
      'title': instance.title,
      'description': instance.description,
      'status': _$DocumentRequestStatusEnumMap[instance.status]!,
      'priority': _$DocumentRequestPriorityEnumMap[instance.priority]!,
      'delivery_method': _$DeliveryMethodEnumMap[instance.deliveryMethod]!,
      'medication_name': instance.medicationName,
      'medication_dosage': instance.medicationDosage,
      'medication_quantity': instance.medicationQuantity,
      'referral_specialty': instance.referralSpecialty,
      'referral_reason': instance.referralReason,
      'preferred_doctor': instance.preferredDoctor,
      'au_start_date': instance.auStartDate?.toIso8601String(),
      'au_end_date': instance.auEndDate?.toIso8601String(),
      'au_reason': instance.auReason,
      'purpose': instance.purpose,
      'additional_notes': instance.additionalNotes,
      'staff_notes': instance.staffNotes,
      'rejection_reason': instance.rejectionReason,
      'processed_by_id': instance.processedById,
      'processed_at': instance.processedAt?.toIso8601String(),
      'ready_at': instance.readyAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$DocumentTypeEnumMap = {
  DocumentType.rezept: 'rezept',
  DocumentType.ueberweisung: 'ueberweisung',
  DocumentType.auBescheinigung: 'au_bescheinigung',
  DocumentType.bescheinigung: 'bescheinigung',
  DocumentType.befund: 'befund',
  DocumentType.attest: 'attest',
  DocumentType.sonstige: 'sonstige',
};

const _$DocumentRequestStatusEnumMap = {
  DocumentRequestStatus.pending: 'pending',
  DocumentRequestStatus.inReview: 'in_review',
  DocumentRequestStatus.approved: 'approved',
  DocumentRequestStatus.ready: 'ready',
  DocumentRequestStatus.delivered: 'delivered',
  DocumentRequestStatus.rejected: 'rejected',
  DocumentRequestStatus.cancelled: 'cancelled',
};

const _$DocumentRequestPriorityEnumMap = {
  DocumentRequestPriority.normal: 'normal',
  DocumentRequestPriority.urgent: 'urgent',
  DocumentRequestPriority.express: 'express',
};

const _$DeliveryMethodEnumMap = {
  DeliveryMethod.pickup: 'pickup',
  DeliveryMethod.email: 'email',
  DeliveryMethod.post: 'post',
  DeliveryMethod.digitalHealth: 'digital_health',
};

_$DocumentRequestCreateImpl _$$DocumentRequestCreateImplFromJson(
        Map<String, dynamic> json) =>
    _$DocumentRequestCreateImpl(
      documentType: $enumDecode(_$DocumentTypeEnumMap, json['document_type']),
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: $enumDecodeNullable(
              _$DocumentRequestPriorityEnumMap, json['priority']) ??
          DocumentRequestPriority.normal,
      deliveryMethod: $enumDecodeNullable(
              _$DeliveryMethodEnumMap, json['delivery_method']) ??
          DeliveryMethod.pickup,
      medicationName: json['medication_name'] as String?,
      medicationDosage: json['medication_dosage'] as String?,
      medicationQuantity: (json['medication_quantity'] as num?)?.toInt(),
      referralSpecialty: json['referral_specialty'] as String?,
      referralReason: json['referral_reason'] as String?,
      preferredDoctor: json['preferred_doctor'] as String?,
      auStartDate: json['au_start_date'] == null
          ? null
          : DateTime.parse(json['au_start_date'] as String),
      auEndDate: json['au_end_date'] == null
          ? null
          : DateTime.parse(json['au_end_date'] as String),
      auReason: json['au_reason'] as String?,
      purpose: json['purpose'] as String?,
      additionalNotes: json['additional_notes'] as String?,
    );

Map<String, dynamic> _$$DocumentRequestCreateImplToJson(
        _$DocumentRequestCreateImpl instance) =>
    <String, dynamic>{
      'document_type': _$DocumentTypeEnumMap[instance.documentType]!,
      'title': instance.title,
      'description': instance.description,
      'priority': _$DocumentRequestPriorityEnumMap[instance.priority]!,
      'delivery_method': _$DeliveryMethodEnumMap[instance.deliveryMethod]!,
      'medication_name': instance.medicationName,
      'medication_dosage': instance.medicationDosage,
      'medication_quantity': instance.medicationQuantity,
      'referral_specialty': instance.referralSpecialty,
      'referral_reason': instance.referralReason,
      'preferred_doctor': instance.preferredDoctor,
      'au_start_date': instance.auStartDate?.toIso8601String(),
      'au_end_date': instance.auEndDate?.toIso8601String(),
      'au_reason': instance.auReason,
      'purpose': instance.purpose,
      'additional_notes': instance.additionalNotes,
    };
