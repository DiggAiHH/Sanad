import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_request.freezed.dart';
part 'document_request.g.dart';

/// Arten von Dokumenten, die angefordert werden können.
enum DocumentType {
  @JsonValue('rezept')
  rezept,
  @JsonValue('ueberweisung')
  ueberweisung,
  @JsonValue('au_bescheinigung')
  auBescheinigung,
  @JsonValue('bescheinigung')
  bescheinigung,
  @JsonValue('befund')
  befund,
  @JsonValue('attest')
  attest,
  @JsonValue('sonstige')
  sonstige,
}

/// Status einer Dokumentenanfrage.
enum DocumentRequestStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_review')
  inReview,
  @JsonValue('approved')
  approved,
  @JsonValue('ready')
  ready,
  @JsonValue('delivered')
  delivered,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

/// Priorität einer Dokumentenanfrage.
enum DocumentRequestPriority {
  @JsonValue('normal')
  normal,
  @JsonValue('urgent')
  urgent,
  @JsonValue('express')
  express,
}

/// Liefermethode für Dokumente.
enum DeliveryMethod {
  @JsonValue('pickup')
  pickup,
  @JsonValue('email')
  email,
  @JsonValue('post')
  post,
  @JsonValue('digital_health')
  digitalHealth,
}

/// Eine Dokumentenanfrage eines Patienten.
@freezed
class DocumentRequest with _$DocumentRequest {
  const factory DocumentRequest({
    required String id,
    required String patientId,
    required String practiceId,
    required DocumentType documentType,
    required String title,
    String? description,
    required DocumentRequestStatus status,
    @Default(DocumentRequestPriority.normal)
    DocumentRequestPriority priority,
    @Default(DeliveryMethod.pickup) DeliveryMethod deliveryMethod,
    
    // Rezept-spezifische Felder
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    
    // Überweisung-spezifische Felder
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    
    // AU-spezifische Felder
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    
    // Allgemeine Felder
    String? purpose,
    String? additionalNotes,
    
    // Status-Tracking
    String? staffNotes,
    String? rejectionReason,
    String? processedById,
    DateTime? processedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    
    // Timestamps
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _DocumentRequest;

  factory DocumentRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentRequestFromJson(json);
}

/// Request zum Erstellen einer Dokumentenanfrage.
@freezed
class DocumentRequestCreate with _$DocumentRequestCreate {
  const factory DocumentRequestCreate({
    required DocumentType documentType,
    required String title,
    String? description,
    @Default(DocumentRequestPriority.normal)
    DocumentRequestPriority priority,
    @Default(DeliveryMethod.pickup) DeliveryMethod deliveryMethod,
    
    // Rezept-Felder
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    
    // Überweisung-Felder
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    
    // AU-Felder
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    
    // Allgemein
    String? purpose,
    String? additionalNotes,
  }) = _DocumentRequestCreate;

  factory DocumentRequestCreate.fromJson(Map<String, dynamic> json) =>
      _$DocumentRequestCreateFromJson(json);
}
