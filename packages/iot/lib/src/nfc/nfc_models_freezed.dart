import 'package:freezed_annotation/freezed_annotation.dart';

part 'nfc_models.freezed.dart';
part 'nfc_models.g.dart';

/// NFC check-in request sent to backend.
@freezed
class NFCCheckInRequest with _$NFCCheckInRequest {
  const factory NFCCheckInRequest({
    /// Raw NFC UID from reader (e.g., '04:A3:5B:1A:7C:8D:90')
    @JsonKey(name: 'nfc_uid') required String nfcUid,

    /// ID of the NFC reader device
    @JsonKey(name: 'device_id') required String deviceId,

    /// Device authentication secret
    @JsonKey(name: 'device_secret') required String deviceSecret,
  }) = _NFCCheckInRequest;

  factory NFCCheckInRequest.fromJson(Map<String, dynamic> json) =>
      _$NFCCheckInRequestFromJson(json);
}

/// NFC check-in response from backend.
@freezed
class NFCCheckInResponse with _$NFCCheckInResponse {
  const factory NFCCheckInResponse({
    required bool success,
    required String message,
    @JsonKey(name: 'ticket_number') String? ticketNumber,
    @JsonKey(name: 'queue_name') String? queueName,
    @JsonKey(name: 'estimated_wait_minutes') int? estimatedWaitMinutes,
    @JsonKey(name: 'assigned_room') String? assignedRoom,
    @JsonKey(name: 'wayfinding_route_id') String? wayfindingRouteId,
    @JsonKey(name: 'patient_name') String? patientName,
  }) = _NFCCheckInResponse;

  factory NFCCheckInResponse.fromJson(Map<String, dynamic> json) =>
      _$NFCCheckInResponseFromJson(json);
}

/// Type of NFC card/token.
@JsonEnum(valueField: 'value')
enum NFCCardType {
  /// Elektronische Gesundheitskarte
  @JsonValue('egk')
  egk('egk'),

  /// Praxis-eigene Karte
  @JsonValue('custom')
  custom('custom'),

  /// Temporär-Karte für Neupatienten
  @JsonValue('temporary')
  temporary('temporary'),

  /// Smartphone HCE
  @JsonValue('mobile')
  mobile('mobile');

  const NFCCardType(this.value);
  final String value;
}

/// NFC card registration request.
@freezed
class NFCCardRegisterRequest with _$NFCCardRegisterRequest {
  const factory NFCCardRegisterRequest({
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'nfc_uid') required String nfcUid,
    @JsonKey(name: 'card_type') @Default(NFCCardType.custom) NFCCardType cardType,
    @JsonKey(name: 'card_label') String? cardLabel,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _NFCCardRegisterRequest;

  factory NFCCardRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$NFCCardRegisterRequestFromJson(json);
}

/// NFC card response from backend.
@freezed
class NFCCardResponse with _$NFCCardResponse {
  const factory NFCCardResponse({
    required String id,
    @JsonKey(name: 'patient_id') required String patientId,
    @JsonKey(name: 'card_type') required NFCCardType cardType,
    @JsonKey(name: 'card_label') String? cardLabel,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'issued_at') required DateTime issuedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'last_used_at') DateTime? lastUsedAt,
  }) = _NFCCardResponse;

  factory NFCCardResponse.fromJson(Map<String, dynamic> json) =>
      _$NFCCardResponseFromJson(json);
}

/// NFC card list response.
@freezed
class NFCCardListResponse with _$NFCCardListResponse {
  const factory NFCCardListResponse({
    required List<NFCCardResponse> items,
    required int total,
  }) = _NFCCardListResponse;

  factory NFCCardListResponse.fromJson(Map<String, dynamic> json) =>
      _$NFCCardListResponseFromJson(json);
}
