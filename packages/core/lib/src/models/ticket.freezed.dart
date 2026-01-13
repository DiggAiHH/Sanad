// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Ticket _$TicketFromJson(Map<String, dynamic> json) {
  return _Ticket.fromJson(json);
}

/// @nodoc
mixin _$Ticket {
  String get id => throw _privateConstructorUsedError;
  String get ticketNumber => throw _privateConstructorUsedError;
  String get prefix => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get practiceId => throw _privateConstructorUsedError;
  String? get assignedStaffId => throw _privateConstructorUsedError;
  String? get roomNumber => throw _privateConstructorUsedError;
  TicketStatus get status => throw _privateConstructorUsedError;
  TicketPriority get priority => throw _privateConstructorUsedError;
  String? get visitReason => throw _privateConstructorUsedError;
  DateTime get issuedAt => throw _privateConstructorUsedError;
  DateTime? get calledAt => throw _privateConstructorUsedError;
  DateTime? get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int? get estimatedWaitMinutes => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TicketCopyWith<Ticket> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TicketCopyWith<$Res> {
  factory $TicketCopyWith(Ticket value, $Res Function(Ticket) then) =
      _$TicketCopyWithImpl<$Res, Ticket>;
  @useResult
  $Res call({
    String id,
    String ticketNumber,
    String prefix,
    int number,
    String patientId,
    String practiceId,
    String? assignedStaffId,
    String? roomNumber,
    TicketStatus status,
    TicketPriority priority,
    String? visitReason,
    DateTime issuedAt,
    DateTime? calledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedWaitMinutes,
    String? notes,
  });
}

/// @nodoc
class _$TicketCopyWithImpl<$Res, $Val extends Ticket>
    implements $TicketCopyWith<$Res> {
  _$TicketCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketNumber = null,
    Object? prefix = null,
    Object? number = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? assignedStaffId = freezed,
    Object? roomNumber = freezed,
    Object? status = null,
    Object? priority = null,
    Object? visitReason = freezed,
    Object? issuedAt = null,
    Object? calledAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? estimatedWaitMinutes = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      ticketNumber: null == ticketNumber ? _value.ticketNumber : ticketNumber as String,
      prefix: null == prefix ? _value.prefix : prefix as String,
      number: null == number ? _value.number : number as int,
      patientId: null == patientId ? _value.patientId : patientId as String,
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      assignedStaffId: freezed == assignedStaffId ? _value.assignedStaffId : assignedStaffId as String?,
      roomNumber: freezed == roomNumber ? _value.roomNumber : roomNumber as String?,
      status: null == status ? _value.status : status as TicketStatus,
      priority: null == priority ? _value.priority : priority as TicketPriority,
      visitReason: freezed == visitReason ? _value.visitReason : visitReason as String?,
      issuedAt: null == issuedAt ? _value.issuedAt : issuedAt as DateTime,
      calledAt: freezed == calledAt ? _value.calledAt : calledAt as DateTime?,
      startedAt: freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      completedAt: freezed == completedAt ? _value.completedAt : completedAt as DateTime?,
      estimatedWaitMinutes: freezed == estimatedWaitMinutes ? _value.estimatedWaitMinutes : estimatedWaitMinutes as int?,
      notes: freezed == notes ? _value.notes : notes as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TicketImplCopyWith<$Res> implements $TicketCopyWith<$Res> {
  factory _$$TicketImplCopyWith(_$TicketImpl value, $Res Function(_$TicketImpl) then) =
      __$$TicketImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String ticketNumber,
    String prefix,
    int number,
    String patientId,
    String practiceId,
    String? assignedStaffId,
    String? roomNumber,
    TicketStatus status,
    TicketPriority priority,
    String? visitReason,
    DateTime issuedAt,
    DateTime? calledAt,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedWaitMinutes,
    String? notes,
  });
}

/// @nodoc
class __$$TicketImplCopyWithImpl<$Res> extends _$TicketCopyWithImpl<$Res, _$TicketImpl>
    implements _$$TicketImplCopyWith<$Res> {
  __$$TicketImplCopyWithImpl(_$TicketImpl _value, $Res Function(_$TicketImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ticketNumber = null,
    Object? prefix = null,
    Object? number = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? assignedStaffId = freezed,
    Object? roomNumber = freezed,
    Object? status = null,
    Object? priority = null,
    Object? visitReason = freezed,
    Object? issuedAt = null,
    Object? calledAt = freezed,
    Object? startedAt = freezed,
    Object? completedAt = freezed,
    Object? estimatedWaitMinutes = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$TicketImpl(
      id: null == id ? _value.id : id as String,
      ticketNumber: null == ticketNumber ? _value.ticketNumber : ticketNumber as String,
      prefix: null == prefix ? _value.prefix : prefix as String,
      number: null == number ? _value.number : number as int,
      patientId: null == patientId ? _value.patientId : patientId as String,
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      assignedStaffId: freezed == assignedStaffId ? _value.assignedStaffId : assignedStaffId as String?,
      roomNumber: freezed == roomNumber ? _value.roomNumber : roomNumber as String?,
      status: null == status ? _value.status : status as TicketStatus,
      priority: null == priority ? _value.priority : priority as TicketPriority,
      visitReason: freezed == visitReason ? _value.visitReason : visitReason as String?,
      issuedAt: null == issuedAt ? _value.issuedAt : issuedAt as DateTime,
      calledAt: freezed == calledAt ? _value.calledAt : calledAt as DateTime?,
      startedAt: freezed == startedAt ? _value.startedAt : startedAt as DateTime?,
      completedAt: freezed == completedAt ? _value.completedAt : completedAt as DateTime?,
      estimatedWaitMinutes: freezed == estimatedWaitMinutes ? _value.estimatedWaitMinutes : estimatedWaitMinutes as int?,
      notes: freezed == notes ? _value.notes : notes as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TicketImpl implements _Ticket {
  const _$TicketImpl({
    required this.id,
    required this.ticketNumber,
    required this.prefix,
    required this.number,
    required this.patientId,
    required this.practiceId,
    this.assignedStaffId,
    this.roomNumber,
    required this.status,
    this.priority = TicketPriority.normal,
    this.visitReason,
    required this.issuedAt,
    this.calledAt,
    this.startedAt,
    this.completedAt,
    this.estimatedWaitMinutes,
    this.notes,
  });

  factory _$TicketImpl.fromJson(Map<String, dynamic> json) => _$$TicketImplFromJson(json);

  @override
  final String id;
  @override
  final String ticketNumber;
  @override
  final String prefix;
  @override
  final int number;
  @override
  final String patientId;
  @override
  final String practiceId;
  @override
  final String? assignedStaffId;
  @override
  final String? roomNumber;
  @override
  final TicketStatus status;
  @override
  @JsonKey()
  final TicketPriority priority;
  @override
  final String? visitReason;
  @override
  final DateTime issuedAt;
  @override
  final DateTime? calledAt;
  @override
  final DateTime? startedAt;
  @override
  final DateTime? completedAt;
  @override
  final int? estimatedWaitMinutes;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Ticket(id: $id, ticketNumber: $ticketNumber, prefix: $prefix, number: $number, patientId: $patientId, practiceId: $practiceId, assignedStaffId: $assignedStaffId, roomNumber: $roomNumber, status: $status, priority: $priority, visitReason: $visitReason, issuedAt: $issuedAt, calledAt: $calledAt, startedAt: $startedAt, completedAt: $completedAt, estimatedWaitMinutes: $estimatedWaitMinutes, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TicketImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ticketNumber, ticketNumber) || other.ticketNumber == ticketNumber) &&
            (identical(other.prefix, prefix) || other.prefix == prefix) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.patientId, patientId) || other.patientId == patientId) &&
            (identical(other.practiceId, practiceId) || other.practiceId == practiceId) &&
            (identical(other.assignedStaffId, assignedStaffId) || other.assignedStaffId == assignedStaffId) &&
            (identical(other.roomNumber, roomNumber) || other.roomNumber == roomNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) || other.priority == priority) &&
            (identical(other.visitReason, visitReason) || other.visitReason == visitReason) &&
            (identical(other.issuedAt, issuedAt) || other.issuedAt == issuedAt) &&
            (identical(other.calledAt, calledAt) || other.calledAt == calledAt) &&
            (identical(other.startedAt, startedAt) || other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) || other.completedAt == completedAt) &&
            (identical(other.estimatedWaitMinutes, estimatedWaitMinutes) || other.estimatedWaitMinutes == estimatedWaitMinutes) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, ticketNumber, prefix, number, patientId, practiceId, assignedStaffId, roomNumber, status, priority, visitReason, issuedAt, calledAt, startedAt, completedAt, estimatedWaitMinutes, notes);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TicketImplCopyWith<_$TicketImpl> get copyWith => __$$TicketImplCopyWithImpl<_$TicketImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TicketImplToJson(this);
  }
}

abstract class _Ticket implements Ticket {
  const factory _Ticket({
    required final String id,
    required final String ticketNumber,
    required final String prefix,
    required final int number,
    required final String patientId,
    required final String practiceId,
    final String? assignedStaffId,
    final String? roomNumber,
    required final TicketStatus status,
    final TicketPriority priority,
    final String? visitReason,
    required final DateTime issuedAt,
    final DateTime? calledAt,
    final DateTime? startedAt,
    final DateTime? completedAt,
    final int? estimatedWaitMinutes,
    final String? notes,
  }) = _$TicketImpl;

  factory _Ticket.fromJson(Map<String, dynamic> json) = _$TicketImpl.fromJson;

  @override String get id;
  @override String get ticketNumber;
  @override String get prefix;
  @override int get number;
  @override String get patientId;
  @override String get practiceId;
  @override String? get assignedStaffId;
  @override String? get roomNumber;
  @override TicketStatus get status;
  @override TicketPriority get priority;
  @override String? get visitReason;
  @override DateTime get issuedAt;
  @override DateTime? get calledAt;
  @override DateTime? get startedAt;
  @override DateTime? get completedAt;
  @override int? get estimatedWaitMinutes;
  @override String? get notes;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TicketImplCopyWith<_$TicketImpl> get copyWith => throw _privateConstructorUsedError;
}
