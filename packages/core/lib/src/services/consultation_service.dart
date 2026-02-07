import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/consultation.dart';
import '../constants/api_endpoints.dart';

/// Service für Konsultationen (Video, Voice, Chat).
///
/// Bietet Funktionen für Patienten-Arzt-Kommunikation.
///
/// Security:
///   - Patienten können nur eigene Konsultationen sehen.
///   - End-to-End Verschlüsselung für Nachrichten empfohlen.
///   - WebRTC-Tokens haben begrenzte Gültigkeit.
class ConsultationService {
  final Dio _dio;

  ConsultationService(this._dio);

  // =========================================================================
  // Consultation CRUD
  // =========================================================================

  /// Erstellt eine neue Konsultationsanfrage.
  ///
  /// Args:
  ///   request: Konsultationsdetails.
  ///
  /// Returns:
  ///   Die erstellte Konsultation.
  Future<Consultation> requestConsultation(ConsultationCreate request) async {
    // Use Backend-compatible JSON (subject statt reason)
    final response = await _dio.post(
      '${ApiEndpoints.consultations}/request',
      data: request.toBackendJson(),
    );
    return Consultation.fromJson(response.data);
  }

  /// Lädt alle Konsultationen des aktuellen Patienten.
  ///
  /// Args:
  ///   status: Optional - Filtert nach Status.
  ///   consultationType: Optional - Filtert nach Typ.
  ///   limit: Maximale Anzahl.
  ///   offset: Pagination-Offset.
  ///
  /// Returns:
  ///   Liste der Konsultationen.
  Future<List<Consultation>> getMyConsultations({
    ConsultationStatus? status,
    ConsultationType? consultationType,
    int page = 1,
    int pageSize = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (consultationType != null) {
      queryParams['consultation_type'] = consultationType.name;
    }

    final response = await _dio.get(
      ApiEndpoints.myConsultations,
      queryParameters: queryParams,
    );

    final List<dynamic> items = response.data['items'] ?? [];
    return items.map((json) => Consultation.fromJson(json)).toList();
  }

  /// Lädt eine einzelne Konsultation.
  Future<Consultation> getConsultation(String consultationId) async {
    final response = await _dio.get(
      '${ApiEndpoints.consultations}/$consultationId',
    );
    return Consultation.fromJson(response.data);
  }

  /// Storniert eine Konsultation.
  Future<bool> cancelConsultation(String consultationId, {String? reason}) async {
    await _dio.post(
      ApiEndpoints.consultationCancel(consultationId),
      data: {'reason': reason},
    );
    return true;
  }

  // =========================================================================
  // Chat Messages
  // =========================================================================

  /// Sendet eine Chat-Nachricht in einer Konsultation.
  ///
  /// Args:
  ///   consultationId: ID der Konsultation.
  ///   content: Nachrichteninhalt.
  ///
  /// Returns:
  ///   Die gesendete Nachricht.
  Future<ConsultationMessage> sendMessage(
    String consultationId,
    String content,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.consultationMessages(consultationId),
      data: {'content': content},
    );
    return ConsultationMessage.fromJson(response.data);
  }

  /// Lädt alle Nachrichten einer Konsultation.
  ///
  /// Args:
  ///   consultationId: ID der Konsultation.
  ///   limit: Maximale Anzahl.
  ///   beforeId: Nachrichten vor dieser ID laden (Pagination).
  ///
  /// Returns:
  ///   Liste der Nachrichten (neueste zuerst).
  Future<List<ConsultationMessage>> getMessages(
    String consultationId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };

    final response = await _dio.get(
      ApiEndpoints.consultationMessages(consultationId),
      queryParameters: queryParams,
    );

    final List<dynamic> items = response.data['items'] ?? [];
    return items.map((json) => ConsultationMessage.fromJson(json)).toList();
  }

  /// Markiert Nachrichten als gelesen.
  Future<void> markMessagesRead(String consultationId) async {
    await _dio.post(
      ApiEndpoints.consultationMessagesRead(consultationId),
    );
  }

  /// Holt Anzahl ungelesener Nachrichten.
  Future<int> getUnreadCount(String consultationId) async {
    final response = await _dio.get(
      '${ApiEndpoints.consultations}/$consultationId/messages/unread-count',
    );
    return response.data['count'] ?? 0;
  }

  // =========================================================================
  // Video/Voice Call
  // =========================================================================

  /// Holt WebRTC-Raum-Info für Video/Voice Call.
  ///
  /// Args:
  ///   consultationId: ID der Konsultation.
  ///
  /// Returns:
  ///   WebRTC-Raum-Informationen mit ICE/TURN Servern.
  ///
  /// Raises:
  ///   Exception: Wenn Konsultation nicht für Calls geeignet.
  Future<WebRTCRoom> getCallRoom(String consultationId) async {
    final response = await _dio.get(
      ApiEndpoints.consultationCallRoom(consultationId),
    );
    return WebRTCRoom.fromJson(response.data);
  }

  /// Tritt einem Call bei (markiert als "in_progress").
  Future<Consultation> joinCall(String consultationId) async {
    final response = await _dio.post(
      ApiEndpoints.consultationJoin(consultationId),
    );
    return Consultation.fromJson(response.data);
  }

  /// Beendet einen Call.
  Future<void> endCall(String consultationId) async {
    await _dio.post(
      ApiEndpoints.consultationEnd(consultationId),
      data: {'consultation_id': consultationId},
    );
  }

  // =========================================================================
  // WebRTC Signaling
  // =========================================================================

  /// Sendet ein WebRTC Offer an den Peer.
  Future<void> sendOffer(String consultationId, WebRTCOffer offer) async {
    await _dio.post(
      ApiEndpoints.webrtcOffer(consultationId),
      data: offer.toJson(),
    );
  }

  /// Sendet ein WebRTC Answer an den Peer.
  Future<void> sendAnswer(String consultationId, WebRTCAnswer answer) async {
    await _dio.post(
      ApiEndpoints.webrtcAnswer(consultationId),
      data: answer.toJson(),
    );
  }

  /// Sendet einen ICE Candidate an den Peer.
  Future<void> sendIceCandidate(
    String consultationId,
    WebRTCIceCandidate candidate,
  ) async {
    await _dio.post(
      ApiEndpoints.webrtcIce(consultationId),
      data: candidate.toJson(),
    );
  }

  /// Pollt nach neuen WebRTC Signals vom Peer.
  ///
  /// Args:
  ///   consultationId: ID der Konsultation.
  ///   since: Nur Signals nach diesem Zeitstempel.
  ///
  /// Returns:
  ///   Liste der neuen Signals.
  Future<List<WebRTCSignal>> pollSignals(
    String consultationId, {
    DateTime? since,
  }) async {
    final queryParams = <String, dynamic>{};
    if (since != null) {
      queryParams['since'] = since.toUtc().toIso8601String();
    }

    final response = await _dio.get(
      ApiEndpoints.webrtcPoll(consultationId),
      queryParameters: queryParams,
    );

    final List<dynamic> items = response.data ?? [];
    return items.map((json) => WebRTCSignal.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Löscht alle Signals einer Konsultation (bei Call-Ende).
  Future<void> clearSignals(String consultationId) async {
    await _dio.delete(ApiEndpoints.webrtcClear(consultationId));
  }

  // =========================================================================
  // Quick Request Helpers
  // =========================================================================

  /// Fordert einen Rückruf an.
  Future<Consultation> requestCallback({
    required String reason,
    String? symptoms,
    ConsultationPriority priority = ConsultationPriority.routine,
    DateTime? preferredTime,
  }) async {
    return requestConsultation(ConsultationCreate(
      consultationType: ConsultationType.callbackRequest,
      reason: reason,
      symptoms: symptoms,
      priority: priority,
      preferredTime: preferredTime,
    ));
  }

  /// Fordert einen Video-Call an.
  Future<Consultation> requestVideoCall({
    required String reason,
    String? symptoms,
    DateTime? preferredTime,
    ConsultationPriority priority = ConsultationPriority.routine,
  }) async {
    return requestConsultation(ConsultationCreate(
      consultationType: ConsultationType.videoCall,
      reason: reason,
      symptoms: symptoms,
      preferredTime: preferredTime,
      priority: priority,
    ));
  }

  /// Fordert einen Voice-Call an.
  Future<Consultation> requestVoiceCall({
    required String reason,
    String? symptoms,
    DateTime? preferredTime,
    ConsultationPriority priority = ConsultationPriority.routine,
  }) async {
    return requestConsultation(ConsultationCreate(
      consultationType: ConsultationType.voiceCall,
      reason: reason,
      symptoms: symptoms,
      preferredTime: preferredTime,
      priority: priority,
    ));
  }

  /// Startet einen Chat.
  Future<Consultation> startChat({
    required String reason,
    String? symptoms,
    ConsultationPriority priority = ConsultationPriority.routine,
  }) async {
    return requestConsultation(ConsultationCreate(
      consultationType: ConsultationType.chat,
      reason: reason,
      symptoms: symptoms,
      priority: priority,
    ));
  }
}

// NOTE: consultationServiceProvider is defined in core_providers.dart
// using the shared Dio instance with proper auth interceptors.
