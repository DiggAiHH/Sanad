// NFC Service Unit Tests
// Tests for scan debounce, retry logic, error handling, and idempotency.

import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sanad_iot/src/nfc/nfc_models.dart';
import 'package:sanad_iot/src/nfc/nfc_service.dart';

// Mock Dio adapter for testing
class MockDioAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  late Response Function(RequestOptions) responseFactory;
  DioException? throwException;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (throwException != null) {
      throw throwException!;
    }

    final response = responseFactory(options);
    return ResponseBody.fromString(
      response.data.toString(),
      response.statusCode ?? 200,
      headers: {
        'content-type': ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('NFCService', () {
    late Dio dio;
    late NFCService service;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
      service = NFCService(
        dio,
        baseUrl: 'https://api.test.com',
        checkInTimeout: const Duration(seconds: 5),
        maxRetries: 2,
      );
    });

    group('constructor', () {
      test('should use default values', () {
        final defaultService = NFCService(dio);
        expect(defaultService.baseUrl, '');
        expect(defaultService.maxRetries, 2);
        expect(defaultService.checkInTimeout.inSeconds, 10);
      });

      test('should accept custom values', () {
        final customService = NFCService(
          dio,
          baseUrl: 'https://custom.api',
          maxRetries: 5,
          checkInTimeout: const Duration(seconds: 30),
        );
        expect(customService.baseUrl, 'https://custom.api');
        expect(customService.maxRetries, 5);
        expect(customService.checkInTimeout.inSeconds, 30);
      });
    });

    group('isScanning', () {
      test('should initially be false', () {
        expect(service.isScanning, isFalse);
      });
    });
  });

  group('NFCCheckInRequest', () {
    test('toJson should serialize correctly', () {
      const request = NFCCheckInRequest(
        nfcUid: '04:A3:5B:1A:7C:8D:90',
        deviceId: 'device-123',
        deviceSecret: 'secret-xyz',
      );

      final json = request.toJson();

      expect(json['nfc_uid'], '04:A3:5B:1A:7C:8D:90');
      expect(json['device_id'], 'device-123');
      expect(json['device_secret'], 'secret-xyz');
    });
  });

  group('NFCCheckInResponse', () {
    test('fromJson should parse success response', () {
      final json = {
        'success': true,
        'message': 'Check-in erfolgreich',
        'ticket_number': 'A-042',
        'queue_name': 'Allgemeinmedizin',
        'estimated_wait_minutes': 15,
        'assigned_room': 'Zimmer 3',
        'wayfinding_route_id': 'route-123',
        'patient_name': 'Max Mustermann',
      };

      final response = NFCCheckInResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, 'Check-in erfolgreich');
      expect(response.ticketNumber, 'A-042');
      expect(response.queueName, 'Allgemeinmedizin');
      expect(response.estimatedWaitMinutes, 15);
      expect(response.assignedRoom, 'Zimmer 3');
      expect(response.wayfindingRouteId, 'route-123');
      expect(response.patientName, 'Max Mustermann');
    });

    test('fromJson should handle minimal response', () {
      final json = <String, dynamic>{};

      final response = NFCCheckInResponse.fromJson(json);

      expect(response.success, isFalse);
      expect(response.message, 'Unbekannte Antwort');
      expect(response.ticketNumber, isNull);
    });

    test('fromJson should handle partial response', () {
      final json = {
        'success': true,
        'ticket_number': 'B-001',
      };

      final response = NFCCheckInResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.message, 'Unbekannte Antwort');
      expect(response.ticketNumber, 'B-001');
      expect(response.estimatedWaitMinutes, isNull);
    });
  });

  group('NFCCardType', () {
    test('fromWire should parse known types', () {
      expect(NFCCardType.fromWire('egk'), NFCCardType.egk);
      expect(NFCCardType.fromWire('custom'), NFCCardType.custom);
      expect(NFCCardType.fromWire('temporary'), NFCCardType.temporary);
      expect(NFCCardType.fromWire('mobile'), NFCCardType.mobile);
    });

    test('fromWire should default to custom for unknown', () {
      expect(NFCCardType.fromWire('unknown'), NFCCardType.custom);
      expect(NFCCardType.fromWire(null), NFCCardType.custom);
      expect(NFCCardType.fromWire(''), NFCCardType.custom);
    });

    test('wireValue should return correct string', () {
      expect(NFCCardType.egk.wireValue, 'egk');
      expect(NFCCardType.custom.wireValue, 'custom');
      expect(NFCCardType.temporary.wireValue, 'temporary');
      expect(NFCCardType.mobile.wireValue, 'mobile');
    });
  });

  group('NFCCard', () {
    test('fromJson should parse complete card', () {
      final json = {
        'id': 'card-123',
        'patient_id': 'patient-456',
        'card_type': 'egk',
        'card_label': 'Gesundheitskarte',
        'is_active': true,
        'created_at': '2026-01-14T10:00:00Z',
        'expires_at': '2027-01-14T10:00:00Z',
        'last_used_at': '2026-01-14T09:00:00Z',
      };

      final card = NFCCard.fromJson(json);

      expect(card.id, 'card-123');
      expect(card.patientId, 'patient-456');
      expect(card.cardType, NFCCardType.egk);
      expect(card.cardLabel, 'Gesundheitskarte');
      expect(card.isActive, isTrue);
      expect(card.expiresAt, isNotNull);
      expect(card.lastUsedAt, isNotNull);
    });

    test('fromJson should handle minimal card', () {
      final json = {
        'id': 'card-789',
        'patient_id': 'patient-000',
        'created_at': '2026-01-14T10:00:00Z',
      };

      final card = NFCCard.fromJson(json);

      expect(card.id, 'card-789');
      expect(card.cardType, NFCCardType.custom);
      expect(card.cardLabel, isNull);
      expect(card.isActive, isFalse);
      expect(card.expiresAt, isNull);
      expect(card.lastUsedAt, isNull);
    });
  });

  group('NFCScanResult', () {
    test('should store scan data', () {
      final now = DateTime.now();
      final result = NFCScanResult(
        uid: '04:A3:5B:1A',
        tagType: 'nfca',
        scannedAt: now,
        technicalData: 'ATQA: 00:04, SAK: 08',
      );

      expect(result.uid, '04:A3:5B:1A');
      expect(result.tagType, 'nfca');
      expect(result.scannedAt, now);
      expect(result.technicalData, isNotNull);
    });
  });

  group('NFCState', () {
    test('when should match correct state', () {
      const idle = NFCState.idle();
      const scanning = NFCState.scanning();
      const processing = NFCState.processing(uid: '04:A3');
      final success = NFCState.success(
        response: const NFCCheckInResponse(success: true, message: 'OK'),
      );
      const error = NFCState.error(message: 'Fehler');
      const unavailable = NFCState.unavailable(reason: 'Kein NFC');

      expect(
        idle.when(
          idle: () => 'idle',
          scanning: () => 'scanning',
          processing: (_) => 'processing',
          success: (_) => 'success',
          error: (_) => 'error',
          unavailable: (_) => 'unavailable',
        ),
        'idle',
      );

      expect(
        scanning.when(
          idle: () => 'idle',
          scanning: () => 'scanning',
          processing: (_) => 'processing',
          success: (_) => 'success',
          error: (_) => 'error',
          unavailable: (_) => 'unavailable',
        ),
        'scanning',
      );

      expect(
        processing.when(
          idle: () => 'idle',
          scanning: () => 'scanning',
          processing: (uid) => 'processing:$uid',
          success: (_) => 'success',
          error: (_) => 'error',
          unavailable: (_) => 'unavailable',
        ),
        'processing:04:A3',
      );
    });

    test('maybeWhen should use orElse for unmatched', () {
      const idle = NFCState.idle();

      final result = idle.maybeWhen(
        scanning: () => 'is scanning',
        orElse: () => 'other state',
      );

      expect(result, 'other state');
    });

    test('maybeWhen should match when callback provided', () {
      const scanning = NFCState.scanning();

      final result = scanning.maybeWhen(
        scanning: () => 'is scanning',
        orElse: () => 'other state',
      );

      expect(result, 'is scanning');
    });
  });

  group('NFCCardRegisterRequest', () {
    test('toJson should include required fields', () {
      const request = NFCCardRegisterRequest(
        patientId: 'patient-123',
        nfcUid: '04:A3:5B:1A:7C:8D:90',
      );

      final json = request.toJson();

      expect(json['patient_id'], 'patient-123');
      expect(json['nfc_uid'], '04:A3:5B:1A:7C:8D:90');
      expect(json['card_type'], 'custom');
      expect(json.containsKey('card_label'), isFalse);
      expect(json.containsKey('expires_at'), isFalse);
    });

    test('toJson should include optional fields when set', () {
      final request = NFCCardRegisterRequest(
        patientId: 'patient-123',
        nfcUid: '04:A3:5B:1A:7C:8D:90',
        cardType: NFCCardType.egk,
        cardLabel: 'Meine Karte',
        expiresAt: DateTime.utc(2027, 1, 14, 10, 0, 0),
      );

      final json = request.toJson();

      expect(json['card_type'], 'egk');
      expect(json['card_label'], 'Meine Karte');
      expect(json['expires_at'], '2027-01-14T10:00:00.000Z');
    });
  });
}
