// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) {
  return _ChatRoom.fromJson(json);
}

/// @nodoc
mixin _$ChatRoom {
  String get id => throw _privateConstructorUsedError;
  String get practiceId => throw _privateConstructorUsedError;
  ChatRoomType get type => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  List<String> get adminIds => throw _privateConstructorUsedError;
  ChatMessage? get lastMessage => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomCopyWith<ChatRoom> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomCopyWith<$Res> {
  factory $ChatRoomCopyWith(ChatRoom value, $Res Function(ChatRoom) then) = _$ChatRoomCopyWithImpl<$Res, ChatRoom>;
  @useResult
  $Res call({
    String id,
    String practiceId,
    ChatRoomType type,
    String? name,
    String? avatarUrl,
    List<String> memberIds,
    List<String> adminIds,
    ChatMessage? lastMessage,
    DateTime createdAt,
    DateTime? updatedAt,
    bool isActive,
  });

  $ChatMessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$ChatRoomCopyWithImpl<$Res, $Val extends ChatRoom> implements $ChatRoomCopyWith<$Res> {
  _$ChatRoomCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? practiceId = null,
    Object? type = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
    Object? memberIds = null,
    Object? adminIds = null,
    Object? lastMessage = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      type: null == type ? _value.type : type as ChatRoomType,
      name: freezed == name ? _value.name : name as String?,
      avatarUrl: freezed == avatarUrl ? _value.avatarUrl : avatarUrl as String?,
      memberIds: null == memberIds ? _value.memberIds : memberIds as List<String>,
      adminIds: null == adminIds ? _value.adminIds : adminIds as List<String>,
      lastMessage: freezed == lastMessage ? _value.lastMessage : lastMessage as ChatMessage?,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      isActive: null == isActive ? _value.isActive : isActive as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChatMessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }
    return $ChatMessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomImplCopyWith<$Res> implements $ChatRoomCopyWith<$Res> {
  factory _$$ChatRoomImplCopyWith(_$ChatRoomImpl value, $Res Function(_$ChatRoomImpl) then) = __$$ChatRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String practiceId,
    ChatRoomType type,
    String? name,
    String? avatarUrl,
    List<String> memberIds,
    List<String> adminIds,
    ChatMessage? lastMessage,
    DateTime createdAt,
    DateTime? updatedAt,
    bool isActive,
  });

  @override
  $ChatMessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$ChatRoomImplCopyWithImpl<$Res> extends _$ChatRoomCopyWithImpl<$Res, _$ChatRoomImpl> implements _$$ChatRoomImplCopyWith<$Res> {
  __$$ChatRoomImplCopyWithImpl(_$ChatRoomImpl _value, $Res Function(_$ChatRoomImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? practiceId = null,
    Object? type = null,
    Object? name = freezed,
    Object? avatarUrl = freezed,
    Object? memberIds = null,
    Object? adminIds = null,
    Object? lastMessage = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_$ChatRoomImpl(
      id: null == id ? _value.id : id as String,
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      type: null == type ? _value.type : type as ChatRoomType,
      name: freezed == name ? _value.name : name as String?,
      avatarUrl: freezed == avatarUrl ? _value.avatarUrl : avatarUrl as String?,
      memberIds: null == memberIds ? _value._memberIds : memberIds as List<String>,
      adminIds: null == adminIds ? _value._adminIds : adminIds as List<String>,
      lastMessage: freezed == lastMessage ? _value.lastMessage : lastMessage as ChatMessage?,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
      isActive: null == isActive ? _value.isActive : isActive as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomImpl implements _ChatRoom {
  const _$ChatRoomImpl({
    required this.id,
    required this.practiceId,
    required this.type,
    this.name,
    this.avatarUrl,
    required final List<String> memberIds,
    final List<String> adminIds = const [],
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  })  : _memberIds = memberIds,
        _adminIds = adminIds;

  factory _$ChatRoomImpl.fromJson(Map<String, dynamic> json) => _$$ChatRoomImplFromJson(json);

  @override
  final String id;
  @override
  final String practiceId;
  @override
  final ChatRoomType type;
  @override
  final String? name;
  @override
  final String? avatarUrl;
  final List<String> _memberIds;
  @override
  List<String> get memberIds => List.unmodifiable(_memberIds);
  final List<String> _adminIds;
  @override
  @JsonKey()
  List<String> get adminIds => List.unmodifiable(_adminIds);
  @override
  final ChatMessage? lastMessage;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ChatRoom(id: $id, practiceId: $practiceId, type: $type, name: $name, avatarUrl: $avatarUrl, memberIds: $memberIds, adminIds: $adminIds, lastMessage: $lastMessage, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.practiceId, practiceId) || other.practiceId == practiceId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl) &&
            const DeepCollectionEquality().equals(other._memberIds, _memberIds) &&
            const DeepCollectionEquality().equals(other._adminIds, _adminIds) &&
            (identical(other.lastMessage, lastMessage) || other.lastMessage == lastMessage) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt) &&
            (identical(other.isActive, isActive) || other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, practiceId, type, name, avatarUrl, const DeepCollectionEquality().hash(_memberIds), const DeepCollectionEquality().hash(_adminIds), lastMessage, createdAt, updatedAt, isActive);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith => __$$ChatRoomImplCopyWithImpl<_$ChatRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomImplToJson(this);
  }
}

abstract class _ChatRoom implements ChatRoom {
  const factory _ChatRoom({
    required final String id,
    required final String practiceId,
    required final ChatRoomType type,
    final String? name,
    final String? avatarUrl,
    required final List<String> memberIds,
    final List<String> adminIds,
    final ChatMessage? lastMessage,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final bool isActive,
  }) = _$ChatRoomImpl;

  factory _ChatRoom.fromJson(Map<String, dynamic> json) = _$ChatRoomImpl.fromJson;

  @override String get id;
  @override String get practiceId;
  @override ChatRoomType get type;
  @override String? get name;
  @override String? get avatarUrl;
  @override List<String> get memberIds;
  @override List<String> get adminIds;
  @override ChatMessage? get lastMessage;
  @override DateTime get createdAt;
  @override DateTime? get updatedAt;
  @override bool get isActive;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomImplCopyWith<_$ChatRoomImpl> get copyWith => throw _privateConstructorUsedError;
}

ChatRoomUnread _$ChatRoomUnreadFromJson(Map<String, dynamic> json) {
  return _ChatRoomUnread.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomUnread {
  String get roomId => throw _privateConstructorUsedError;
  String get oderId => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  DateTime? get lastReadAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomUnreadCopyWith<ChatRoomUnread> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomUnreadCopyWith<$Res> {
  factory $ChatRoomUnreadCopyWith(ChatRoomUnread value, $Res Function(ChatRoomUnread) then) = _$ChatRoomUnreadCopyWithImpl<$Res, ChatRoomUnread>;
  @useResult
  $Res call({String roomId, String oderId, int unreadCount, DateTime? lastReadAt});
}

/// @nodoc
class _$ChatRoomUnreadCopyWithImpl<$Res, $Val extends ChatRoomUnread> implements $ChatRoomUnreadCopyWith<$Res> {
  _$ChatRoomUnreadCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? oderId = null,
    Object? unreadCount = null,
    Object? lastReadAt = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId ? _value.roomId : roomId as String,
      oderId: null == oderId ? _value.oderId : oderId as String,
      unreadCount: null == unreadCount ? _value.unreadCount : unreadCount as int,
      lastReadAt: freezed == lastReadAt ? _value.lastReadAt : lastReadAt as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatRoomUnreadImplCopyWith<$Res> implements $ChatRoomUnreadCopyWith<$Res> {
  factory _$$ChatRoomUnreadImplCopyWith(_$ChatRoomUnreadImpl value, $Res Function(_$ChatRoomUnreadImpl) then) = __$$ChatRoomUnreadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String roomId, String oderId, int unreadCount, DateTime? lastReadAt});
}

/// @nodoc
class __$$ChatRoomUnreadImplCopyWithImpl<$Res> extends _$ChatRoomUnreadCopyWithImpl<$Res, _$ChatRoomUnreadImpl> implements _$$ChatRoomUnreadImplCopyWith<$Res> {
  __$$ChatRoomUnreadImplCopyWithImpl(_$ChatRoomUnreadImpl _value, $Res Function(_$ChatRoomUnreadImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? oderId = null,
    Object? unreadCount = null,
    Object? lastReadAt = freezed,
  }) {
    return _then(_$ChatRoomUnreadImpl(
      roomId: null == roomId ? _value.roomId : roomId as String,
      oderId: null == oderId ? _value.oderId : oderId as String,
      unreadCount: null == unreadCount ? _value.unreadCount : unreadCount as int,
      lastReadAt: freezed == lastReadAt ? _value.lastReadAt : lastReadAt as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomUnreadImpl implements _ChatRoomUnread {
  const _$ChatRoomUnreadImpl({
    required this.roomId,
    required this.oderId,
    required this.unreadCount,
    this.lastReadAt,
  });

  factory _$ChatRoomUnreadImpl.fromJson(Map<String, dynamic> json) => _$$ChatRoomUnreadImplFromJson(json);

  @override
  final String roomId;
  @override
  final String oderId;
  @override
  final int unreadCount;
  @override
  final DateTime? lastReadAt;

  @override
  String toString() {
    return 'ChatRoomUnread(roomId: $roomId, oderId: $oderId, unreadCount: $unreadCount, lastReadAt: $lastReadAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomUnreadImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.oderId, oderId) || other.oderId == oderId) &&
            (identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount) &&
            (identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, roomId, oderId, unreadCount, lastReadAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomUnreadImplCopyWith<_$ChatRoomUnreadImpl> get copyWith => __$$ChatRoomUnreadImplCopyWithImpl<_$ChatRoomUnreadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomUnreadImplToJson(this);
  }
}

abstract class _ChatRoomUnread implements ChatRoomUnread {
  const factory _ChatRoomUnread({
    required final String roomId,
    required final String oderId,
    required final int unreadCount,
    final DateTime? lastReadAt,
  }) = _$ChatRoomUnreadImpl;

  factory _ChatRoomUnread.fromJson(Map<String, dynamic> json) = _$ChatRoomUnreadImpl.fromJson;

  @override String get roomId;
  @override String get oderId;
  @override int get unreadCount;
  @override DateTime? get lastReadAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomUnreadImplCopyWith<_$ChatRoomUnreadImpl> get copyWith => throw _privateConstructorUsedError;
}
