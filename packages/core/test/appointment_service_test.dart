import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:sanad_core/sanad_core.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late AppointmentService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000/api/v1'));
    dioAdapter = DioAdapter(dio: dio);
    service = AppointmentService(dio);
  });

  group('AppointmentService - types and availability', () {
    test('getAppointmentTypes returns type metadata', () async {
      dioAdapter.onGet(
        '/appointments/types',
        (server) => server.reply(200, [
          {
            'type': 'acute',
            'name': 'Akutsprechstunde',
            'description': 'Akute Beschwerden',
            'duration_minutes': 15,
            'requires_referral': false,
            'online_bookable': true,
          },
          {
            'type': 'lab_results',
            'name': 'Befundbesprechung',
            'description': 'Laborwerte',
            'duration_minutes': 10,
            'requires_referral': false,
            'online_bookable': true,
          },
        ]),
      );

      final result = await service.getAppointmentTypes();

      expect(result.length, 2);
      expect(result[0].type, AppointmentType.acute);
      expect(result[1].type, AppointmentType.labResults);
    });

    test('getAvailability returns day availability list', () async {
      dioAdapter.onGet(
        '/appointments/availability',
        (server) => server.reply(200, [
          {
            'date': '2025-01-20',
            'is_holiday': false,
            'is_closed': false,
            'slots': [
              {
                'start_time': '2025-01-20T09:00:00.000Z',
                'end_time': '2025-01-20T09:15:00.000Z',
                'is_available': true,
                'doctor_id': 'dr-1',
                'doctor_name': 'Dr. A',
              },
            ],
          },
        ]),
        queryParameters: {
          'appointment_type': 'acute',
          'from_date': '2025-01-20',
          'to_date': '2025-01-22',
          'doctor_id': 'dr-1',
        },
      );

      final result = await service.getAvailability(
        appointmentType: AppointmentType.acute,
        fromDate: DateTime(2025, 1, 20),
        toDate: DateTime(2025, 1, 22),
        doctorId: 'dr-1',
      );

      expect(result.length, 1);
      expect(result.first.slots.first.isAvailable, true);
    });

    test('getNextAvailableSlot returns a slot', () async {
      dioAdapter.onGet(
        '/appointments/next-available',
        (server) => server.reply(200, {
          'start_time': '2025-01-20T09:00:00.000Z',
          'end_time': '2025-01-20T09:15:00.000Z',
          'is_available': true,
          'doctor_id': 'dr-1',
          'doctor_name': 'Dr. A',
        }),
        queryParameters: {
          'appointment_type': 'acute',
        },
      );

      final result = await service.getNextAvailableSlot(
        appointmentType: AppointmentType.acute,
      );

      expect(result.isAvailable, true);
      expect(result.doctorId, 'dr-1');
    });
  });

  group('AppointmentService - booking and management', () {
    test('bookAppointment creates a new appointment', () async {
      dioAdapter.onPost(
        '/appointments/book',
        (server) => server.reply(201, {
          'id': 'apt-001',
          'patient_id': 'patient-123',
          'patient_name': 'Max Mustermann',
          'appointment_type': 'acute',
          'status': 'confirmed',
          'scheduled_at': '2025-01-20T09:00:00.000Z',
          'duration_minutes': 15,
          'doctor_id': 'dr-1',
          'doctor_name': 'Dr. A',
          'reason': 'Starke Kopfschmerzen',
          'created_at': '2025-01-15T10:00:00.000Z',
          'confirmed_at': '2025-01-15T10:00:00.000Z',
          'reminder_sent': false,
        }),
        data: {
          'appointment_type': 'acute',
          'preferred_date': '2025-01-20',
          'preferred_time': '09:00:00',
          'reason': 'Starke Kopfschmerzen',
          'is_first_visit': false,
        },
      );

      final result = await service.bookAppointment(
        BookingRequest(
          appointmentType: AppointmentType.acute,
          preferredDate: DateTime(2025, 1, 20),
          preferredTime: DateTime(2025, 1, 1, 9, 0),
          reason: 'Starke Kopfschmerzen',
        ),
      );

      expect(result.id, 'apt-001');
      expect(result.status, AppointmentStatus.confirmed);
    });

    test('bookAppointment throws on conflict (abuse case)', () async {
      dioAdapter.onPost(
        '/appointments/book',
        (server) => server.reply(409, {'detail': 'Selected time slot is no longer available'}),
        data: {
          'appointment_type': 'acute',
          'preferred_date': '2025-01-20',
          'preferred_time': '09:00:00',
          'reason': 'Starke Kopfschmerzen',
          'is_first_visit': false,
        },
      );

      await expectLater(
        service.bookAppointment(
          BookingRequest(
            appointmentType: AppointmentType.acute,
            preferredDate: DateTime(2025, 1, 20),
            preferredTime: DateTime(2025, 1, 1, 9, 0),
            reason: 'Starke Kopfschmerzen',
          ),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('getMyAppointments returns list', () async {
      dioAdapter.onGet(
        '/appointments/my',
        (server) => server.reply(200, [
          {
            'id': 'apt-001',
            'patient_id': 'patient-123',
            'patient_name': 'Max Mustermann',
            'appointment_type': 'acute',
            'status': 'confirmed',
            'scheduled_at': '2025-01-20T09:00:00.000Z',
            'duration_minutes': 15,
            'doctor_id': 'dr-1',
            'doctor_name': 'Dr. A',
            'reason': 'Starke Kopfschmerzen',
            'created_at': '2025-01-15T10:00:00.000Z',
            'confirmed_at': '2025-01-15T10:00:00.000Z',
            'reminder_sent': false,
          },
        ]),
        queryParameters: {
          'status_filter': 'confirmed',
          'upcoming_only': true,
        },
      );

      final result = await service.getMyAppointments(
        statusFilter: AppointmentStatus.confirmed,
        upcomingOnly: true,
      );

      expect(result.length, 1);
      expect(result.first.status, AppointmentStatus.confirmed);
    });

    test('getAppointment throws on forbidden (abuse case)', () async {
      dioAdapter.onGet(
        '/appointments/apt-999',
        (server) => server.reply(403, {'detail': 'Access denied'}),
      );

      await expectLater(
        service.getAppointment('apt-999'),
        throwsA(isA<DioException>()),
      );
    });

    test('rescheduleAppointment updates the appointment', () async {
      dioAdapter.onPut(
        '/appointments/apt-001/reschedule',
        (server) => server.reply(200, {
          'id': 'apt-001',
          'patient_id': 'patient-123',
          'patient_name': 'Max Mustermann',
          'appointment_type': 'acute',
          'status': 'confirmed',
          'scheduled_at': '2025-01-22T11:00:00.000Z',
          'duration_minutes': 15,
          'doctor_id': 'dr-1',
          'doctor_name': 'Dr. A',
          'reason': 'Starke Kopfschmerzen',
          'created_at': '2025-01-15T10:00:00.000Z',
          'confirmed_at': '2025-01-15T10:00:00.000Z',
          'reminder_sent': false,
        }),
        data: {
          'new_date': '2025-01-22',
          'new_time': '11:00:00',
        },
      );

      final result = await service.rescheduleAppointment(
        'apt-001',
        RescheduleRequest(
          newDate: DateTime(2025, 1, 22),
          newTime: DateTime(2025, 1, 1, 11, 0),
        ),
      );

      expect(result.scheduledAt, DateTime.parse('2025-01-22T11:00:00.000Z'));
    });

    test('rescheduleAppointment throws on invalid status (abuse case)', () async {
      dioAdapter.onPut(
        '/appointments/apt-001/reschedule',
        (server) => server.reply(400, {'detail': 'Cannot reschedule'}),
        data: {
          'new_date': '2025-01-22',
          'new_time': '11:00:00',
        },
      );

      await expectLater(
        service.rescheduleAppointment(
          'apt-001',
          RescheduleRequest(
            newDate: DateTime(2025, 1, 22),
            newTime: DateTime(2025, 1, 1, 11, 0),
          ),
        ),
        throwsA(isA<DioException>()),
      );
    });

    test('cancelAppointment updates appointment', () async {
      dioAdapter.onDelete(
        '/appointments/apt-001',
        (server) => server.reply(200, {
          'id': 'apt-001',
          'patient_id': 'patient-123',
          'patient_name': 'Max Mustermann',
          'appointment_type': 'acute',
          'status': 'cancelled',
          'scheduled_at': '2025-01-20T09:00:00.000Z',
          'duration_minutes': 15,
          'doctor_id': 'dr-1',
          'doctor_name': 'Dr. A',
          'reason': 'Starke Kopfschmerzen',
          'created_at': '2025-01-15T10:00:00.000Z',
          'confirmed_at': '2025-01-15T10:00:00.000Z',
          'cancelled_at': '2025-01-18T10:00:00.000Z',
          'cancellation_reason': 'Terminkollision',
          'reminder_sent': false,
        }),
        data: {
          'reason': 'Terminkollision',
        },
      );

      final result = await service.cancelAppointment(
        appointmentId: 'apt-001',
        reason: 'Terminkollision',
      );

      expect(result.status, AppointmentStatus.cancelled);
    });

    test('updateReminderSettings saves settings', () async {
      dioAdapter.onPut(
        '/appointments/apt-001/reminder-settings',
        (server) => server.reply(200, {
          'email_24h': true,
          'email_1h': false,
          'push_24h': true,
          'push_1h': false,
          'sms_24h': false,
        }),
        data: {
          'email_24h': true,
          'email_1h': false,
          'push_24h': true,
          'push_1h': false,
          'sms_24h': false,
        },
      );

      final result = await service.updateReminderSettings(
        appointmentId: 'apt-001',
        settings: const ReminderSettings(push1h: false),
      );

      expect(result.push1h, false);
      expect(result.email24h, true);
    });
  });
}
