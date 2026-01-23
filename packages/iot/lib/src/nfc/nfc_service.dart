import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:dio/dio.dart';

import 'nfc_models.dart';

// ============================================================================
// NFC SERVICE – Sanad IoT Package
// ============================================================================
// Handles NFC tag reading, device check-in, and card management.
// Security: Device credentials (deviceId, deviceSecret) are NEVER logged.
// ============================================================================

/// Callback for NFC availability status changes.
typedef NFCAvailabilityCallback = void Function(bool isAvailable);

/// Callback for NFC state changes.
typedef NFCStateCallback = void Function(NFCState state);

/// Service for NFC operations.
///
/// Handles:
/// - NFC availability checking
/// - Tag reading with error recovery
/// - Auto check-in via backend API with retry/timeout
/// - Idempotency key support to prevent duplicate check-ins
///
/// Usage:
/// ```dart
/// final nfcService = NFCService(dio, baseUrl: 'https://api.example.com');
///
/// // Check availability
/// if (await nfcService.isAvailable()) {
///   // Start scanning
///   await nfcService.startScanning(
///     onTagDiscovered: (result) async {
///       // Perform check-in with device credentials
///       final response = await nfcService.performCheckIn(
///         result,
///         deviceId: 'device-123',
///         deviceSecret: 'secret-from-secure-storage',
///       );
///       if (response.success) {
///         print('Ticket: ${response.ticketNumber}');
///       }
///     },
///     onError: (error) => print('Scan error: $error'),
///   );
/// }
/// ```
class NFCService {
  /// Creates NFC service with Dio client.
  ///
  /// [dio] - HTTP client for API calls.
  /// [baseUrl] - Backend API base URL.
  /// [checkInTimeout] - Timeout for check-in requests (default: 10s).
  /// [maxRetries] - Max retry attempts for transient failures (default: 2).
  NFCService(
    this._dio, {
    this.baseUrl = '',
    this.checkInTimeout = const Duration(seconds: 10),
    this.maxRetries = 2,
  });

  final Dio _dio;
  final String baseUrl;
  final Duration checkInTimeout;
  final int maxRetries;

  bool _isScanning = false;
  final _random = Random();

  /// Last generated idempotency key for debugging.
  String? _lastIdempotencyKey;

  /// Recent UIDs to prevent rapid duplicate scans (debounce).
  final Map<String, DateTime> _recentScans = {};
  static const _scanDebounceWindow = Duration(seconds: 3);
  
  /// Check if NFC is available on this device.
  ///
  /// Returns `false` on web platforms or if NFC hardware is absent/disabled.
  Future<bool> isAvailable() async {
    // NFC not available on web
    if (kIsWeb) return false;

    try {
      return await NfcManager.instance.isAvailable();
    } catch (e) {
      _log('NFC availability check failed', error: e);
      return false;
    }
  }

  /// Get current scanning state.
  bool get isScanning => _isScanning;

  /// Start scanning for NFC tags.
  ///
  /// [onTagDiscovered] is called when a tag is detected.
  /// [onError] is called on scan errors.
  /// [debounce] if true, ignores rapid re-scans of same UID (default: true).
  ///
  /// Throws [StateError] if already scanning.
  Future<void> startScanning({
    required Future<void> Function(NFCScanResult) onTagDiscovered,
    void Function(String error)? onError,
    bool debounce = true,
  }) async {
    if (_isScanning) {
      _log('NFC scanning already in progress');
      throw StateError('NFC scanning already in progress');
    }

    final available = await isAvailable();
    if (!available) {
      const msg = 'NFC ist auf diesem Gerät nicht verfügbar';
      onError?.call(msg);
      return;
    }

    _isScanning = true;
    _cleanupRecentScans();

    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final uid = _extractUid(tag);
          if (uid == null) {
            onError?.call('Konnte Tag-ID nicht lesen');
            return;
          }

          // Debounce rapid scans of same UID
          if (debounce && _isRecentlyScanned(uid)) {
            _log('Debounced duplicate scan', context: {'uid_prefix': uid.substring(0, 5)});
            return;
          }
          _recordScan(uid);

          final result = NFCScanResult(
            uid: uid,
            tagType: _detectTagType(tag),
            scannedAt: DateTime.now(),
            technicalData: _extractTechnicalData(tag),
          );

          await onTagDiscovered(result);
        },
        onError: (error) async {
          _log('NFC session error', error: error);
          onError?.call(error.message);
        },
      );
    } catch (e) {
      _isScanning = false;
      _log('Failed to start NFC session', error: e);
      onError?.call('NFC-Session konnte nicht gestartet werden');
      rethrow;
    }
  }

  /// Stop scanning for NFC tags.
  ///
  /// Safe to call even if not scanning.
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await NfcManager.instance.stopSession();
      _log('NFC session stopped');
    } catch (e) {
      _log('Error stopping NFC session', error: e);
    } finally {
      _isScanning = false;
    }
  }
  
  /// Perform check-in with scanned NFC tag.
  ///
  /// Sends the tag UID to the backend for validation and ticket creation.
  /// Includes retry logic for transient failures and idempotency key.
  ///
  /// [scanResult] - The NFC scan result containing UID.
  /// [deviceId] - Unique device identifier (from secure storage).
  /// [deviceSecret] - Device authentication secret (from secure storage).
  /// [idempotencyKey] - Optional key to prevent duplicate check-ins.
  ///   If not provided, a random key is generated.
  ///
  /// Returns [NFCCheckInResponse] with success/failure and ticket info.
  Future<NFCCheckInResponse> performCheckIn(
    NFCScanResult scanResult, {
    required String deviceId,
    required String deviceSecret,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _generateIdempotencyKey(scanResult.uid);
    _lastIdempotencyKey = key;

    _log('Check-in started', context: {
      'uid_prefix': scanResult.uid.substring(0, 5),
      'device_id': deviceId,
      // SECURITY: deviceSecret is NEVER logged
    });

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final request = NFCCheckInRequest(
          nfcUid: scanResult.uid,
          deviceId: deviceId,
          deviceSecret: deviceSecret,
        );

        final response = await _dio
            .post(
              '$baseUrl/api/v1/nfc/check-in',
              data: request.toJson(),
              options: Options(
                headers: {'X-Idempotency-Key': key},
                sendTimeout: checkInTimeout,
                receiveTimeout: checkInTimeout,
              ),
            )
            .timeout(checkInTimeout);

        _log('Check-in succeeded', context: {
          'ticket': response.data['ticket_number'],
        });

        return NFCCheckInResponse.fromJson(response.data);
      } on DioException catch (e) {
        // Don't retry client errors (4xx)
        if (e.response?.statusCode != null &&
            e.response!.statusCode! >= 400 &&
            e.response!.statusCode! < 500) {
          return _handleCheckInError(e);
        }

        // Retry on network/server errors
        if (attempt < maxRetries) {
          final delay = Duration(milliseconds: 200 * (attempt + 1));
          _log('Retrying check-in', context: {
            'attempt': attempt + 1,
            'delay_ms': delay.inMilliseconds,
          });
          await Future<void>.delayed(delay);
          continue;
        }

        return _handleCheckInError(e);
      } on TimeoutException {
        if (attempt < maxRetries) {
          continue;
        }
        return const NFCCheckInResponse(
          success: false,
          message: 'Zeitüberschreitung bei der Verbindung',
        );
      }
    }

    return const NFCCheckInResponse(
      success: false,
      message: 'Check-in fehlgeschlagen nach mehreren Versuchen',
    );
  }

  NFCCheckInResponse _handleCheckInError(DioException e) {
    _log('Check-in failed', error: e, context: {
      'status': e.response?.statusCode,
    });

    final message = switch (e.response?.statusCode) {
      401 => 'Gerät nicht autorisiert',
      403 => 'Zugriff verweigert',
      404 => 'Karte nicht registriert',
      409 => 'Check-in bereits durchgeführt',
      429 => 'Zu viele Anfragen – bitte warten',
      _ => e.response?.data?['detail'] as String? ??
          e.message ??
          'Verbindungsfehler',
    };

    return NFCCheckInResponse(
      success: false,
      message: message,
    );
  }
  
  /// Register a new NFC card for a patient.
  ///
  /// [request] - Card registration details.
  /// Throws [DioException] on network/server errors.
  Future<NFCCard> registerCard(NFCCardRegisterRequest request) async {
    _log('Registering NFC card', context: {
      'patient_id': request.patientId,
      'card_type': request.cardType.wireValue,
    });

    final response = await _dio.post(
      '$baseUrl/api/v1/nfc/cards/register',
      data: request.toJson(),
    );

    return NFCCard.fromJson(response.data);
  }

  /// Get all NFC cards for a patient.
  ///
  /// [patientId] - Patient UUID.
  /// Returns list of active and inactive cards.
  Future<List<NFCCard>> getPatientCards(String patientId) async {
    final response = await _dio.get(
      '$baseUrl/api/v1/nfc/cards/patient/$patientId',
    );

    final items = response.data['items'] as List;
    return items.map((e) => NFCCard.fromJson(e)).toList();
  }

  /// Deactivate an NFC card.
  ///
  /// [cardId] - Card UUID to deactivate.
  Future<void> deactivateCard(String cardId) async {
    _log('Deactivating NFC card', context: {'card_id': cardId});
    await _dio.delete('$baseUrl/api/v1/nfc/cards/$cardId');
  }

  // ========================================================================
  // Private Methods
  // ========================================================================

  /// Generate idempotency key for check-in request.
  String _generateIdempotencyKey(String uid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = _random.nextInt(999999).toString().padLeft(6, '0');
    return 'nfc-$timestamp-$random';
  }

  /// Check if UID was recently scanned (debounce).
  bool _isRecentlyScanned(String uid) {
    final lastScan = _recentScans[uid];
    if (lastScan == null) return false;
    return DateTime.now().difference(lastScan) < _scanDebounceWindow;
  }

  /// Record scan timestamp for debounce.
  void _recordScan(String uid) {
    _recentScans[uid] = DateTime.now();
  }

  /// Cleanup old entries from recent scans map.
  void _cleanupRecentScans() {
    final now = DateTime.now();
    _recentScans.removeWhere(
      (_, time) => now.difference(time) > _scanDebounceWindow * 2,
    );
  }

  /// Structured logging (no secrets).
  void _log(
    String message, {
    Object? error,
    Map<String, dynamic>? context,
  }) {
    final buffer = StringBuffer('[NFCService] $message');
    if (context != null && context.isNotEmpty) {
      buffer.write(' | ');
      buffer.write(context.entries.map((e) => '${e.key}=${e.value}').join(', '));
    }
    if (error != null) {
      buffer.write(' | error=$error');
    }
    debugPrint(buffer.toString());
  }

  String? _extractUid(NfcTag tag) {
    // Try different tag types
    final nfca = NfcA.from(tag);
    if (nfca != null) {
      return _bytesToHex(nfca.identifier);
    }

    final nfcb = NfcB.from(tag);
    if (nfcb != null) {
      return _bytesToHex(nfcb.identifier);
    }

    final nfcf = NfcF.from(tag);
    if (nfcf != null) {
      return _bytesToHex(nfcf.identifier);
    }

    final nfcv = NfcV.from(tag);
    if (nfcv != null) {
      return _bytesToHex(nfcv.identifier);
    }

    final isoDep = IsoDep.from(tag);
    if (isoDep != null) {
      return _bytesToHex(isoDep.identifier);
    }

    return null;
  }

  String _detectTagType(NfcTag tag) {
    if (NfcA.from(tag) != null) return 'nfca';
    if (NfcB.from(tag) != null) return 'nfcb';
    if (NfcF.from(tag) != null) return 'nfcf';
    if (NfcV.from(tag) != null) return 'nfcv';
    if (IsoDep.from(tag) != null) return 'isodep';
    if (MifareClassic.from(tag) != null) return 'mifare_classic';
    if (MifareUltralight.from(tag) != null) return 'mifare_ultralight';
    return 'unknown';
  }

  String? _extractTechnicalData(NfcTag tag) {
    final nfca = NfcA.from(tag);
    if (nfca != null) {
      return 'ATQA: ${_bytesToHex(nfca.atqa)}, SAK: ${nfca.sak}';
    }

    final isoDep = IsoDep.from(tag);
    if (isoDep != null && isoDep.historicalBytes != null) {
      return 'Historical: ${_bytesToHex(isoDep.historicalBytes!)}';
    }

    return null;
  }

  String _bytesToHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(':');
  }
}
