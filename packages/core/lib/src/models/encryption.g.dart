// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EncryptedMessageImpl _$$EncryptedMessageImplFromJson(
        Map<String, dynamic> json) =>
    _$EncryptedMessageImpl(
      id: json['id'] as String,
      consultationId: json['consultation_id'] as String,
      ciphertext: json['ciphertext'] as String,
      senderId: json['sender_id'] as String,
      senderRole: json['sender_role'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: json['sender_name'] as String?,
    );

Map<String, dynamic> _$$EncryptedMessageImplToJson(
        _$EncryptedMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'consultation_id': instance.consultationId,
      'ciphertext': instance.ciphertext,
      'sender_id': instance.senderId,
      'sender_role': instance.senderRole,
      'is_read': instance.isRead,
      'created_at': instance.createdAt.toIso8601String(),
      'sender_name': instance.senderName,
    };

_$KeyExchangeRequestImpl _$$KeyExchangeRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$KeyExchangeRequestImpl(
      consultationId: json['consultation_id'] as String,
      publicKey: json['public_key'] as String,
    );

Map<String, dynamic> _$$KeyExchangeRequestImplToJson(
        _$KeyExchangeRequestImpl instance) =>
    <String, dynamic>{
      'consultation_id': instance.consultationId,
      'public_key': instance.publicKey,
    };

_$KeyExchangeResponseImpl _$$KeyExchangeResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$KeyExchangeResponseImpl(
      consultationId: json['consultation_id'] as String,
      salt: json['salt'] as String,
      encryptionEnabled: json['encryption_enabled'] as bool,
    );

Map<String, dynamic> _$$KeyExchangeResponseImplToJson(
        _$KeyExchangeResponseImpl instance) =>
    <String, dynamic>{
      'consultation_id': instance.consultationId,
      'salt': instance.salt,
      'encryption_enabled': instance.encryptionEnabled,
    };

_$EncryptionStatusImpl _$$EncryptionStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$EncryptionStatusImpl(
      consultationId: json['consultation_id'] as String,
      isEnabled: json['is_enabled'] as bool,
      keyExchangeComplete: json['key_exchange_complete'] as bool,
      enabledAt: json['enabled_at'] == null
          ? null
          : DateTime.parse(json['enabled_at'] as String),
    );

Map<String, dynamic> _$$EncryptionStatusImplToJson(
        _$EncryptionStatusImpl instance) =>
    <String, dynamic>{
      'consultation_id': instance.consultationId,
      'is_enabled': instance.isEnabled,
      'key_exchange_complete': instance.keyExchangeComplete,
      'enabled_at': instance.enabledAt?.toIso8601String(),
    };
