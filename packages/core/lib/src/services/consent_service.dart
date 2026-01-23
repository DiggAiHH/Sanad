// =============================================================================
// CONSENT SERVICE - DSGVO Compliance
// =============================================================================
// Service für Einwilligungsverwaltung, Datenexport und Löschung.
// Art. 7, 17, 20 DSGVO konform.
// =============================================================================

import 'package:dio/dio.dart';
import '../models/consent.dart';

/// Service für DSGVO-konforme Einwilligungsverwaltung
class ConsentService {
  final Dio _dio;
  final String _baseUrl;

  ConsentService({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  // ===========================================================================
  // CONSENT MANAGEMENT (Art. 7 DSGVO)
  // ===========================================================================

  /// Holt alle Einwilligungen eines Patienten
  Future<PatientConsents> getConsents() async {
    final response = await _dio.get('$_baseUrl/privacy/consents');
    return PatientConsents.fromJson(response.data);
  }

  /// Erteilt oder aktualisiert eine Einwilligung
  Future<ConsentRecord> updateConsent(ConsentRequest request) async {
    final response = await _dio.post(
      '$_baseUrl/privacy/consents',
      data: request.toJson(),
    );
    return ConsentRecord.fromJson(response.data);
  }

  /// Widerruft eine Einwilligung (Art. 7 Abs. 3 DSGVO)
  Future<ConsentRecord> revokeConsent({
    required ConsentCategory category,
    String? reason,
  }) async {
    final response = await _dio.delete(
      '$_baseUrl/privacy/consents/${category.name}',
      data: {'reason': reason},
    );
    return ConsentRecord.fromJson(response.data);
  }

  /// Prüft ob eine bestimmte Einwilligung erteilt wurde
  Future<bool> hasConsent(ConsentCategory category) async {
    final consents = await getConsents();
    final record = consents.consents.where((c) => c.category == category).lastOrNull;
    return record?.granted ?? false;
  }

  // ===========================================================================
  // DATA EXPORT (Art. 20 DSGVO - Datenportabilität)
  // ===========================================================================

  /// Fordert Datenexport an
  Future<DataExportRequest> requestDataExport({
    DataExportFormat format = DataExportFormat.json,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/privacy/export',
      data: {'format': format.name},
    );
    return DataExportRequest.fromJson(response.data);
  }

  /// Prüft Status eines Datenexports
  Future<DataExportRequest> getExportStatus(String requestId) async {
    final response = await _dio.get('$_baseUrl/privacy/export/$requestId');
    return DataExportRequest.fromJson(response.data);
  }

  /// Lädt exportierte Daten herunter
  Future<List<int>> downloadExport(String requestId) async {
    final response = await _dio.get<List<int>>(
      '$_baseUrl/privacy/export/$requestId/download',
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }

  // ===========================================================================
  // DATA DELETION (Art. 17 DSGVO - Recht auf Löschung)
  // ===========================================================================

  /// Fordert Datenlöschung an
  Future<DataDeletionRequest> requestDataDeletion({
    required String reason,
  }) async {
    final response = await _dio.post(
      '$_baseUrl/privacy/deletion',
      data: {'reason': reason},
    );
    return DataDeletionRequest.fromJson(response.data);
  }

  /// Prüft Status einer Löschanfrage
  Future<DataDeletionRequest> getDeletionStatus(String requestId) async {
    final response = await _dio.get('$_baseUrl/privacy/deletion/$requestId');
    return DataDeletionRequest.fromJson(response.data);
  }

  /// Bricht eine Löschanfrage ab (falls noch nicht ausgeführt)
  Future<void> cancelDeletionRequest(String requestId) async {
    await _dio.delete('$_baseUrl/privacy/deletion/$requestId');
  }

  // ===========================================================================
  // AUDIT LOG (Art. 30 DSGVO - Verzeichnis von Verarbeitungstätigkeiten)
  // ===========================================================================

  /// Holt Audit-Log für den aktuellen Benutzer
  Future<List<PrivacyAuditLog>> getAuditLog({
    DateTime? from,
    DateTime? to,
    PrivacyAuditAction? action,
    int limit = 100,
  }) async {
    final response = await _dio.get(
      '$_baseUrl/privacy/audit-log',
      queryParameters: {
        if (from != null) 'from': from.toIso8601String(),
        if (to != null) 'to': to.toIso8601String(),
        if (action != null) 'action': action.name,
        'limit': limit,
      },
    );
    return (response.data as List)
        .map((e) => PrivacyAuditLog.fromJson(e))
        .toList();
  }
}
