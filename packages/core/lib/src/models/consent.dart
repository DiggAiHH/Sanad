// =============================================================================
// CONSENT MODEL - DSGVO Article 7 Compliance
// =============================================================================
// Granulare Einwilligungsverwaltung mit Widerruf-Möglichkeit.
// Alle Consent-Änderungen werden mit Timestamp gespeichert.
// =============================================================================

import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent.freezed.dart';
part 'consent.g.dart';

/// Consent-Kategorien für verschiedene Datenverarbeitungszwecke
enum ConsentCategory {
  /// Grundlegende App-Funktion (erforderlich)
  essential,

  /// Medizinische Datenverarbeitung (Art. 9 DSGVO)
  medicalData,

  /// Telemedizin/Videosprechstunde
  telemedicine,

  /// Push-Benachrichtigungen
  pushNotifications,

  /// Analysedaten zur Verbesserung
  analytics,

  /// Datenweitergabe an Dritte (z.B. Labor)
  thirdPartySharing,

  /// Marketing-Kommunikation
  marketing,
}

/// Einzelne Einwilligung mit Zeitstempel
@freezed
class ConsentRecord with _$ConsentRecord {
  const factory ConsentRecord({
    required String id,
    required String patientId,
    required ConsentCategory category,
    required bool granted,
    required DateTime timestamp,
    required String version,
    String? ipAddress,
    String? userAgent,
    String? revokedAt,
    String? revokeReason,
  }) = _ConsentRecord;

  factory ConsentRecord.fromJson(Map<String, dynamic> json) =>
      _$ConsentRecordFromJson(json);
}

/// Zusammenfassung aller Einwilligungen eines Patienten
@freezed
class PatientConsents with _$PatientConsents {
  const factory PatientConsents({
    required String patientId,
    required List<ConsentRecord> consents,
    required DateTime lastUpdated,
  }) = _PatientConsents;

  factory PatientConsents.fromJson(Map<String, dynamic> json) =>
      _$PatientConsentsFromJson(json);
}

/// Consent Request für neue Einwilligung
@freezed
class ConsentRequest with _$ConsentRequest {
  const factory ConsentRequest({
    required ConsentCategory category,
    required bool granted,
    required String version,
  }) = _ConsentRequest;

  factory ConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$ConsentRequestFromJson(json);
}

/// Daten-Export-Anfrage (Art. 20 DSGVO - Datenportabilität)
@freezed
class DataExportRequest with _$DataExportRequest {
  const factory DataExportRequest({
    required String id,
    required String patientId,
    required DataExportFormat format,
    required DataExportStatus status,
    required DateTime requestedAt,
    DateTime? completedAt,
    String? downloadUrl,
    DateTime? expiresAt,
  }) = _DataExportRequest;

  factory DataExportRequest.fromJson(Map<String, dynamic> json) =>
      _$DataExportRequestFromJson(json);
}

enum DataExportFormat {
  json,
  pdf,
  xml,
  fhir,
}

enum DataExportStatus {
  pending,
  processing,
  ready,
  downloaded,
  expired,
  failed,
}

/// Daten-Löschungs-Anfrage (Art. 17 DSGVO - Recht auf Löschung)
@freezed
class DataDeletionRequest with _$DataDeletionRequest {
  const factory DataDeletionRequest({
    required String id,
    required String patientId,
    required DataDeletionStatus status,
    required DateTime requestedAt,
    required String reason,
    DateTime? scheduledAt,
    DateTime? completedAt,
    String? rejectionReason,
  }) = _DataDeletionRequest;

  factory DataDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$DataDeletionRequestFromJson(json);
}

enum DataDeletionStatus {
  pending,
  approved,
  scheduled,
  completed,
  rejected,
  partiallyCompleted,
}

/// Audit-Log für DSGVO-Compliance
@freezed
class PrivacyAuditLog with _$PrivacyAuditLog {
  const factory PrivacyAuditLog({
    required String id,
    required String patientId,
    required PrivacyAuditAction action,
    required DateTime timestamp,
    required String actorId,
    required String actorType,
    Map<String, dynamic>? details,
    String? ipAddress,
  }) = _PrivacyAuditLog;

  factory PrivacyAuditLog.fromJson(Map<String, dynamic> json) =>
      _$PrivacyAuditLogFromJson(json);
}

enum PrivacyAuditAction {
  consentGranted,
  consentRevoked,
  dataAccessed,
  dataExported,
  dataDeleted,
  dataModified,
  loginAttempt,
  passwordChanged,
  accountLocked,
}
