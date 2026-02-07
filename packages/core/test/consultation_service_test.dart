import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sanad_core/sanad_core.dart';

/// Schritt 18: Unit-Tests für ConsultationService.
void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late ConsultationService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    service = ConsultationService(dio);
  });

  group('ConsultationService - Consultation CRUD', () {
    test('getMyConsultations returns list of consultations', () async {
      // Arrange
      dioAdapter.onGet(
        '/consultations/my-consultations',
        (server) => server.reply(200, {
          'items': [
            {
              'id': 'consult-001',
              'patient_id': 'patient-123',
              'practice_id': 'practice-abc',
              'consultation_type': 'video_call',
              'status': 'scheduled',
              'priority': 'routine',
              'created_at': '2025-01-15T10:00:00.000Z',
            },
            {
              'id': 'consult-002',
              'patient_id': 'patient-123',
              'practice_id': 'practice-abc',
              'consultation_type': 'chat',
              'status': 'in_progress',
              'priority': 'routine',
              'created_at': '2025-01-15T11:00:00.000Z',
            },
          ],
          'total': 2,
          'page': 1,
          'page_size': 50,
        }),
        queryParameters: {'page': 1, 'page_size': 50},
      );

      // Act
      final result = await service.getMyConsultations();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'consult-001');
      expect(result[0].consultationType, ConsultationType.videoCall);
      expect(result[1].status, ConsultationStatus.inProgress);
    });

    test('getMyConsultations with status filter', () async {
      dioAdapter.onGet(
        '/consultations/my-consultations',
        (server) => server.reply(200, {
          'items': [
            {
              'id': 'consult-active',
              'patient_id': 'patient-123',
              'practice_id': 'practice-abc',
              'consultation_type': 'chat',
              'status': 'in_progress',
              'priority': 'routine',
              'created_at': '2025-01-15T10:00:00.000Z',
            },
          ],
          'total': 1,
          'page': 1,
          'page_size': 50,
        }),
        queryParameters: {'page': 1, 'page_size': 50, 'status': 'inProgress'},
      );

      final result = await service.getMyConsultations(
        status: ConsultationStatus.inProgress,
      );

      expect(result.length, 1);
      expect(result[0].status, ConsultationStatus.inProgress);
    });

    test('getConsultation returns single consultation', () async {
      dioAdapter.onGet(
        '/consultations/consult-001',
        (server) => server.reply(200, {
          'id': 'consult-001',
          'patient_id': 'patient-123',
          'practice_id': 'practice-abc',
          'consultation_type': 'video_call',
          'status': 'scheduled',
          'priority': 'routine',
          'reason': 'Kopfschmerzen',
          'doctor_name': 'Dr. Schmidt',
          'created_at': '2025-01-15T10:00:00.000Z',
        }),
      );

      final result = await service.getConsultation('consult-001');

      expect(result.id, 'consult-001');
      expect(result.reason, 'Kopfschmerzen');
      expect(result.doctorName, 'Dr. Schmidt');
    });

    test('requestConsultation creates new consultation', () async {
      dioAdapter.onPost(
        '/consultations/request',
        (server) => server.reply(201, {
          'id': 'consult-new',
          'patient_id': 'patient-123',
          'practice_id': 'practice-abc',
          'consultation_type': 'video_call',
          'status': 'requested',
          'priority': 'same_day',
          'reason': 'Akute Schmerzen',
          'created_at': '2025-01-15T12:00:00.000Z',
        }),
        data: {
          'consultation_type': 'videoCall',
          'priority': 'sameDay',
          'subject': 'Akute Schmerzen',
          'symptoms': 'Starke Bauchschmerzen',
        },
      );

      final request = ConsultationCreate(
        consultationType: ConsultationType.videoCall,
        priority: ConsultationPriority.sameDay,
        reason: 'Akute Schmerzen',
        symptoms: 'Starke Bauchschmerzen',
      );

      final result = await service.requestConsultation(request);

      expect(result.id, 'consult-new');
      expect(result.status, ConsultationStatus.requested);
    });

    test('cancelConsultation returns true on success', () async {
      dioAdapter.onPost(
        '/consultations/my-consultations/consult-001/cancel',
        (server) => server.reply(200, {'success': true}),
        data: {'reason': 'Terminkollision'},
      );

      final result = await service.cancelConsultation(
        'consult-001',
        reason: 'Terminkollision',
      );

      expect(result, true);
    });
  });

  group('ConsultationService - Messages', () {
    test('getMessages returns list of messages', () async {
      dioAdapter.onGet(
        '/consultations/consult-001/messages',
        (server) => server.reply(200, {
          'items': [
            {
              'id': 'msg-001',
              'consultation_id': 'consult-001',
              'sender_id': 'patient-123',
              'sender_role': 'patient',
              'content': 'Guten Tag',
              'is_read': true,
              'created_at': '2025-01-15T10:00:00.000Z',
            },
            {
              'id': 'msg-002',
              'consultation_id': 'consult-001',
              'sender_id': 'doctor-456',
              'sender_role': 'doctor',
              'content': 'Hallo, wie kann ich helfen?',
              'is_read': false,
              'created_at': '2025-01-15T10:05:00.000Z',
            },
          ],
          'total': 2,
        }),
        queryParameters: {'page': 1, 'page_size': 50},
      );

      final result = await service.getMessages('consult-001');

      expect(result.length, 2);
      expect(result[0].content, 'Guten Tag');
      expect(result[1].senderRole, 'doctor');
    });

    test('sendMessage creates new message', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/messages',
        (server) => server.reply(201, {
          'id': 'msg-new',
          'consultation_id': 'consult-001',
          'sender_id': 'patient-123',
          'sender_role': 'patient',
          'content': 'Meine Symptome...',
          'is_read': false,
          'created_at': '2025-01-15T12:00:00.000Z',
        }),
        data: {'content': 'Meine Symptome...'},
      );

      final result = await service.sendMessage(
        'consult-001',
        'Meine Symptome...',
      );

      expect(result.id, 'msg-new');
      expect(result.content, 'Meine Symptome...');
    });

    test('markMessagesRead completes without error', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/messages/read',
        (server) => server.reply(200, {'success': true}),
      );

      await expectLater(
        service.markMessagesRead('consult-001'),
        completes,
      );
    });
  });

  group('ConsultationService - Video/Voice Call', () {
    test('getCallRoom returns WebRTCRoom with ICE servers', () async {
      dioAdapter.onGet(
        '/consultations/consult-001/room',
        (server) => server.reply(200, {
          'room_id': 'room-001',
          'consultation_id': 'consult-001',
          'ice_servers': [
            {'urls': ['stun:stun.l.google.com:19302']},
          ],
          'turn_servers': [
            {
              'urls': ['turn:turn.sanad.de:3478'],
              'username': 'user',
              'credential': 'pass',
            },
          ],
        }),
      );

      final result = await service.getCallRoom('consult-001');

      expect(result.roomId, 'room-001');
      expect(result.iceServers.length, 1);
      expect(result.turnServers!.length, 1);
      expect(result.turnServers!.first.username, 'user');
    });

    test('joinCall updates consultation status', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/join',
        (server) => server.reply(200, {
          'id': 'consult-001',
          'patient_id': 'patient-123',
          'practice_id': 'practice-abc',
          'consultation_type': 'video_call',
          'status': 'in_progress',
          'priority': 'routine',
          'created_at': '2025-01-15T10:00:00.000Z',
        }),
      );

      final result = await service.joinCall('consult-001');

      expect(result.status, ConsultationStatus.inProgress);
    });

    test('endCall completes without error', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/end',
        (server) => server.reply(200, {'success': true}),
        data: {'consultation_id': 'consult-001'},
      );

      await expectLater(
        service.endCall('consult-001'),
        completes,
      );
    });
  });

  group('ConsultationService - WebRTC Signaling', () {
    test('sendOffer sends WebRTC offer', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/signal/offer',
        (server) => server.reply(200, {'success': true}),
        data: {'sdp': 'v=0...', 'type': 'offer'},
      );

      await expectLater(
        service.sendOffer(
          'consult-001',
          const WebRTCOffer(sdp: 'v=0...', type: 'offer'),
        ),
        completes,
      );
    });

    test('sendAnswer sends WebRTC answer', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/signal/answer',
        (server) => server.reply(200, {'success': true}),
        data: {'sdp': 'v=0...answer', 'type': 'answer'},
      );

      await expectLater(
        service.sendAnswer(
          'consult-001',
          const WebRTCAnswer(sdp: 'v=0...answer', type: 'answer'),
        ),
        completes,
      );
    });

    test('sendIceCandidate sends ICE candidate', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/signal/ice',
        (server) => server.reply(200, {'success': true}),
        data: {
          'candidate': 'candidate:0 1 UDP ...',
          'sdp_mid': 'audio',
          'sdp_m_line_index': 0,
        },
      );

      await expectLater(
        service.sendIceCandidate(
          'consult-001',
          const WebRTCIceCandidate(
            candidate: 'candidate:0 1 UDP ...',
            sdpMid: 'audio',
            sdpMLineIndex: 0,
          ),
        ),
        completes,
      );
    });

    test('pollSignals returns list of signals', () async {
      dioAdapter.onGet(
        '/consultations/consult-001/signal/poll',
        (server) => server.reply(200, [
          {
            'signal_type': 'offer',
            'payload': {'sdp': 'test', 'type': 'offer'},
            'sender_id': 'doctor-123',
            'timestamp': '2025-01-15T12:00:00.000Z',
          },
          {
            'signal_type': 'ice-candidate',
            'payload': {'candidate': 'candidate:...'},
            'sender_id': 'doctor-123',
            'timestamp': '2025-01-15T12:00:01.000Z',
          },
        ]),
      );

      final result = await service.pollSignals('consult-001');

      expect(result.length, 2);
      expect(result[0].signalType, 'offer');
      expect(result[1].signalType, 'ice-candidate');
    });

    test('clearSignals deletes all signals', () async {
      dioAdapter.onDelete(
        '/consultations/consult-001/signal',
        (server) => server.reply(200, {'deleted': 5}),
      );

      await expectLater(
        service.clearSignals('consult-001'),
        completes,
      );
    });
  });

  group('ConsultationService - Quick Request Helpers', () {
    test('requestCallback creates callback consultation', () async {
      dioAdapter.onPost(
        '/consultations/request',
        (server) => server.reply(201, {
          'id': 'consult-callback',
          'patient_id': 'patient-123',
          'practice_id': 'practice-abc',
          'consultation_type': 'callback_request',
          'status': 'requested',
          'priority': 'routine',
          'reason': 'Rezeptanfrage',
          'created_at': '2025-01-15T12:00:00.000Z',
        }),
        data: {
          'consultation_type': 'callbackRequest',
          'priority': 'routine',
          'subject': 'Rezeptanfrage',
          'symptoms': null,
        },
      );

      final result = await service.requestCallback(
        reason: 'Rezeptanfrage',
      );

      expect(result.consultationType, ConsultationType.callbackRequest);
    });

    test('requestVideoCall creates video consultation', () async {
      dioAdapter.onPost(
        '/consultations/request',
        (server) => server.reply(201, {
          'id': 'consult-video',
          'patient_id': 'patient-123',
          'practice_id': 'practice-abc',
          'consultation_type': 'video_call',
          'status': 'requested',
          'priority': 'urgent',
          'reason': 'Starke Schmerzen',
          'created_at': '2025-01-15T12:00:00.000Z',
        }),
        data: {
          'consultation_type': 'videoCall',
          'priority': 'urgent',
          'subject': 'Starke Schmerzen',
          'symptoms': 'Kopfschmerzen',
        },
      );

      final result = await service.requestVideoCall(
        reason: 'Starke Schmerzen',
        symptoms: 'Kopfschmerzen',
        priority: ConsultationPriority.urgent,
      );

      expect(result.consultationType, ConsultationType.videoCall);
      expect(result.priority, ConsultationPriority.urgent);
    });
  });

  group('ConsultationService - Error Handling', () {
    test('getConsultation throws on 404', () async {
      dioAdapter.onGet(
        '/consultations/nonexistent',
        (server) => server.reply(404, {'detail': 'Not found'}),
      );

      expect(
        () => service.getConsultation('nonexistent'),
        throwsA(isA<DioException>()),
      );
    });

    test('sendMessage throws on 401 unauthorized', () async {
      dioAdapter.onPost(
        '/consultations/consult-001/messages',
        (server) => server.reply(401, {'detail': 'Unauthorized'}),
        data: {'content': 'Test'},
      );

      expect(
        () => service.sendMessage('consult-001', 'Test'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
