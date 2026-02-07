// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationImpl _$$ConsultationImplFromJson(Map<String, dynamic> json) =>
    _$ConsultationImpl(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      practiceId: json['practice_id'] as String,
      doctorId: json['doctor_id'] as String?,
      consultationType:
          $enumDecode(_$ConsultationTypeEnumMap, json['consultation_type']),
      status: $enumDecode(_$ConsultationStatusEnumMap, json['status']),
      priority: $enumDecodeNullable(
              _$ConsultationPriorityEnumMap, json['priority']) ??
          ConsultationPriority.routine,
      reason: json['reason'] as String?,
      symptoms: json['symptoms'] as String?,
      notes: json['notes'] as String?,
      scheduledAt: json['scheduled_at'] == null
          ? null
          : DateTime.parse(json['scheduled_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] == null
          ? null
          : DateTime.parse(json['ended_at'] as String),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      roomId: json['room_id'] as String?,
      roomToken: json['room_token'] as String?,
      diagnosis: json['diagnosis'] as String?,
      prescription: json['prescription'] as String?,
      followUpRecommendation: json['follow_up_recommendation'] as String?,
      followUpDate: json['follow_up_date'] == null
          ? null
          : DateTime.parse(json['follow_up_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      patientName: json['patient_name'] as String?,
      doctorName: json['doctor_name'] as String?,
    );

Map<String, dynamic> _$$ConsultationImplToJson(_$ConsultationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'practice_id': instance.practiceId,
      'doctor_id': instance.doctorId,
      'consultation_type':
          _$ConsultationTypeEnumMap[instance.consultationType]!,
      'status': _$ConsultationStatusEnumMap[instance.status]!,
      'priority': _$ConsultationPriorityEnumMap[instance.priority]!,
      'reason': instance.reason,
      'symptoms': instance.symptoms,
      'notes': instance.notes,
      'scheduled_at': instance.scheduledAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'ended_at': instance.endedAt?.toIso8601String(),
      'duration_minutes': instance.durationMinutes,
      'room_id': instance.roomId,
      'room_token': instance.roomToken,
      'diagnosis': instance.diagnosis,
      'prescription': instance.prescription,
      'follow_up_recommendation': instance.followUpRecommendation,
      'follow_up_date': instance.followUpDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'patient_name': instance.patientName,
      'doctor_name': instance.doctorName,
    };

const _$ConsultationTypeEnumMap = {
  ConsultationType.videoCall: 'video_call',
  ConsultationType.voiceCall: 'voice_call',
  ConsultationType.chat: 'chat',
  ConsultationType.callbackRequest: 'callback_request',
};

const _$ConsultationStatusEnumMap = {
  ConsultationStatus.requested: 'requested',
  ConsultationStatus.scheduled: 'scheduled',
  ConsultationStatus.waiting: 'waiting',
  ConsultationStatus.inProgress: 'in_progress',
  ConsultationStatus.completed: 'completed',
  ConsultationStatus.cancelled: 'cancelled',
  ConsultationStatus.noShow: 'no_show',
  ConsultationStatus.technicalError: 'technical_error',
};

const _$ConsultationPriorityEnumMap = {
  ConsultationPriority.routine: 'routine',
  ConsultationPriority.sameDay: 'same_day',
  ConsultationPriority.urgent: 'urgent',
  ConsultationPriority.emergency: 'emergency',
};

_$ConsultationCreateImpl _$$ConsultationCreateImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsultationCreateImpl(
      consultationType:
          $enumDecode(_$ConsultationTypeEnumMap, json['consultation_type']),
      priority: $enumDecodeNullable(
              _$ConsultationPriorityEnumMap, json['priority']) ??
          ConsultationPriority.routine,
      reason: json['reason'] as String?,
      symptoms: json['symptoms'] as String?,
      preferredDoctorId: json['preferred_doctor_id'] as String?,
      preferredTime: json['preferred_time'] == null
          ? null
          : DateTime.parse(json['preferred_time'] as String),
    );

Map<String, dynamic> _$$ConsultationCreateImplToJson(
        _$ConsultationCreateImpl instance) =>
    <String, dynamic>{
      'consultation_type':
          _$ConsultationTypeEnumMap[instance.consultationType]!,
      'priority': _$ConsultationPriorityEnumMap[instance.priority]!,
      'reason': instance.reason,
      'symptoms': instance.symptoms,
      'preferred_doctor_id': instance.preferredDoctorId,
      'preferred_time': instance.preferredTime?.toIso8601String(),
    };

_$ConsultationMessageImpl _$$ConsultationMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsultationMessageImpl(
      id: json['id'] as String,
      consultationId: json['consultation_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: json['sender_name'] as String?,
    );

Map<String, dynamic> _$$ConsultationMessageImplToJson(
        _$ConsultationMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consultation_id': instance.consultationId,
      'sender_id': instance.senderId,
      'sender_role': instance.senderRole,
      'content': instance.content,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
      'sender_name': instance.senderName,
    };

_$ConsultationMessageCreateImpl _$$ConsultationMessageCreateImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsultationMessageCreateImpl(
      content: json['content'] as String,
    );

Map<String, dynamic> _$$ConsultationMessageCreateImplToJson(
        _$ConsultationMessageCreateImpl instance) =>
    <String, dynamic>{
      'content': instance.content,
    };

_$WebRTCRoomImpl _$$WebRTCRoomImplFromJson(Map<String, dynamic> json) =>
    _$WebRTCRoomImpl(
      roomId: json['room_id'] as String,
      consultationId: json['consultation_id'] as String,
      iceServers: (json['ice_servers'] as List<dynamic>)
          .map((e) => IceServer.fromJson(e as Map<String, dynamic>))
          .toList(),
      turnServers: (json['turn_servers'] as List<dynamic>?)
          ?.map((e) => TurnServer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WebRTCRoomImplToJson(_$WebRTCRoomImpl instance) =>
    <String, dynamic>{
      'room_id': instance.roomId,
      'consultation_id': instance.consultationId,
      'ice_servers': instance.iceServers.map((e) => e.toJson()).toList(),
      'turn_servers': instance.turnServers?.map((e) => e.toJson()).toList(),
    };
