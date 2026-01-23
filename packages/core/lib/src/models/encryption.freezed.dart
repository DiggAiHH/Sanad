// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'encryption.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This is not supported.');

EncryptedMessage _$EncryptedMessageFromJson(Map<String, dynamic> json) {
  return _EncryptedMessage.fromJson(json);
}

/// @nodoc
mixin _$EncryptedMessage {
  String get id => throw _privateConstructorUsedError;
  String get consultationId => throw _privateConstructorUsedError;
  String get ciphertext => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get senderRole => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get senderName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EncryptedMessageCopyWith<EncryptedMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptedMessageCopyWith<$Res> {
  factory $EncryptedMessageCopyWith(
          EncryptedMessage value, $Res Function(EncryptedMessage) then) =
      _$EncryptedMessageCopyWithImpl<$Res, EncryptedMessage>;
  @useResult
  $Res call(
      {String id,
      String consultationId,
      String ciphertext,
      String senderId,
      String senderRole,
      bool isRead,
      DateTime createdAt,
      String? senderName});
}

/// @nodoc
class _$EncryptedMessageCopyWithImpl<$Res, $Val extends EncryptedMessage>
    implements $EncryptedMessageCopyWith<$Res> {
  _$EncryptedMessageCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? ciphertext = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? senderName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      ciphertext: null == ciphertext
          ? _value.ciphertext
          : ciphertext as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId as String,
      senderRole: null == senderRole
          ? _value.senderRole
          : senderRole as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt as DateTime,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EncryptedMessageImplCopyWith<$Res>
    implements $EncryptedMessageCopyWith<$Res> {
  factory _$$EncryptedMessageImplCopyWith(_$EncryptedMessageImpl value,
          $Res Function(_$EncryptedMessageImpl) then) =
      __$$EncryptedMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String consultationId,
      String ciphertext,
      String senderId,
      String senderRole,
      bool isRead,
      DateTime createdAt,
      String? senderName});
}

/// @nodoc
class __$$EncryptedMessageImplCopyWithImpl<$Res>
    extends _$EncryptedMessageCopyWithImpl<$Res, _$EncryptedMessageImpl>
    implements _$$EncryptedMessageImplCopyWith<$Res> {
  __$$EncryptedMessageImplCopyWithImpl(_$EncryptedMessageImpl _value,
      $Res Function(_$EncryptedMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? consultationId = null,
    Object? ciphertext = null,
    Object? senderId = null,
    Object? senderRole = null,
    Object? isRead = null,
    Object? createdAt = null,
    Object? senderName = freezed,
  }) {
    return _then(_$EncryptedMessageImpl(
      id: null == id
          ? _value.id
          : id as String,
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      ciphertext: null == ciphertext
          ? _value.ciphertext
          : ciphertext as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId as String,
      senderRole: null == senderRole
          ? _value.senderRole
          : senderRole as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt as DateTime,
      senderName: freezed == senderName
          ? _value.senderName
          : senderName as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EncryptedMessageImpl implements _EncryptedMessage {
  const _$EncryptedMessageImpl(
      {required this.id,
      required this.consultationId,
      required this.ciphertext,
      required this.senderId,
      required this.senderRole,
      this.isRead = false,
      required this.createdAt,
      this.senderName});

  factory _$EncryptedMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$EncryptedMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String consultationId;
  @override
  final String ciphertext;
  @override
  final String senderId;
  @override
  final String senderRole;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final DateTime createdAt;
  @override
  final String? senderName;

  @override
  String toString() {
    return 'EncryptedMessage(id: $id, consultationId: $consultationId, ciphertext: $ciphertext, senderId: $senderId, senderRole: $senderRole, isRead: $isRead, createdAt: $createdAt, senderName: $senderName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptedMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.ciphertext, ciphertext) ||
                other.ciphertext == ciphertext) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderRole, senderRole) ||
                other.senderRole == senderRole) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, consultationId, ciphertext,
      senderId, senderRole, isRead, createdAt, senderName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptedMessageImplCopyWith<_$EncryptedMessageImpl> get copyWith =>
      __$$EncryptedMessageImplCopyWithImpl<_$EncryptedMessageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EncryptedMessageImplToJson(this);
  }
}

abstract class _EncryptedMessage implements EncryptedMessage {
  const factory _EncryptedMessage(
      {required final String id,
      required final String consultationId,
      required final String ciphertext,
      required final String senderId,
      required final String senderRole,
      final bool isRead,
      required final DateTime createdAt,
      final String? senderName}) = _$EncryptedMessageImpl;

  factory _EncryptedMessage.fromJson(Map<String, dynamic> json) =
      _$EncryptedMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get consultationId;
  @override
  String get ciphertext;
  @override
  String get senderId;
  @override
  String get senderRole;
  @override
  bool get isRead;
  @override
  DateTime get createdAt;
  @override
  String? get senderName;
  @override
  @JsonKey(ignore: true)
  _$$EncryptedMessageImplCopyWith<_$EncryptedMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeyExchangeRequest _$KeyExchangeRequestFromJson(Map<String, dynamic> json) {
  return _KeyExchangeRequest.fromJson(json);
}

/// @nodoc
mixin _$KeyExchangeRequest {
  String get consultationId => throw _privateConstructorUsedError;
  String get publicKey => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KeyExchangeRequestCopyWith<KeyExchangeRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyExchangeRequestCopyWith<$Res> {
  factory $KeyExchangeRequestCopyWith(
          KeyExchangeRequest value, $Res Function(KeyExchangeRequest) then) =
      _$KeyExchangeRequestCopyWithImpl<$Res, KeyExchangeRequest>;
  @useResult
  $Res call({String consultationId, String publicKey});
}

/// @nodoc
class _$KeyExchangeRequestCopyWithImpl<$Res, $Val extends KeyExchangeRequest>
    implements $KeyExchangeRequestCopyWith<$Res> {
  _$KeyExchangeRequestCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? publicKey = null,
  }) {
    return _then(_value.copyWith(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyExchangeRequestImplCopyWith<$Res>
    implements $KeyExchangeRequestCopyWith<$Res> {
  factory _$$KeyExchangeRequestImplCopyWith(_$KeyExchangeRequestImpl value,
          $Res Function(_$KeyExchangeRequestImpl) then) =
      __$$KeyExchangeRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String consultationId, String publicKey});
}

/// @nodoc
class __$$KeyExchangeRequestImplCopyWithImpl<$Res>
    extends _$KeyExchangeRequestCopyWithImpl<$Res, _$KeyExchangeRequestImpl>
    implements _$$KeyExchangeRequestImplCopyWith<$Res> {
  __$$KeyExchangeRequestImplCopyWithImpl(_$KeyExchangeRequestImpl _value,
      $Res Function(_$KeyExchangeRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? publicKey = null,
  }) {
    return _then(_$KeyExchangeRequestImpl(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      publicKey: null == publicKey
          ? _value.publicKey
          : publicKey as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KeyExchangeRequestImpl implements _KeyExchangeRequest {
  const _$KeyExchangeRequestImpl(
      {required this.consultationId, required this.publicKey});

  factory _$KeyExchangeRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyExchangeRequestImplFromJson(json);

  @override
  final String consultationId;
  @override
  final String publicKey;

  @override
  String toString() {
    return 'KeyExchangeRequest(consultationId: $consultationId, publicKey: $publicKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyExchangeRequestImpl &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.publicKey, publicKey) ||
                other.publicKey == publicKey));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, consultationId, publicKey);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyExchangeRequestImplCopyWith<_$KeyExchangeRequestImpl> get copyWith =>
      __$$KeyExchangeRequestImplCopyWithImpl<_$KeyExchangeRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyExchangeRequestImplToJson(this);
  }
}

abstract class _KeyExchangeRequest implements KeyExchangeRequest {
  const factory _KeyExchangeRequest(
      {required final String consultationId,
      required final String publicKey}) = _$KeyExchangeRequestImpl;

  factory _KeyExchangeRequest.fromJson(Map<String, dynamic> json) =
      _$KeyExchangeRequestImpl.fromJson;

  @override
  String get consultationId;
  @override
  String get publicKey;
  @override
  @JsonKey(ignore: true)
  _$$KeyExchangeRequestImplCopyWith<_$KeyExchangeRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeyExchangeResponse _$KeyExchangeResponseFromJson(Map<String, dynamic> json) {
  return _KeyExchangeResponse.fromJson(json);
}

/// @nodoc
mixin _$KeyExchangeResponse {
  String get consultationId => throw _privateConstructorUsedError;
  String get salt => throw _privateConstructorUsedError;
  bool get encryptionEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KeyExchangeResponseCopyWith<KeyExchangeResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeyExchangeResponseCopyWith<$Res> {
  factory $KeyExchangeResponseCopyWith(
          KeyExchangeResponse value, $Res Function(KeyExchangeResponse) then) =
      _$KeyExchangeResponseCopyWithImpl<$Res, KeyExchangeResponse>;
  @useResult
  $Res call({String consultationId, String salt, bool encryptionEnabled});
}

/// @nodoc
class _$KeyExchangeResponseCopyWithImpl<$Res, $Val extends KeyExchangeResponse>
    implements $KeyExchangeResponseCopyWith<$Res> {
  _$KeyExchangeResponseCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? salt = null,
    Object? encryptionEnabled = null,
  }) {
    return _then(_value.copyWith(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      salt: null == salt
          ? _value.salt
          : salt as String,
      encryptionEnabled: null == encryptionEnabled
          ? _value.encryptionEnabled
          : encryptionEnabled as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KeyExchangeResponseImplCopyWith<$Res>
    implements $KeyExchangeResponseCopyWith<$Res> {
  factory _$$KeyExchangeResponseImplCopyWith(_$KeyExchangeResponseImpl value,
          $Res Function(_$KeyExchangeResponseImpl) then) =
      __$$KeyExchangeResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String consultationId, String salt, bool encryptionEnabled});
}

/// @nodoc
class __$$KeyExchangeResponseImplCopyWithImpl<$Res>
    extends _$KeyExchangeResponseCopyWithImpl<$Res, _$KeyExchangeResponseImpl>
    implements _$$KeyExchangeResponseImplCopyWith<$Res> {
  __$$KeyExchangeResponseImplCopyWithImpl(_$KeyExchangeResponseImpl _value,
      $Res Function(_$KeyExchangeResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? salt = null,
    Object? encryptionEnabled = null,
  }) {
    return _then(_$KeyExchangeResponseImpl(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      salt: null == salt
          ? _value.salt
          : salt as String,
      encryptionEnabled: null == encryptionEnabled
          ? _value.encryptionEnabled
          : encryptionEnabled as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KeyExchangeResponseImpl implements _KeyExchangeResponse {
  const _$KeyExchangeResponseImpl(
      {required this.consultationId,
      required this.salt,
      required this.encryptionEnabled});

  factory _$KeyExchangeResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeyExchangeResponseImplFromJson(json);

  @override
  final String consultationId;
  @override
  final String salt;
  @override
  final bool encryptionEnabled;

  @override
  String toString() {
    return 'KeyExchangeResponse(consultationId: $consultationId, salt: $salt, encryptionEnabled: $encryptionEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeyExchangeResponseImpl &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.salt, salt) || other.salt == salt) &&
            (identical(other.encryptionEnabled, encryptionEnabled) ||
                other.encryptionEnabled == encryptionEnabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, consultationId, salt, encryptionEnabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KeyExchangeResponseImplCopyWith<_$KeyExchangeResponseImpl> get copyWith =>
      __$$KeyExchangeResponseImplCopyWithImpl<_$KeyExchangeResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeyExchangeResponseImplToJson(this);
  }
}

abstract class _KeyExchangeResponse implements KeyExchangeResponse {
  const factory _KeyExchangeResponse(
      {required final String consultationId,
      required final String salt,
      required final bool encryptionEnabled}) = _$KeyExchangeResponseImpl;

  factory _KeyExchangeResponse.fromJson(Map<String, dynamic> json) =
      _$KeyExchangeResponseImpl.fromJson;

  @override
  String get consultationId;
  @override
  String get salt;
  @override
  bool get encryptionEnabled;
  @override
  @JsonKey(ignore: true)
  _$$KeyExchangeResponseImplCopyWith<_$KeyExchangeResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EncryptionStatus _$EncryptionStatusFromJson(Map<String, dynamic> json) {
  return _EncryptionStatus.fromJson(json);
}

/// @nodoc
mixin _$EncryptionStatus {
  String get consultationId => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  bool get keyExchangeComplete => throw _privateConstructorUsedError;
  DateTime? get enabledAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EncryptionStatusCopyWith<EncryptionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EncryptionStatusCopyWith<$Res> {
  factory $EncryptionStatusCopyWith(
          EncryptionStatus value, $Res Function(EncryptionStatus) then) =
      _$EncryptionStatusCopyWithImpl<$Res, EncryptionStatus>;
  @useResult
  $Res call(
      {String consultationId,
      bool isEnabled,
      bool keyExchangeComplete,
      DateTime? enabledAt});
}

/// @nodoc
class _$EncryptionStatusCopyWithImpl<$Res, $Val extends EncryptionStatus>
    implements $EncryptionStatusCopyWith<$Res> {
  _$EncryptionStatusCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? isEnabled = null,
    Object? keyExchangeComplete = null,
    Object? enabledAt = freezed,
  }) {
    return _then(_value.copyWith(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled as bool,
      keyExchangeComplete: null == keyExchangeComplete
          ? _value.keyExchangeComplete
          : keyExchangeComplete as bool,
      enabledAt: freezed == enabledAt
          ? _value.enabledAt
          : enabledAt as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EncryptionStatusImplCopyWith<$Res>
    implements $EncryptionStatusCopyWith<$Res> {
  factory _$$EncryptionStatusImplCopyWith(_$EncryptionStatusImpl value,
          $Res Function(_$EncryptionStatusImpl) then) =
      __$$EncryptionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String consultationId,
      bool isEnabled,
      bool keyExchangeComplete,
      DateTime? enabledAt});
}

/// @nodoc
class __$$EncryptionStatusImplCopyWithImpl<$Res>
    extends _$EncryptionStatusCopyWithImpl<$Res, _$EncryptionStatusImpl>
    implements _$$EncryptionStatusImplCopyWith<$Res> {
  __$$EncryptionStatusImplCopyWithImpl(_$EncryptionStatusImpl _value,
      $Res Function(_$EncryptionStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? consultationId = null,
    Object? isEnabled = null,
    Object? keyExchangeComplete = null,
    Object? enabledAt = freezed,
  }) {
    return _then(_$EncryptionStatusImpl(
      consultationId: null == consultationId
          ? _value.consultationId
          : consultationId as String,
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled as bool,
      keyExchangeComplete: null == keyExchangeComplete
          ? _value.keyExchangeComplete
          : keyExchangeComplete as bool,
      enabledAt: freezed == enabledAt
          ? _value.enabledAt
          : enabledAt as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EncryptionStatusImpl implements _EncryptionStatus {
  const _$EncryptionStatusImpl(
      {required this.consultationId,
      required this.isEnabled,
      required this.keyExchangeComplete,
      this.enabledAt});

  factory _$EncryptionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$EncryptionStatusImplFromJson(json);

  @override
  final String consultationId;
  @override
  final bool isEnabled;
  @override
  final bool keyExchangeComplete;
  @override
  final DateTime? enabledAt;

  @override
  String toString() {
    return 'EncryptionStatus(consultationId: $consultationId, isEnabled: $isEnabled, keyExchangeComplete: $keyExchangeComplete, enabledAt: $enabledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptionStatusImpl &&
            (identical(other.consultationId, consultationId) ||
                other.consultationId == consultationId) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.keyExchangeComplete, keyExchangeComplete) ||
                other.keyExchangeComplete == keyExchangeComplete) &&
            (identical(other.enabledAt, enabledAt) ||
                other.enabledAt == enabledAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, consultationId, isEnabled, keyExchangeComplete, enabledAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptionStatusImplCopyWith<_$EncryptionStatusImpl> get copyWith =>
      __$$EncryptionStatusImplCopyWithImpl<_$EncryptionStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EncryptionStatusImplToJson(this);
  }
}

abstract class _EncryptionStatus implements EncryptionStatus {
  const factory _EncryptionStatus(
      {required final String consultationId,
      required final bool isEnabled,
      required final bool keyExchangeComplete,
      final DateTime? enabledAt}) = _$EncryptionStatusImpl;

  factory _EncryptionStatus.fromJson(Map<String, dynamic> json) =
      _$EncryptionStatusImpl.fromJson;

  @override
  String get consultationId;
  @override
  bool get isEnabled;
  @override
  bool get keyExchangeComplete;
  @override
  DateTime? get enabledAt;
  @override
  @JsonKey(ignore: true)
  _$$EncryptionStatusImplCopyWith<_$EncryptionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
