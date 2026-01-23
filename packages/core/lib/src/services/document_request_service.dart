import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/document_request.dart';
import '../constants/api_endpoints.dart';

/// Service für Dokumentenanfragen (Rezept, AU, Überweisung etc.).
///
/// Bietet CRUD-Operationen für Patienten-Dokumentenanfragen.
/// 
/// Security:
///   - Patienten können nur eigene Anfragen sehen/erstellen.
///   - JWT-Token erforderlich für alle Operationen.
class DocumentRequestService {
  final Dio _dio;

  DocumentRequestService(this._dio);

  /// Erstellt eine neue Dokumentenanfrage.
  ///
  /// Args:
  ///   request: Die zu erstellende Anfrage.
  ///
  /// Returns:
  ///   Die erstellte Dokumentenanfrage mit ID.
  ///
  /// Raises:
  ///   DioException: Bei Netzwerk- oder Server-Fehlern.
  Future<DocumentRequest> createRequest(DocumentRequestCreate request) async {
    final response = await _dio.post(
      ApiEndpoints.documentRequests,
      data: request.toJson(),
    );
    return DocumentRequest.fromJson(response.data);
  }

  /// Lädt alle Dokumentenanfragen des aktuellen Patienten.
  ///
  /// Args:
  ///   status: Optional - Filtert nach Status.
  ///   limit: Maximale Anzahl (default: 50).
  ///   offset: Pagination-Offset.
  ///
  /// Returns:
  ///   Liste der Dokumentenanfragen.
  Future<List<DocumentRequest>> getMyRequests({
    DocumentRequestStatus? status,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (status != null) {
      queryParams['status'] = status.name;
    }

    final response = await _dio.get(
      '${ApiEndpoints.documentRequests}/my',
      queryParameters: queryParams,
    );

    final List<dynamic> items = response.data['items'] ?? [];
    return items.map((json) => DocumentRequest.fromJson(json)).toList();
  }

  /// Lädt eine einzelne Dokumentenanfrage.
  ///
  /// Args:
  ///   requestId: ID der Anfrage.
  ///
  /// Returns:
  ///   Die Dokumentenanfrage.
  Future<DocumentRequest> getRequest(String requestId) async {
    final response = await _dio.get(
      '${ApiEndpoints.documentRequests}/$requestId',
    );
    return DocumentRequest.fromJson(response.data);
  }

  /// Storniert eine Dokumentenanfrage.
  ///
  /// Args:
  ///   requestId: ID der zu stornierenden Anfrage.
  ///
  /// Returns:
  ///   True wenn erfolgreich.
  Future<bool> cancelRequest(String requestId) async {
    await _dio.delete('${ApiEndpoints.documentRequests}/$requestId');
    return true;
  }

  // =========================================================================
  // Quick Request Helpers
  // =========================================================================

  /// Erstellt schnell eine Rezept-Anfrage.
  Future<DocumentRequest> requestRezept({
    required String medicationName,
    String? dosage,
    int? quantity,
    String? notes,
    DocumentRequestPriority priority = DocumentRequestPriority.normal,
    DeliveryMethod delivery = DeliveryMethod.pickup,
  }) async {
    return createRequest(DocumentRequestCreate(
      documentType: DocumentType.rezept,
      title: 'Rezept: $medicationName',
      medicationName: medicationName,
      medicationDosage: dosage,
      medicationQuantity: quantity,
      additionalNotes: notes,
      priority: priority,
      deliveryMethod: delivery,
    ));
  }

  /// Erstellt schnell eine Überweisung-Anfrage.
  Future<DocumentRequest> requestUeberweisung({
    required String specialty,
    String? reason,
    String? preferredDoctor,
    String? notes,
    DocumentRequestPriority priority = DocumentRequestPriority.normal,
    DeliveryMethod delivery = DeliveryMethod.pickup,
  }) async {
    return createRequest(DocumentRequestCreate(
      documentType: DocumentType.ueberweisung,
      title: 'Überweisung: $specialty',
      referralSpecialty: specialty,
      referralReason: reason,
      preferredDoctor: preferredDoctor,
      additionalNotes: notes,
      priority: priority,
      deliveryMethod: delivery,
    ));
  }

  /// Erstellt schnell eine AU-Bescheinigung-Anfrage.
  Future<DocumentRequest> requestAU({
    required DateTime startDate,
    DateTime? endDate,
    String? reason,
    String? notes,
    DocumentRequestPriority priority = DocumentRequestPriority.normal,
    DeliveryMethod delivery = DeliveryMethod.pickup,
  }) async {
    return createRequest(DocumentRequestCreate(
      documentType: DocumentType.auBescheinigung,
      title: 'AU-Bescheinigung',
      auStartDate: startDate,
      auEndDate: endDate,
      auReason: reason,
      additionalNotes: notes,
      priority: priority,
      deliveryMethod: delivery,
    ));
  }

  /// Erstellt eine allgemeine Bescheinigung-Anfrage.
  Future<DocumentRequest> requestBescheinigung({
    required String purpose,
    String? description,
    String? notes,
    DocumentRequestPriority priority = DocumentRequestPriority.normal,
    DeliveryMethod delivery = DeliveryMethod.pickup,
  }) async {
    return createRequest(DocumentRequestCreate(
      documentType: DocumentType.bescheinigung,
      title: 'Bescheinigung: $purpose',
      purpose: purpose,
      description: description,
      additionalNotes: notes,
      priority: priority,
      deliveryMethod: delivery,
    ));
  }
}

/// Provider für DocumentRequestService.
final documentRequestServiceProvider = Provider<DocumentRequestService>((ref) {
  // TODO: Get Dio instance from core providers
  final dio = Dio(BaseOptions(
    baseUrl: ApiEndpoints.baseUrl,
    headers: {'Content-Type': 'application/json'},
  ));
  return DocumentRequestService(dio);
});

/// Provider für die Dokumentenanfragen des aktuellen Patienten.
final myDocumentRequestsProvider =
    FutureProvider.autoDispose<List<DocumentRequest>>((ref) async {
  final service = ref.watch(documentRequestServiceProvider);
  return service.getMyRequests();
});

/// Provider für ausstehende Dokumentenanfragen.
final pendingDocumentRequestsProvider =
    FutureProvider.autoDispose<List<DocumentRequest>>((ref) async {
  final service = ref.watch(documentRequestServiceProvider);
  return service.getMyRequests(status: DocumentRequestStatus.pending);
});
