// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get id => throw _privateConstructorUsedError;
  String get roomId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get attachmentUrl => throw _privateConstructorUsedError;
  String? get attachmentName => throw _privateConstructorUsedError;
  String? get replyToMessageId => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  List<String> get readBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get editedAt => throw _privateConstructorUsedError;
  bool get isDeleted => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatMessageCopyWith<ChatMessage> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) then) = _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({
    String id,
    String roomId,
    String senderId,
    MessageType type,
    String content,
    String? attachmentUrl,
    String? attachmentName,
    String? replyToMessageId,
    MessageStatus status,
    List<String> readBy,
    DateTime createdAt,
    DateTime? editedAt,
    bool isDeleted,
  });
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage> implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? type = null,
    Object? content = null,
    Object? attachmentUrl = freezed,
    Object? attachmentName = freezed,
    Object? replyToMessageId = freezed,
    Object? status = null,
    Object? readBy = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      roomId: null == roomId ? _value.roomId : roomId as String,
      senderId: null == senderId ? _value.senderId : senderId as String,
      type: null == type ? _value.type : type as MessageType,
      content: null == content ? _value.content : content as String,
      attachmentUrl: freezed == attachmentUrl ? _value.attachmentUrl : attachmentUrl as String?,
      attachmentName: freezed == attachmentName ? _value.attachmentName : attachmentName as String?,
      replyToMessageId: freezed == replyToMessageId ? _value.replyToMessageId : replyToMessageId as String?,
      status: null == status ? _value.status : status as MessageStatus,
      readBy: null == readBy ? _value.readBy : readBy as List<String>,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      editedAt: freezed == editedAt ? _value.editedAt : editedAt as DateTime?,
      isDeleted: null == isDeleted ? _value.isDeleted : isDeleted as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(_$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) = __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String roomId,
    String senderId,
    MessageType type,
    String content,
    String? attachmentUrl,
    String? attachmentName,
    String? replyToMessageId,
    MessageStatus status,
    List<String> readBy,
    DateTime createdAt,
    DateTime? editedAt,
    bool isDeleted,
  });
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res> extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl> implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(_$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? type = null,
    Object? content = null,
    Object? attachmentUrl = freezed,
    Object? attachmentName = freezed,
    Object? replyToMessageId = freezed,
    Object? status = null,
    Object? readBy = null,
    Object? createdAt = null,
    Object? editedAt = freezed,
    Object? isDeleted = null,
  }) {
    return _then(_$ChatMessageImpl(
      id: null == id ? _value.id : id as String,
      roomId: null == roomId ? _value.roomId : roomId as String,
      senderId: null == senderId ? _value.senderId : senderId as String,
      type: null == type ? _value.type : type as MessageType,
      content: null == content ? _value.content : content as String,
      attachmentUrl: freezed == attachmentUrl ? _value.attachmentUrl : attachmentUrl as String?,
      attachmentName: freezed == attachmentName ? _value.attachmentName : attachmentName as String?,
      replyToMessageId: freezed == replyToMessageId ? _value.replyToMessageId : replyToMessageId as String?,
      status: null == status ? _value.status : status as MessageStatus,
      readBy: null == readBy ? _value._readBy : readBy as List<String>,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      editedAt: freezed == editedAt ? _value.editedAt : editedAt as DateTime?,
      isDeleted: null == isDeleted ? _value.isDeleted : isDeleted as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.type,
    required this.content,
    this.attachmentUrl,
    this.attachmentName,
    this.replyToMessageId,
    required this.status,
    final List<String> readBy = const [],
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
  }) : _readBy = readBy;

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) => _$$ChatMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String roomId;
  @override
  final String senderId;
  @override
  final MessageType type;
  @override
  final String content;
  @override
  final String? attachmentUrl;
  @override
  final String? attachmentName;
  @override
  final String? replyToMessageId;
  @override
  final MessageStatus status;
  final List<String> _readBy;
  @override
  @JsonKey()
  List<String> get readBy => List.unmodifiable(_readBy);
  @override
  final DateTime createdAt;
  @override
  final DateTime? editedAt;
  @override
  @JsonKey()
  final bool isDeleted;

  @override
  String toString() {
    return 'ChatMessage(id: $id, roomId: $roomId, senderId: $senderId, type: $type, content: $content, attachmentUrl: $attachmentUrl, attachmentName: $attachmentName, replyToMessageId: $replyToMessageId, status: $status, readBy: $readBy, createdAt: $createdAt, editedAt: $editedAt, isDeleted: $isDeleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.senderId, senderId) || other.senderId == senderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl) &&
            (identical(other.attachmentName, attachmentName) || other.attachmentName == attachmentName) &&
            (identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.editedAt, editedAt) || other.editedAt == editedAt) &&
            (identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, roomId, senderId, type, content, attachmentUrl, attachmentName, replyToMessageId, status, const DeepCollectionEquality().hash(_readBy), createdAt, editedAt, isDeleted);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith => __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(this);
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage({
    required final String id,
    required final String roomId,
    required final String senderId,
    required final MessageType type,
    required final String content,
    final String? attachmentUrl,
    final String? attachmentName,
    final String? replyToMessageId,
    required final MessageStatus status,
    final List<String> readBy,
    required final DateTime createdAt,
    final DateTime? editedAt,
    final bool isDeleted,
  }) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) = _$ChatMessageImpl.fromJson;

  @override String get id;
  @override String get roomId;
  @override String get senderId;
  @override MessageType get type;
  @override String get content;
  @override String? get attachmentUrl;
  @override String? get attachmentName;
  @override String? get replyToMessageId;
  @override MessageStatus get status;
  @override List<String> get readBy;
  @override DateTime get createdAt;
  @override DateTime? get editedAt;
  @override bool get isDeleted;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith => throw _privateConstructorUsedError;
}
