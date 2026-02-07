import 'package:freezed_annotation/freezed_annotation.dart';

part 'encryption.freezed.dart';
part 'encryption.g.dart';

/// Verschlüsselte Nachricht mit Metadaten.
@freezed
class EncryptedMessage with _$EncryptedMessage {
  const factory EncryptedMessage({
    required String id,
    required String consultationId,
    required String ciphertext,
    required String senderId,
    required String senderRole,
    @Default(false) bool isRead,
    required DateTime createdAt,
    String? senderName,
  }) = _EncryptedMessage;

  factory EncryptedMessage.fromJson(Map<String, dynamic> json) =>
      _$EncryptedMessageFromJson(json);
}

/// Key Exchange Request für E2E-Encryption Setup.
@freezed
class KeyExchangeRequest with _$KeyExchangeRequest {
  const factory KeyExchangeRequest({
    required String consultationId,
    required String publicKey,
  }) = _KeyExchangeRequest;

  factory KeyExchangeRequest.fromJson(Map<String, dynamic> json) =>
      _$KeyExchangeRequestFromJson(json);
}

/// Key Exchange Response mit Server-generiertem Salt.
@freezed
class KeyExchangeResponse with _$KeyExchangeResponse {
  const factory KeyExchangeResponse({
    required String consultationId,
    required String salt,
    required bool encryptionEnabled,
  }) = _KeyExchangeResponse;

  factory KeyExchangeResponse.fromJson(Map<String, dynamic> json) =>
      _$KeyExchangeResponseFromJson(json);
}

/// Encryption Status für eine Konsultation.
@freezed
class EncryptionStatus with _$EncryptionStatus {
  const factory EncryptionStatus({
    required String consultationId,
    required bool isEnabled,
    required bool keyExchangeComplete,
    DateTime? enabledAt,
  }) = _EncryptionStatus;

  factory EncryptionStatus.fromJson(Map<String, dynamic> json) =>
      _$EncryptionStatusFromJson(json);
}
