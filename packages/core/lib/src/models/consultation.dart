import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation.freezed.dart';
part 'consultation.g.dart';

/// Art der Konsultation.
enum ConsultationType {
  @JsonValue('video_call')
  videoCall,
  @JsonValue('voice_call')
  voiceCall,
  @JsonValue('chat')
  chat,
  @JsonValue('callback_request')
  callbackRequest,
}

/// Status einer Konsultation.
enum ConsultationStatus {
  @JsonValue('requested')
  requested,
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('waiting')
  waiting,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('no_show')
  noShow,
  @JsonValue('technical_error')
  technicalError,
}

/// Priorität der Konsultation.
enum ConsultationPriority {
  @JsonValue('routine')
  routine,
  @JsonValue('same_day')
  sameDay,
  @JsonValue('urgent')
  urgent,
  @JsonValue('emergency')
  emergency,
}

/// Eine Konsultation zwischen Patient und Arzt/Staff.
/// 
/// NOTE: Current structure matches generated freezed files.
/// Backend field mapping handled in [consultation_service.dart].
/// 
/// Backend API fields (snake_case) → Frontend fields (camelCase):
/// - subject → reason (use [subject] getter)
/// - description → notes (use [description] getter)
/// - call_started_at → startedAt
/// - call_ended_at → endedAt
@freezed
class Consultation with _$Consultation {
  const factory Consultation({
    required String id,
    required String patientId,
    required String practiceId,
    String? doctorId,
    required ConsultationType consultationType,
    required ConsultationStatus status,
    @Default(ConsultationPriority.routine) ConsultationPriority priority,
    String? reason,
    String? symptoms,
    String? notes,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationMinutes,
    String? roomId,
    String? roomToken,
    String? diagnosis,
    String? prescription,
    String? followUpRecommendation,
    DateTime? followUpDate,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? doctorName,
  }) = _Consultation;

  factory Consultation.fromJson(Map<String, dynamic> json) =>
      _$ConsultationFromJson(json);
}

/// Extension für Backend-API-Kompatibilität.
extension ConsultationApiExtension on Consultation {
  /// Backend: subject field
  String? get subject => reason;
  
  /// Backend: description field
  String? get description => notes;
}

/// Request zum Erstellen einer Konsultation.
/// 
/// Backend API fields (snake_case) mapped in service layer.
@freezed
class ConsultationCreate with _$ConsultationCreate {
  const factory ConsultationCreate({
    required ConsultationType consultationType,
    @Default(ConsultationPriority.routine) ConsultationPriority priority,
    String? reason,
    String? symptoms,
    String? preferredDoctorId,
    DateTime? preferredTime,
  }) = _ConsultationCreate;

  factory ConsultationCreate.fromJson(Map<String, dynamic> json) =>
      _$ConsultationCreateFromJson(json);
}

/// Extension für Backend-API (subject statt reason).
extension ConsultationCreateApiExtension on ConsultationCreate {
  /// Convert to Backend JSON with correct field names.
  Map<String, dynamic> toBackendJson() => {
    'consultation_type': consultationType.name,
    'priority': priority.name,
    'subject': reason, // Backend expects 'subject'
    'symptoms': symptoms,
    if (preferredDoctorId != null) 'preferred_doctor_id': preferredDoctorId,
    if (preferredTime != null) 'preferred_date': preferredTime!.toIso8601String(),
  };
}

/// Eine Chat-Nachricht in einer Konsultation.
/// 
/// Matches generated freezed structure.
@freezed
class ConsultationMessage with _$ConsultationMessage {
  const factory ConsultationMessage({
    required String id,
    required String consultationId,
    required String senderId,
    required String senderRole,
    required String content,
    @Default(false) bool isRead,
    required DateTime createdAt,
    String? senderName,
  }) = _ConsultationMessage;

  factory ConsultationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConsultationMessageFromJson(json);
}

/// Request zum Senden einer Nachricht.
@freezed
class ConsultationMessageCreate with _$ConsultationMessageCreate {
  const factory ConsultationMessageCreate({
    required String content,
  }) = _ConsultationMessageCreate;

  factory ConsultationMessageCreate.fromJson(Map<String, dynamic> json) =>
      _$ConsultationMessageCreateFromJson(json);
}

/// WebRTC Room Info für Video/Voice Calls.
/// 
/// ICE/TURN-Server werden direkt mitgeliefert (Option 2-A).
@freezed
class WebRTCRoom with _$WebRTCRoom {
  const factory WebRTCRoom({
    @JsonKey(name: 'room_id') required String roomId,
    @JsonKey(name: 'consultation_id') required String consultationId,
    @JsonKey(name: 'ice_servers') required List<IceServer> iceServers,
    @JsonKey(name: 'turn_servers') List<TurnServer>? turnServers,
  }) = _WebRTCRoom;

  factory WebRTCRoom.fromJson(Map<String, dynamic> json) =>
      _$WebRTCRoomFromJson(json);
}

/// ICE Server configuration for WebRTC.
/// Used when fetching ICE/TURN servers separately.
class IceServer {
  final List<String> urls;
  
  const IceServer({required this.urls});
  
  factory IceServer.fromJson(Map<String, dynamic> json) => IceServer(
    urls: (json['urls'] as List).cast<String>(),
  );
  
  Map<String, dynamic> toJson() => {'urls': urls};
}

/// TURN Server configuration with credentials.
class TurnServer {
  final List<String> urls;
  final String? username;
  final String? credential;
  
  const TurnServer({
    required this.urls,
    this.username,
    this.credential,
  });
  
  factory TurnServer.fromJson(Map<String, dynamic> json) => TurnServer(
    urls: (json['urls'] as List).cast<String>(),
    username: json['username'] as String?,
    credential: json['credential'] as String?,
  );
  
  Map<String, dynamic> toJson() => {
    'urls': urls,
    if (username != null) 'username': username,
    if (credential != null) 'credential': credential,
  };
}

/// WebRTC Signaling - Offer.
class WebRTCOffer {
  final String sdp;
  final String type;
  
  const WebRTCOffer({required this.sdp, this.type = 'offer'});
  
  factory WebRTCOffer.fromJson(Map<String, dynamic> json) => WebRTCOffer(
    sdp: json['sdp'] as String,
    type: json['type'] as String? ?? 'offer',
  );
  
  Map<String, dynamic> toJson() => {'sdp': sdp, 'type': type};
}

/// WebRTC Signaling - Answer.
class WebRTCAnswer {
  final String sdp;
  final String type;
  
  const WebRTCAnswer({required this.sdp, this.type = 'answer'});
  
  factory WebRTCAnswer.fromJson(Map<String, dynamic> json) => WebRTCAnswer(
    sdp: json['sdp'] as String,
    type: json['type'] as String? ?? 'answer',
  );
  
  Map<String, dynamic> toJson() => {'sdp': sdp, 'type': type};
}

/// WebRTC ICE Candidate.
class WebRTCIceCandidate {
  final String candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;
  
  const WebRTCIceCandidate({
    required this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
  });
  
  factory WebRTCIceCandidate.fromJson(Map<String, dynamic> json) => WebRTCIceCandidate(
    candidate: json['candidate'] as String,
    sdpMid: json['sdp_mid'] as String?,
    sdpMLineIndex: json['sdp_m_line_index'] as int?,
  );
  
  Map<String, dynamic> toJson() => {
    'candidate': candidate,
    if (sdpMid != null) 'sdp_mid': sdpMid,
    if (sdpMLineIndex != null) 'sdp_m_line_index': sdpMLineIndex,
  };
}

/// Generic WebRTC Signal for polling.
class WebRTCSignal {
  final String signalType;
  final Map<String, dynamic> payload;
  final String senderId;
  final DateTime timestamp;
  
  const WebRTCSignal({
    required this.signalType,
    required this.payload,
    required this.senderId,
    required this.timestamp,
  });
  
  factory WebRTCSignal.fromJson(Map<String, dynamic> json) => WebRTCSignal(
    signalType: json['signal_type'] as String,
    payload: json['payload'] as Map<String, dynamic>,
    senderId: json['sender_id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
  
  Map<String, dynamic> toJson() => {
    'signal_type': signalType,
    'payload': payload,
    'sender_id': senderId,
    'timestamp': timestamp.toIso8601String(),
  };
}

