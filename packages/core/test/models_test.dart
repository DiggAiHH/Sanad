import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_core/sanad_core.dart';

void main() {
  group('User Model', () {
    test('fromJson creates User correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'test@example.de',
        'firstName': 'Max',
        'lastName': 'Mustermann',
        'role': 'patient',
        'isActive': true,
        'isVerified': false,
        'createdAt': '2025-01-01T10:00:00.000Z',
      };

      final user = User.fromJson(json);

      expect(user.id, 'user-123');
      expect(user.email, 'test@example.de');
      expect(user.firstName, 'Max');
      expect(user.lastName, 'Mustermann');
      expect(user.role, UserRole.patient);
      expect(user.isActive, true);
      expect(user.isVerified, false);
    });

    test('toJson serializes User correctly', () {
      final user = User(
        id: 'user-456',
        email: 'arzt@praxis.de',
        firstName: 'Dr. Hans',
        lastName: 'Müller',
        role: UserRole.doctor,
        createdAt: DateTime.utc(2025, 1, 15, 8, 0),
      );

      final json = user.toJson();

      expect(json['id'], 'user-456');
      expect(json['email'], 'arzt@praxis.de');
      expect(json['firstName'], 'Dr. Hans');
      expect(json['lastName'], 'Müller');
      expect(json['role'], 'doctor');
    });

    test('copyWith creates modified copy', () {
      final user = User(
        id: 'user-789',
        email: 'old@email.de',
        firstName: 'Old',
        lastName: 'Name',
        role: UserRole.staff,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(
        email: 'new@email.de',
        firstName: 'New',
      );

      expect(updated.email, 'new@email.de');
      expect(updated.firstName, 'New');
      expect(updated.lastName, 'Name'); // Unchanged
      expect(updated.id, 'user-789'); // Unchanged
    });

    test('fullName getter returns formatted name', () {
      final user = User(
        id: 'user-test',
        email: 'test@test.de',
        firstName: 'Max',
        lastName: 'Mustermann',
        role: UserRole.patient,
        createdAt: DateTime.now(),
      );

      expect(user.fullName, 'Max Mustermann');
    });
  });

  group('Ticket Model', () {
    test('fromJson creates Ticket correctly', () {
      final json = {
        'id': 'ticket-001',
        'queueId': 'queue-A',
        'ticketNumber': 'A-042',
        'status': 'waiting',
        'priority': 'normal',
        'patientName': 'Erika Muster',
        'createdAt': '2025-01-15T09:30:00.000Z',
      };

      final ticket = Ticket.fromJson(json);

      expect(ticket.id, 'ticket-001');
      expect(ticket.ticketNumber, 'A-042');
      expect(ticket.status, TicketStatus.waiting);
      expect(ticket.priority, TicketPriority.normal);
      expect(ticket.patientName, 'Erika Muster');
    });

    test('toJson serializes Ticket correctly', () {
      final ticket = Ticket(
        id: 'ticket-002',
        queueId: 'queue-B',
        ticketNumber: 'B-007',
        status: TicketStatus.called,
        priority: TicketPriority.high,
        createdAt: DateTime.utc(2025, 1, 15, 10, 0),
      );

      final json = ticket.toJson();

      expect(json['id'], 'ticket-002');
      expect(json['ticketNumber'], 'B-007');
      expect(json['status'], 'called');
      expect(json['priority'], 'high');
    });

    test('isWaiting getter returns correct value', () {
      final waitingTicket = Ticket(
        id: 't1',
        queueId: 'q1',
        ticketNumber: 'A-001',
        status: TicketStatus.waiting,
        priority: TicketPriority.normal,
        createdAt: DateTime.now(),
      );

      final calledTicket = waitingTicket.copyWith(status: TicketStatus.called);

      expect(waitingTicket.isWaiting, true);
      expect(calledTicket.isWaiting, false);
    });
  });

  group('Task Model', () {
    test('fromJson creates Task correctly', () {
      final json = {
        'id': 'task-001',
        'title': 'Patientenakte prüfen',
        'description': 'Akte für Herrn Müller aktualisieren',
        'status': 'todo',
        'priority': 'high',
        'createdAt': '2025-01-15T08:00:00.000Z',
        'updatedAt': '2025-01-15T08:00:00.000Z',
      };

      final task = Task.fromJson(json);

      expect(task.id, 'task-001');
      expect(task.title, 'Patientenakte prüfen');
      expect(task.status, TaskStatus.todo);
      expect(task.priority, TaskPriority.high);
    });

    test('isCompleted getter returns correct value', () {
      final todoTask = Task(
        id: 'task-test',
        title: 'Test Task',
        status: TaskStatus.todo,
        priority: TaskPriority.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final completedTask = todoTask.copyWith(status: TaskStatus.completed);

      expect(todoTask.isCompleted, false);
      expect(completedTask.isCompleted, true);
    });
  });

  group('ChatMessage Model', () {
    test('fromJson creates ChatMessage correctly', () {
      final json = {
        'id': 'msg-001',
        'roomId': 'room-team',
        'senderId': 'user-123',
        'content': 'Guten Morgen!',
        'messageType': 'text',
        'isRead': false,
        'createdAt': '2025-01-15T08:30:00.000Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.id, 'msg-001');
      expect(message.content, 'Guten Morgen!');
      expect(message.messageType, MessageType.text);
      expect(message.isRead, false);
    });
  });

  group('AuthState Model', () {
    test('initial state is unauthenticated', () {
      const state = AuthState.unauthenticated();
      
      state.when(
        initial: () => fail('Should not be initial'),
        loading: () => fail('Should not be loading'),
        authenticated: (_) => fail('Should not be authenticated'),
        unauthenticated: () => expect(true, true),
        error: (_) => fail('Should not be error'),
      );
    });

    test('authenticated state contains user', () {
      final user = User(
        id: 'auth-user',
        email: 'auth@test.de',
        firstName: 'Auth',
        lastName: 'User',
        role: UserRole.admin,
        createdAt: DateTime.now(),
      );

      final state = AuthState.authenticated(user);

      state.when(
        initial: () => fail('Should not be initial'),
        loading: () => fail('Should not be loading'),
        authenticated: (u) => expect(u.email, 'auth@test.de'),
        unauthenticated: () => fail('Should not be unauthenticated'),
        error: (_) => fail('Should not be error'),
      );
    });
  });

  // ==========================================================================
  // Schritt 17: Consultation Model Tests
  // ==========================================================================

  group('Consultation Model', () {
    test('fromJson creates Consultation correctly', () {
      final json = {
        'id': 'consult-001',
        'patient_id': 'patient-123',
        'practice_id': 'practice-abc',
        'doctor_id': 'doctor-456',
        'consultation_type': 'video_call',
        'status': 'scheduled',
        'priority': 'routine',
        'reason': 'Kopfschmerzen',
        'symptoms': 'Migräne seit 3 Tagen',
        'created_at': '2025-01-15T10:00:00.000Z',
        'doctor_name': 'Dr. med. Schmidt',
      };

      final consultation = Consultation.fromJson(json);

      expect(consultation.id, 'consult-001');
      expect(consultation.patientId, 'patient-123');
      expect(consultation.consultationType, ConsultationType.videoCall);
      expect(consultation.status, ConsultationStatus.scheduled);
      expect(consultation.priority, ConsultationPriority.routine);
      expect(consultation.reason, 'Kopfschmerzen');
      expect(consultation.doctorName, 'Dr. med. Schmidt');
    });

    test('toJson serializes Consultation correctly', () {
      final consultation = Consultation(
        id: 'consult-002',
        patientId: 'patient-789',
        practiceId: 'practice-xyz',
        consultationType: ConsultationType.chat,
        status: ConsultationStatus.inProgress,
        reason: 'Rezeptanfrage',
        createdAt: DateTime.utc(2025, 1, 15, 11, 0),
      );

      final json = consultation.toJson();

      expect(json['id'], 'consult-002');
      expect(json['consultationType'], 'chat');
      expect(json['status'], 'in_progress');
    });

    test('copyWith creates modified consultation', () {
      final consultation = Consultation(
        id: 'consult-003',
        patientId: 'patient-001',
        practiceId: 'practice-001',
        consultationType: ConsultationType.voiceCall,
        status: ConsultationStatus.requested,
        createdAt: DateTime.now(),
      );

      final updated = consultation.copyWith(
        status: ConsultationStatus.scheduled,
        doctorId: 'doctor-assigned',
      );

      expect(updated.status, ConsultationStatus.scheduled);
      expect(updated.doctorId, 'doctor-assigned');
      expect(updated.id, 'consult-003'); // Unchanged
    });

    test('ConsultationType enum maps correctly', () {
      expect(ConsultationType.videoCall.name, 'videoCall');
      expect(ConsultationType.voiceCall.name, 'voiceCall');
      expect(ConsultationType.chat.name, 'chat');
      expect(ConsultationType.callbackRequest.name, 'callbackRequest');
    });

    test('ConsultationStatus enum maps correctly', () {
      expect(ConsultationStatus.requested.name, 'requested');
      expect(ConsultationStatus.inProgress.name, 'inProgress');
      expect(ConsultationStatus.completed.name, 'completed');
      expect(ConsultationStatus.cancelled.name, 'cancelled');
    });
  });

  group('ConsultationCreate Model', () {
    test('toBackendJson maps reason to subject', () {
      final create = ConsultationCreate(
        consultationType: ConsultationType.videoCall,
        priority: ConsultationPriority.sameDay,
        reason: 'Akute Rückenschmerzen',
        symptoms: 'Schmerzen beim Bücken',
      );

      final json = create.toBackendJson();

      expect(json['consultation_type'], 'videoCall');
      expect(json['priority'], 'sameDay');
      expect(json['subject'], 'Akute Rückenschmerzen'); // Mapped from reason
      expect(json['symptoms'], 'Schmerzen beim Bücken');
    });
  });

  group('ConsultationMessage Model', () {
    test('fromJson creates ConsultationMessage correctly', () {
      final json = {
        'id': 'msg-consult-001',
        'consultation_id': 'consult-001',
        'sender_id': 'user-patient',
        'sender_role': 'patient',
        'content': 'Hallo Herr Doktor',
        'is_read': true,
        'created_at': '2025-01-15T12:00:00.000Z',
        'sender_name': 'Max Mustermann',
      };

      final message = ConsultationMessage.fromJson(json);

      expect(message.id, 'msg-consult-001');
      expect(message.content, 'Hallo Herr Doktor');
      expect(message.senderRole, 'patient');
      expect(message.isRead, true);
    });
  });

  group('WebRTCRoom Model', () {
    test('fromJson creates WebRTCRoom with ICE/TURN servers', () {
      final json = {
        'room_id': 'room-webrtc-001',
        'consultation_id': 'consult-001',
        'ice_servers': [
          {'urls': ['stun:stun.l.google.com:19302']},
        ],
        'turn_servers': [
          {
            'urls': ['turn:turn.sanad.de:3478'],
            'username': 'user123',
            'credential': 'secret456',
          },
        ],
      };

      final room = WebRTCRoom.fromJson(json);

      expect(room.roomId, 'room-webrtc-001');
      expect(room.consultationId, 'consult-001');
      expect(room.iceServers.length, 1);
      expect(room.iceServers.first.urls, ['stun:stun.l.google.com:19302']);
      expect(room.turnServers, isNotNull);
      expect(room.turnServers!.first.username, 'user123');
    });

    test('WebRTCRoom handles missing TURN servers', () {
      final json = {
        'room_id': 'room-no-turn',
        'consultation_id': 'consult-002',
        'ice_servers': [
          {'urls': ['stun:stun1.l.google.com:19302']},
        ],
      };

      final room = WebRTCRoom.fromJson(json);

      expect(room.turnServers, isNull);
      expect(room.iceServers.isNotEmpty, true);
    });
  });

  group('WebRTC Signaling Models', () {
    test('WebRTCOffer fromJson works', () {
      final json = {'sdp': 'v=0...', 'type': 'offer'};
      final offer = WebRTCOffer.fromJson(json);

      expect(offer.sdp, 'v=0...');
      expect(offer.type, 'offer');
    });

    test('WebRTCAnswer fromJson works', () {
      final json = {'sdp': 'v=0...answer', 'type': 'answer'};
      final answer = WebRTCAnswer.fromJson(json);

      expect(answer.sdp, 'v=0...answer');
      expect(answer.type, 'answer');
    });

    test('WebRTCIceCandidate fromJson works', () {
      final json = {
        'candidate': 'candidate:0 1 UDP ...',
        'sdp_mid': 'audio',
        'sdp_m_line_index': 0,
      };
      final candidate = WebRTCIceCandidate.fromJson(json);

      expect(candidate.candidate, contains('candidate:'));
      expect(candidate.sdpMid, 'audio');
      expect(candidate.sdpMLineIndex, 0);
    });

    test('WebRTCSignal fromJson works', () {
      final json = {
        'signal_type': 'offer',
        'payload': {'sdp': 'test', 'type': 'offer'},
        'sender_id': 'user-123',
        'timestamp': '2025-01-15T12:00:00.000Z',
      };
      final signal = WebRTCSignal.fromJson(json);

      expect(signal.signalType, 'offer');
      expect(signal.senderId, 'user-123');
      expect(signal.payload['sdp'], 'test');
    });
  });
}
