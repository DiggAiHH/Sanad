// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Consultation _$ConsultationFromJson(Map<String, dynamic> json) {
  return _Consultation.fromJson(json);
}

/// @nodoc
mixin _$Consultation {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get practiceId => throw _privateConstructorUsedError;
  String? get doctorId => throw _privateConstructorUsedError;
  ConsultationType get consultationType => throw _privateConstructorUsedError;
  ConsultationStatus get status => throw _privateConstructorUsedError;
  ConsultationPriority get priority => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get symptoms => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  String? get roomId => throw _privateConstructorUsedError;
  String? get roomToken => throw _privateConstructorUsedError;
  String? get diagnosis => throw _privateConstructorUsedError;
  String? get prescription => throw _privateConstructorUsedError;
  String? get followUpRecommendation => throw _privateConstructorUsedError;
  DateTime? get followUpDate => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get patientName => throw _privateConstructorUsedError;
  String? get doctorName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsultationCopyWith<Consultation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationCopyWith<$Res> {
  factory $ConsultationCopyWith(
          Consultation value, $Res Function(Consultation) then) =
      _$ConsultationCopyWithImpl<$Res, Consultation>;
  @useResult
  $Res call({
    String id,
    String patientId,
    String practiceId,
    String? doctorId,
    ConsultationType consultationType,
    ConsultationStatus status,
    ConsultationPriority priority,
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
    DateTime createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? doctorName,
  });
}

/// @nodoc
class _$ConsultationCopyWithImpl<$Res, $Val extends Consultation>
    implements $ConsultationCopyWith<$Res> {
  _$ConsultationCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? doctorId = freezed,
    Object? consultationType = null,
    Object? status = null,
    Object? priority = null,
    Object? reason = freezed,
    Object? symptoms = freezed,
    Object? notes = freezed,
    Object? scheduledAt = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? durationMinutes = freezed,
    Object? roomId = freezed,
    Object? roomToken = freezed,
    Object? diagnosis = freezed,
    Object? prescription = freezed,
    Object? followUpRecommendation = freezed,
    Object? followUpDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? patientName = freezed,
    Object? doctorName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      patientId: null == patientId ? _value.patientId : patientId as String,
      practiceId:
          null == practiceId ? _value.practiceId : practiceId as String,
      doctorId: freezed == doctorId ? _value.doctorId : doctorId as String?,
      consultationType: null == consultationType
          ? _value.consultationType
          : consultationType as ConsultationType,
      status: null == status ? _value.status : status as ConsultationStatus,
      priority:
          null == priority ? _value.priority : priority as ConsultationPriority,
      reason: freezed == reason ? _value.reason : reason as String?,
      symptoms: freezed == symptoms ? _value.symptoms : symptoms as String?,
      notes: freezed == notes ? _value.notes : notes as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt as DateTime?,
      startedAt:
          freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      endedAt: freezed == endedAt ? _value.endedAt : endedAt as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes as int?,
      roomId: freezed == roomId ? _value.roomId : roomId as String?,
      roomToken: freezed == roomToken ? _value.roomToken : roomToken as String?,
      diagnosis: freezed == diagnosis ? _value.diagnosis : diagnosis as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription as String?,
      followUpRecommendation: freezed == followUpRecommendation
          ? _value.followUpRecommendation
          : followUpRecommendation as String?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate as DateTime?,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      patientName:
          freezed == patientName ? _value.patientName : patientName as String?,
      doctorName:
          freezed == doctorName ? _value.doctorName : doctorName as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsultationImplCopyWith<$Res>
    implements $ConsultationCopyWith<$Res> {
  factory _$$ConsultationImplCopyWith(
          _$ConsultationImpl value, $Res Function(_$ConsultationImpl) then) =
      __$$ConsultationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    String practiceId,
    String? doctorId,
    ConsultationType consultationType,
    ConsultationStatus status,
    ConsultationPriority priority,
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
    DateTime createdAt,
    DateTime? updatedAt,
    String? patientName,
    String? doctorName,
  });
}

/// @nodoc
class __$$ConsultationImplCopyWithImpl<$Res>
    extends _$ConsultationCopyWithImpl<$Res, _$ConsultationImpl>
    implements _$$ConsultationImplCopyWith<$Res> {
  __$$ConsultationImplCopyWithImpl(
      _$ConsultationImpl _value, $Res Function(_$ConsultationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? doctorId = freezed,
    Object? consultationType = null,
    Object? status = null,
    Object? priority = null,
    Object? reason = freezed,
    Object? symptoms = freezed,
    Object? notes = freezed,
    Object? scheduledAt = freezed,
    Object? startedAt = freezed,
    Object? endedAt = freezed,
    Object? durationMinutes = freezed,
    Object? roomId = freezed,
    Object? roomToken = freezed,
    Object? diagnosis = freezed,
    Object? prescription = freezed,
    Object? followUpRecommendation = freezed,
    Object? followUpDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? patientName = freezed,
    Object? doctorName = freezed,
  }) {
    return _then(_$ConsultationImpl(
      id: null == id ? _value.id : id as String,
      patientId: null == patientId ? _value.patientId : patientId as String,
      practiceId:
          null == practiceId ? _value.practiceId : practiceId as String,
      doctorId: freezed == doctorId ? _value.doctorId : doctorId as String?,
      consultationType: null == consultationType
          ? _value.consultationType
          : consultationType as ConsultationType,
      status: null == status ? _value.status : status as ConsultationStatus,
      priority:
          null == priority ? _value.priority : priority as ConsultationPriority,
      reason: freezed == reason ? _value.reason : reason as String?,
      symptoms: freezed == symptoms ? _value.symptoms : symptoms as String?,
      notes: freezed == notes ? _value.notes : notes as String?,
      scheduledAt: freezed == scheduledAt
          ? _value.scheduledAt
          : scheduledAt as DateTime?,
      startedAt:
          freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      endedAt: freezed == endedAt ? _value.endedAt : endedAt as DateTime?,
      durationMinutes: freezed == durationMinutes
          ? _value.durationMinutes
          : durationMinutes as int?,
      roomId: freezed == roomId ? _value.roomId : roomId as String?,
      roomToken: freezed == roomToken ? _value.roomToken : roomToken as String?,
      diagnosis: freezed == diagnosis ? _value.diagnosis : diagnosis as String?,
      prescription: freezed == prescription
          ? _value.prescription
          : prescription as String?,
      followUpRecommendation: freezed == followUpRecommendation
          ? _value.followUpRecommendation
          : followUpRecommendation as String?,
      followUpDate: freezed == followUpDate
          ? _value.followUpDate
          : followUpDate as DateTime?,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt:
          freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      patientName:
          freezed == patientName ? _value.patientName : patientName as String?,
      doctorName:
          freezed == doctorName ? _value.doctorName : doctorName as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationImpl implements _Consultation {
  const _$ConsultationImpl({
    required this.id,
    required this.patientId,
    required this.practiceId,
    this.doctorId,
    required this.consultationType,
    required this.status,
    this.priority = ConsultationPriority.routine,
    this.reason,
    this.symptoms,
    this.notes,
    this.scheduledAt,
    this.startedAt,
    this.endedAt,
    this.durationMinutes,
    this.roomId,
    this.roomToken,
    this.diagnosis,
    this.prescription,
    this.followUpRecommendation,
    this.followUpDate,
    required this.createdAt,
    this.updatedAt,
    this.patientName,
    this.doctorName,
  });

  factory _$ConsultationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String practiceId;
  @override
  final String? doctorId;
  @override
  final ConsultationType consultationType;
  @override
  final ConsultationStatus status;
  @override
  @JsonKey()
  final ConsultationPriority priority;
  @override
  final String? reason;
  @override
  final String? symptoms;
  @override
  final String? notes;
  @override
  final DateTime? scheduledAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? endedAt;
  @override
  final int? durationMinutes;
  @override
  final String? roomId;
  @override
  final String? roomToken;
  @override
  final String? diagnosis;
  @override
  final String? prescription;
  @override
  final String? followUpRecommendation;
  @override
  final DateTime? followUpDate;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? patientName;
  @override
  final String? doctorName;

  @override
  String toString() {
    return 'Consultation(id: $id, patientId: $patientId, practiceId: $practiceId, doctorId: $doctorId, consultationType: $consultationType, status: $status, priority: $priority, reason: $reason, symptoms: $symptoms, notes: $notes, scheduledAt: $scheduledAt, startedAt: $startedAt, endedAt: $endedAt, durationMinutes: $durationMinutes, roomId: $roomId, roomToken: $roomToken, diagnosis: $diagnosis, prescription: $prescription, followUpRecommendation: $followUpRecommendation, followUpDate: $followUpDate, createdAt: $createdAt, updatedAt: $updatedAt, patientName: $patientName, doctorName: $doctorName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.practiceId, practiceId) ||
                other.practiceId == practiceId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.consultationType, consultationType) ||
                other.consultationType == consultationType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.symptoms, symptoms) ||
                other.symptoms == symptoms) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.roomToken, roomToken) ||
                other.roomToken == roomToken) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.prescription, prescription) ||
                other.prescription == prescription) &&
            (identical(other.followUpRecommendation, followUpRecommendation) ||
                other.followUpRecommendation == followUpRecommendation) &&
            (identical(other.followUpDate, followUpDate) ||
                other.followUpDate == followUpDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.patientName, patientName) ||
                other.patientName == patientName) &&
            (identical(other.doctorName, doctorName) ||
                other.doctorName == doctorName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        patientId,
        practiceId,
        doctorId,
        consultationType,
        status,
        priority,
        reason,
        symptoms,
        notes,
        scheduledAt,
        startedAt,
        endedAt,
        durationMinutes,
        roomId,
        roomToken,
        diagnosis,
        prescription,
        followUpRecommendation,
        followUpDate,
        createdAt,
        updatedAt,
        patientName,
        doctorName,
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      __$$ConsultationImplCopyWithImpl<_$ConsultationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationImplToJson(this);
  }
}

abstract class _Consultation implements Consultation {
  const factory _Consultation({
    required final String id,
    required final String patientId,
    required final String practiceId,
    final String? doctorId,
    required final ConsultationType consultationType,
    required final ConsultationStatus status,
    final ConsultationPriority priority,
    final String? reason,
    final String? symptoms,
    final String? notes,
    final DateTime? scheduledAt,
    final DateTime? startedAt,
    final DateTime? endedAt,
    final int? durationMinutes,
    final String? roomId,
    final String? roomToken,
    final String? diagnosis,
    final String? prescription,
    final String? followUpRecommendation,
    final DateTime? followUpDate,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final String? patientName,
    final String? doctorName,
  }) = _$ConsultationImpl;

  factory _Consultation.fromJson(Map<String, dynamic> json) =
      _$ConsultationImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get practiceId;
  @override
  String? get doctorId;
  @override
  ConsultationType get consultationType;
  @override
  ConsultationStatus get status;
  @override
  ConsultationPriority get priority;
  @override
  String? get reason;
  @override
  String? get symptoms;
  @override
  String? get notes;
  @override
  DateTime? get scheduledAt;
  @override
  DateTime? get startedAt;
  @override
  DateTime? get endedAt;
  @override
  int? get durationMinutes;
  @override
  String? get roomId;
  @override
  String? get roomToken;
  @override
  String? get diagnosis;
  @override
  String? get prescription;
  @override
  String? get followUpRecommendation;
  @override
  DateTime? get followUpDate;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get patientName;
  @override
  String? get doctorName;
  @override
  @JsonKey(ignore: true)
  _$$ConsultationImplCopyWith<_$ConsultationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsultationCreate _$ConsultationCreateFromJson(Map<String, dynamic> json) {
  return _ConsultationCreate.fromJson(json);
}

/// @nodoc
mixin _$ConsultationCreate {
  ConsultationType get consultationType => throw _privateConstructorUsedError;
  ConsultationPriority get priority => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  String? get symptoms => throw _privateConstructorUsedError;
  String? get preferredDoctorId => throw _privateConstructorUsedError;
  DateTime? get preferredTime => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsultationCreateCopyWith<ConsultationCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationCreateCopyWith<$Res> {
  factory $ConsultationCreateCopyWith(
          ConsultationCreate value, $Res Function(ConsultationCreate) then) =
      _$ConsultationCreateCopyWithImpl<$Res, ConsultationCreate>;
  @useResult
  $Res call({
    ConsultationType consultationType,
    ConsultationPriority priority,
    String? reason,
    String? symptoms,
    String? preferredDoctorId,
    DateTime? preferredTime,
  });
}

/// @nodoc
class _$ConsultationCreateCopyWithImpl<$Res, $Val extends ConsultationCreate>
    implements $ConsultationCreateCopyWith<$Res> {
  _$ConsultationCreateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationType = null,
    Object? priority = null,
    Object? reason = freezed,
    Object? symptoms = freezed,
    Object? preferredDoctorId = freezed,
    Object? preferredTime = freezed,
  }) {
    return _then(_value.copyWith(
      consultationType: null == consultationType
          ? _value.consultationType
          : consultationType as ConsultationType,
      priority:
          null == priority ? _value.priority : priority as ConsultationPriority,
      reason: freezed == reason ? _value.reason : reason as String?,
      symptoms: freezed == symptoms ? _value.symptoms : symptoms as String?,
      preferredDoctorId: freezed == preferredDoctorId
          ? _value.preferredDoctorId
          : preferredDoctorId as String?,
      preferredTime: freezed == preferredTime
          ? _value.preferredTime
          : preferredTime as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsultationCreateImplCopyWith<$Res>
    implements $ConsultationCreateCopyWith<$Res> {
  factory _$$ConsultationCreateImplCopyWith(_$ConsultationCreateImpl value,
          $Res Function(_$ConsultationCreateImpl) then) =
      __$$ConsultationCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ConsultationType consultationType,
    ConsultationPriority priority,
    String? reason,
    String? symptoms,
    String? preferredDoctorId,
    DateTime? preferredTime,
  });
}

/// @nodoc
class __$$ConsultationCreateImplCopyWithImpl<$Res>
    extends _$ConsultationCreateCopyWithImpl<$Res, _$ConsultationCreateImpl>
    implements _$$ConsultationCreateImplCopyWith<$Res> {
  __$$ConsultationCreateImplCopyWithImpl(_$ConsultationCreateImpl _value,
      $Res Function(_$ConsultationCreateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationType = null,
    Object? priority = null,
    Object? reason = freezed,
    Object? symptoms = freezed,
    Object? preferredDoctorId = freezed,
    Object? preferredTime = freezed,
  }) {
    return _then(_$ConsultationCreateImpl(
      consultationType: null == consultationType
          ? _value.consultationType
          : consultationType as ConsultationType,
      priority:
          null == priority ? _value.priority : priority as ConsultationPriority,
      reason: freezed == reason ? _value.reason : reason as String?,
      symptoms: freezed == symptoms ? _value.symptoms : symptoms as String?,
      preferredDoctorId: freezed == preferredDoctorId
          ? _value.preferredDoctorId
          : preferredDoctorId as String?,
      preferredTime: freezed == preferredTime
          ? _value.preferredTime
          : preferredTime as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationCreateImpl implements _ConsultationCreate {
  const _$ConsultationCreateImpl({
    required this.consultationType,
    this.priority = ConsultationPriority.routine,
    this.reason,
    this.symptoms,
    this.preferredDoctorId,
    this.preferredTime,
  });

  factory _$ConsultationCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationCreateImplFromJson(json);

  @override
  final ConsultationType consultationType;
  @override
  @JsonKey()
  final ConsultationPriority priority;
  @override
  final String? reason;
  @override
  final String? symptoms;
  @override
  final String? preferredDoctorId;
  @override
  final DateTime? preferredTime;

  @override
  String toString() {
    return 'ConsultationCreate(consultationType: $consultationType, priority: $priority, reason: $reason, symptoms: $symptoms, preferredDoctorId: $preferredDoctorId, preferredTime: $preferredTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationCreateImpl &&
            (identical(other.consultationType, consultationType) ||
                other.consultationType == consultationType) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.symptoms, symptoms) ||
                other.symptoms == symptoms) &&
            (identical(other.preferredDoctorId, preferredDoctorId) ||
                other.preferredDoctorId == preferredDoctorId) &&
            (identical(other.preferredTime, preferredTime) ||
                other.preferredTime == preferredTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, consultationType, priority,
      reason, symptoms, preferredDoctorId, preferredTime);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationCreateImplCopyWith<_$ConsultationCreateImpl> get copyWith =>
      __$$ConsultationCreateImplCopyWithImpl<_$ConsultationCreateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationCreateImplToJson(this);
  }
}

abstract class _ConsultationCreate implements ConsultationCreate {
  const factory _ConsultationCreate({
    required final ConsultationType consultationType,
    final ConsultationPriority priority,
    final String? reason,
    final String? symptoms,
    final String? preferredDoctorId,
    final DateTime? preferredTime,
  }) = _$ConsultationCreateImpl;

  factory _ConsultationCreate.fromJson(Map<String, dynamic> json) =
      _$ConsultationCreateImpl.fromJson;

  @override
  ConsultationType get consultationType;
  @override
  ConsultationPriority get priority;
  @override
  String? get reason;
  @override
  String? get symptoms;
  @override
  String? get preferredDoctorId;
  @override
  DateTime? get preferredTime;
  @override
  @JsonKey(ignore: true)
  _$$ConsultationCreateImplCopyWith<_$ConsultationCreateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsultationMessage _$ConsultationMessageFromJson(Map<String, dynamic> json) {
  return _ConsultationMessage.fromJson(json);
}

/// @nodoc
mixin _$ConsultationMessage {
  String get id => throw _privateConstructorUsedError;
  String get consultationId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderRole => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsultationMessageCopyWith<ConsultationMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationMessageCopyWith<$Res> {
  factory $ConsultationMessageCopyWith(
          ConsultationMessage value, $Res Function(ConsultationMessage) then) =
      _$ConsultationMessageCopyWithImpl<$Res, ConsultationMessage>;
  @useResult
  $Res call({
    String id,
    String consultationId,
    String senderId,
    String senderRole,
    String content,
    bool isRead,
    DateTime createdAt,
    String? senderName,
  });
}

/// @nodoc
class _$ConsultationMessageCopyWithImpl<$Res, $Val extends ConsultationMessage>
    implements $ConsultationMessageCopyWith<$Res> {
  _$ConsultationMessageCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? senderName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      senderId: null == senderId ? _value.senderId : senderId as String,
      senderRole:
          null == senderRole ? _value.senderRole : senderRole as String,
      content: null == content ? _value.content : content as String,
      isRead: null == isRead ? _value.isRead : isRead as bool,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      senderName:
          freezed == senderName ? _value.senderName : senderName as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsultationMessageImplCopyWith<$Res>
    implements $ConsultationMessageCopyWith<$Res> {
  factory _$$ConsultationMessageImplCopyWith(_$ConsultationMessageImpl value,
          $Res Function(_$ConsultationMessageImpl) then) =
      __$$ConsultationMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String consultationId,
    String senderId,
    String senderRole,
    String content,
    bool isRead,
    DateTime createdAt,
    String? senderName,
  });
}

/// @nodoc
class __$$ConsultationMessageImplCopyWithImpl<$Res>
    extends _$ConsultationMessageCopyWithImpl<$Res, _$ConsultationMessageImpl>
    implements _$$ConsultationMessageImplCopyWith<$Res> {
  __$$ConsultationMessageImplCopyWithImpl(_$ConsultationMessageImpl _value,
      $Res Function(_$ConsultationMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? content = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? senderName = freezed,
  }) {
    return _then(_$ConsultationMessageImpl(
      id: null == id ? _value.id : id as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      senderId: null == senderId ? _value.senderId : senderId as String,
      senderRole:
          null == senderRole ? _value.senderRole : senderRole as String,
      content: null == content ? _value.content : content as String,
      isRead: null == isRead ? _value.isRead : isRead as bool,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      senderName:
          freezed == senderName ? _value.senderName : senderName as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationMessageImpl implements _ConsultationMessage {
  const _$ConsultationMessageImpl({
    required this.id,
    required this.consultationId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.senderName,
  });

  factory _$ConsultationMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String consultationId;
  @override
  final String senderId;
  @override
  final String senderRole;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final String? senderName;

  @override
  String toString() {
    return 'ConsultationMessage(id: $id, consultationId: $consultationId, senderId: $senderId, senderRole: $senderRole, content: $content, isRead: $isRead, createdAt: $createdAt, senderName: $senderName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, consultationId, senderId,
      senderRole, content, isRead, createdAt, senderName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationMessageImplCopyWith<_$ConsultationMessageImpl> get copyWith =>
      __$$ConsultationMessageImplCopyWithImpl<_$ConsultationMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationMessageImplToJson(this);
  }
}

abstract class _ConsultationMessage implements ConsultationMessage {
  const factory _ConsultationMessage({
    required final String id,
    required final String consultationId,
    required final String senderId,
    required final String senderRole,
    required final String content,
    final bool isRead,
    required final DateTime createdAt,
    final String? senderName,
  }) = _$ConsultationMessageImpl;

  factory _ConsultationMessage.fromJson(Map<String, dynamic> json) =
      _$ConsultationMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get consultationId;
  @override
  String get senderId;
  @override
  String get senderRole;
  @override
  String get content;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;
  @override
  String? get senderName;
  @override
  @JsonKey(ignore: true)
  _$$ConsultationMessageImplCopyWith<_$ConsultationMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConsultationMessageCreate _$ConsultationMessageCreateFromJson(
    Map<String, dynamic> json) {
  return _ConsultationMessageCreate.fromJson(json);
}

/// @nodoc
mixin _$ConsultationMessageCreate {
  String get content => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ConsultationMessageCreateCopyWith<ConsultationMessageCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationMessageCreateCopyWith<$Res> {
  factory $ConsultationMessageCreateCopyWith(ConsultationMessageCreate value,
          $Res Function(ConsultationMessageCreate) then) =
      _$ConsultationMessageCreateCopyWithImpl<$Res, ConsultationMessageCreate>;
  @useResult
  $Res call({String content});
}

/// @nodoc
class _$ConsultationMessageCreateCopyWithImpl<$Res,
        $Val extends ConsultationMessageCreate>
    implements $ConsultationMessageCreateCopyWith<$Res> {
  _$ConsultationMessageCreateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_value.copyWith(
      content: null == content ? _value.content : content as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConsultationMessageCreateImplCopyWith<$Res>
    implements $ConsultationMessageCreateCopyWith<$Res> {
  factory _$$ConsultationMessageCreateImplCopyWith(
          _$ConsultationMessageCreateImpl value,
          $Res Function(_$ConsultationMessageCreateImpl) then) =
      __$$ConsultationMessageCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content});
}

/// @nodoc
class __$$ConsultationMessageCreateImplCopyWithImpl<$Res>
    extends _$ConsultationMessageCreateCopyWithImpl<$Res,
        _$ConsultationMessageCreateImpl>
    implements _$$ConsultationMessageCreateImplCopyWith<$Res> {
  __$$ConsultationMessageCreateImplCopyWithImpl(
      _$ConsultationMessageCreateImpl _value,
      $Res Function(_$ConsultationMessageCreateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
  }) {
    return _then(_$ConsultationMessageCreateImpl(
      content: null == content ? _value.content : content as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationMessageCreateImpl implements _ConsultationMessageCreate {
  const _$ConsultationMessageCreateImpl({required this.content});

  factory _$ConsultationMessageCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationMessageCreateImplFromJson(json);

  @override
  final String content;

  @override
  String toString() {
    return 'ConsultationMessageCreate(content: $content)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationMessageCreateImpl &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, content);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationMessageCreateImplCopyWith<_$ConsultationMessageCreateImpl>
      get copyWith => __$$ConsultationMessageCreateImplCopyWithImpl<
          _$ConsultationMessageCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationMessageCreateImplToJson(this);
  }
}

abstract class _ConsultationMessageCreate implements ConsultationMessageCreate {
  const factory _ConsultationMessageCreate({required final String content}) =
      _$ConsultationMessageCreateImpl;

  factory _ConsultationMessageCreate.fromJson(Map<String, dynamic> json) =
      _$ConsultationMessageCreateImpl.fromJson;

  @override
  String get content;
  @override
  @JsonKey(ignore: true)
  _$$ConsultationMessageCreateImplCopyWith<_$ConsultationMessageCreateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

WebRTCRoom _$WebRTCRoomFromJson(Map<String, dynamic> json) {
  return _WebRTCRoom.fromJson(json);
}

/// @nodoc
mixin _$WebRTCRoom {
  String get roomId => throw _privateConstructorUsedError;
  String get consultationId => throw _privateConstructorUsedError;
  List<IceServer> get iceServers => throw _privateConstructorUsedError;
  List<TurnServer>? get turnServers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WebRTCRoomCopyWith<WebRTCRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WebRTCRoomCopyWith<$Res> {
  factory $WebRTCRoomCopyWith(
          WebRTCRoom value, $Res Function(WebRTCRoom) then) =
      _$WebRTCRoomCopyWithImpl<$Res, WebRTCRoom>;
  @useResult
  $Res call({
    String roomId,
    String consultationId,
    List<IceServer> iceServers,
    List<TurnServer>? turnServers,
  });
}

/// @nodoc
class _$WebRTCRoomCopyWithImpl<$Res, $Val extends WebRTCRoom>
    implements $WebRTCRoomCopyWith<$Res> {
  _$WebRTCRoomCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? consultationId = null,
    Object? iceServers = null,
    Object? turnServers = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId ? _value.roomId : roomId as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      iceServers: null == iceServers
          ? _value.iceServers
          : iceServers as List<IceServer>,
      turnServers: freezed == turnServers
          ? _value.turnServers
          : turnServers as List<TurnServer>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WebRTCRoomImplCopyWith<$Res>
    implements $WebRTCRoomCopyWith<$Res> {
  factory _$$WebRTCRoomImplCopyWith(
          _$WebRTCRoomImpl value, $Res Function(_$WebRTCRoomImpl) then) =
      __$$WebRTCRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String roomId,
    String consultationId,
    List<IceServer> iceServers,
    List<TurnServer>? turnServers,
  });
}

/// @nodoc
class __$$WebRTCRoomImplCopyWithImpl<$Res>
    extends _$WebRTCRoomCopyWithImpl<$Res, _$WebRTCRoomImpl>
    implements _$$WebRTCRoomImplCopyWith<$Res> {
  __$$WebRTCRoomImplCopyWithImpl(
      _$WebRTCRoomImpl _value, $Res Function(_$WebRTCRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? consultationId = null,
    Object? iceServers = null,
    Object? turnServers = freezed,
  }) {
    return _then(_$WebRTCRoomImpl(
      roomId: null == roomId ? _value.roomId : roomId as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      iceServers: null == iceServers
          ? _value._iceServers
          : iceServers as List<IceServer>,
      turnServers: freezed == turnServers
          ? _value._turnServers
          : turnServers as List<TurnServer>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WebRTCRoomImpl implements _WebRTCRoom {
  const _$WebRTCRoomImpl({
    required this.roomId,
    required this.consultationId,
    required final List<IceServer> iceServers,
    final List<TurnServer>? turnServers,
  })  : _iceServers = iceServers,
        _turnServers = turnServers;

  factory _$WebRTCRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$WebRTCRoomImplFromJson(json);

  @override
  final String roomId;
  @override
  final String consultationId;
  final List<IceServer> _iceServers;
  @override
  List<IceServer> get iceServers {
    return List.unmodifiable(_iceServers);
  }

  final List<TurnServer>? _turnServers;
  @override
  List<TurnServer>? get turnServers {
    final value = _turnServers;
    if (value == null) return null;
    return List.unmodifiable(value);
  }

  @override
  String toString() {
    return 'WebRTCRoom(roomId: $roomId, consultationId: $consultationId, iceServers: $iceServers, turnServers: $turnServers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WebRTCRoomImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.consultationId, consultationId) ||
              other.consultationId == consultationId) &&
            (identical(other.iceServers, iceServers) ||
              other.iceServers == iceServers) &&
            (identical(other.turnServers, turnServers) ||
              other.turnServers == turnServers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, roomId, consultationId, iceServers, turnServers);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WebRTCRoomImplCopyWith<_$WebRTCRoomImpl> get copyWith =>
      __$$WebRTCRoomImplCopyWithImpl<_$WebRTCRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WebRTCRoomImplToJson(this);
  }
}

abstract class _WebRTCRoom implements WebRTCRoom {
  const factory _WebRTCRoom({
    required final String roomId,
    required final String consultationId,
    required final List<IceServer> iceServers,
    final List<TurnServer>? turnServers,
  }) = _$WebRTCRoomImpl;

  factory _WebRTCRoom.fromJson(Map<String, dynamic> json) =
      _$WebRTCRoomImpl.fromJson;

  @override
  String get roomId;
  @override
  String get consultationId;
  @override
  List<IceServer> get iceServers;
  @override
  List<TurnServer>? get turnServers;
  @override
  @JsonKey(ignore: true)
  _$$WebRTCRoomImplCopyWith<_$WebRTCRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
