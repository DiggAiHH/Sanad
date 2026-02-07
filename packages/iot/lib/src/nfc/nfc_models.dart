// ============================================================================
// NFC MODELS – Sanad IoT Package
// ============================================================================
// Plain Dart models for NFC flows. No code generation required.
// Security: deviceSecret is write-only (toJson) and never exposed in logs.
// ============================================================================

/// NFC check-in request sent to backend.
class NFCCheckInRequest {
  const NFCCheckInRequest({
    required this.nfcUid,
    required this.deviceId,
    required this.deviceSecret,
  });

  /// Raw NFC UID from reader (e.g., '04:A3:5B:1A:7C:8D:90')
  final String nfcUid;

  /// ID of the NFC reader device
  final String deviceId;

  /// Device authentication secret (NEVER logged)
  final String deviceSecret;

  Map<String, dynamic> toJson() => {
        'nfc_uid': nfcUid,
        'device_id': deviceId,
        'device_secret': deviceSecret,
      };

  @override
  String toString() =>
      'NFCCheckInRequest(nfcUid: ${nfcUid.substring(0, 5)}..., deviceId: $deviceId)';
}

/// NFC check-in response from backend.
class NFCCheckInResponse {
  const NFCCheckInResponse({
    required this.success,
    required this.message,
    this.ticketNumber,
    this.queueName,
    this.estimatedWaitMinutes,
    this.assignedRoom,
    this.wayfindingRouteId,
    this.patientName,
  });

  final bool success;
  final String message;
  final String? ticketNumber;
  final String? queueName;
  final int? estimatedWaitMinutes;
  final String? assignedRoom;
  final String? wayfindingRouteId;
  final String? patientName;

  factory NFCCheckInResponse.fromJson(Map<String, dynamic> json) {
    return NFCCheckInResponse(
      success: (json['success'] as bool?) ?? false,
      ticketNumber: json['ticket_number'] as String?,
      queueName: json['queue_name'] as String?,
      estimatedWaitMinutes: (json['estimated_wait_minutes'] as num?)?.toInt(),
      assignedRoom: json['assigned_room'] as String?,
      wayfindingRouteId: json['wayfinding_route_id']?.toString(),
      patientName: json['patient_name'] as String?,
      message: (json['message'] as String?) ?? 'Unbekannte Antwort',
    );
  }

  /// Whether patient should be shown wayfinding instructions.
  bool get hasWayfinding => wayfindingRouteId != null;

  /// Whether wait time is available.
  bool get hasWaitTime => estimatedWaitMinutes != null;

  @override
  String toString() => 'NFCCheckInResponse(success: $success, ticket: $ticketNumber)';
}

/// NFC card registration request.
class NFCCardRegisterRequest {
  const NFCCardRegisterRequest({
    required this.patientId,
    required this.nfcUid,
    this.cardType = NFCCardType.custom,
    this.cardLabel,
    this.expiresAt,
  });

  final String patientId;
  final String nfcUid;
  final NFCCardType cardType;
  final String? cardLabel;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'nfc_uid': nfcUid,
        'card_type': cardType.wireValue,
        if (cardLabel != null) 'card_label': cardLabel,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      };
}

/// Type of NFC card/token.
enum NFCCardType {
  /// Elektronische Gesundheitskarte
  egk('egk'),

  /// Praxis-eigene Karte
  custom('custom'),

  /// Temporär-Karte für Neupatienten
  temporary('temporary'),

  /// Smartphone HCE
  mobile('mobile');

  const NFCCardType(this.wireValue);
  final String wireValue;

  static NFCCardType fromWire(String? value) {
    return NFCCardType.values
        .firstWhere((e) => e.wireValue == value, orElse: () => NFCCardType.custom);
  }
}

/// NFC card information.
class NFCCard {
  const NFCCard({
    required this.id,
    required this.patientId,
    required this.cardType,
    required this.isActive,
    required this.createdAt,
    this.cardLabel,
    this.expiresAt,
    this.lastUsedAt,
  });

  final String id;
  final String patientId;
  final NFCCardType cardType;
  final String? cardLabel;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? lastUsedAt;

  factory NFCCard.fromJson(Map<String, dynamic> json) {
    return NFCCard(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      cardType: NFCCardType.fromWire(json['card_type'] as String?),
      cardLabel: json['card_label'] as String?,
      isActive: (json['is_active'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at'] as String) : null,
      lastUsedAt: json['last_used_at'] != null ? DateTime.parse(json['last_used_at'] as String) : null,
    );
  }

  /// Whether the card has expired.
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Whether the card is valid (active and not expired).
  bool get isValid => isActive && !isExpired;

  /// Display name for the card.
  String get displayName => cardLabel ?? cardType.wireValue.toUpperCase();

  @override
  String toString() =>
      'NFCCard(id: $id, type: ${cardType.wireValue}, active: $isActive)';
}

/// NFC scan result from device.
class NFCScanResult {
  const NFCScanResult({
    required this.uid,
    required this.tagType,
    required this.scannedAt,
    this.technicalData,
  });

  /// Raw UID bytes as hex string
  final String uid;

  /// Tag type (e.g., 'nfca', 'isodep')
  final String tagType;

  /// Timestamp of scan
  final DateTime scannedAt;

  /// Optional ATR/ATS data
  final String? technicalData;
}

/// NFC service state.
sealed class NFCState {
  const NFCState();

  const factory NFCState.idle() = NFCStateIdle;
  const factory NFCState.scanning() = NFCStateScanning;
  const factory NFCState.processing({required String uid}) = NFCStateProcessing;
  const factory NFCState.success({required NFCCheckInResponse response}) = NFCStateSuccess;
  const factory NFCState.error({required String message}) = NFCStateError;
  const factory NFCState.unavailable({required String reason}) = NFCStateUnavailable;

  T when<T>({
    required T Function() idle,
    required T Function() scanning,
    required T Function(String uid) processing,
    required T Function(NFCCheckInResponse response) success,
    required T Function(String message) error,
    required T Function(String reason) unavailable,
  }) {
    final self = this;
    if (self is NFCStateIdle) return idle();
    if (self is NFCStateScanning) return scanning();
    if (self is NFCStateProcessing) return processing(self.uid);
    if (self is NFCStateSuccess) return success(self.response);
    if (self is NFCStateError) return error(self.message);
    if (self is NFCStateUnavailable) return unavailable(self.reason);
    throw StateError('Unreachable NFCState: $self');
  }

  T maybeWhen<T>({
    T Function()? idle,
    T Function()? scanning,
    T Function(String uid)? processing,
    T Function(NFCCheckInResponse response)? success,
    T Function(String message)? error,
    T Function(String reason)? unavailable,
    required T Function() orElse,
  }) {
    final self = this;
    if (self is NFCStateIdle && idle != null) return idle();
    if (self is NFCStateScanning && scanning != null) return scanning();
    if (self is NFCStateProcessing && processing != null) return processing(self.uid);
    if (self is NFCStateSuccess && success != null) return success(self.response);
    if (self is NFCStateError && error != null) return error(self.message);
    if (self is NFCStateUnavailable && unavailable != null) return unavailable(self.reason);
    return orElse();
  }
}

final class NFCStateIdle extends NFCState {
  const NFCStateIdle();
}

final class NFCStateScanning extends NFCState {
  const NFCStateScanning();
}

final class NFCStateProcessing extends NFCState {
  const NFCStateProcessing({required this.uid});
  final String uid;
}

final class NFCStateSuccess extends NFCState {
  const NFCStateSuccess({required this.response});
  final NFCCheckInResponse response;
}

final class NFCStateError extends NFCState {
  const NFCStateError({required this.message});
  final String message;
}

final class NFCStateUnavailable extends NFCState {
  const NFCStateUnavailable({required this.reason});
  final String reason;
}
