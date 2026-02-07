import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../models/appointment.dart';

/// Service for appointment booking and management.
///
/// Security:
///   - Requires authenticated requests (JWT).
///   - Patients can only access their own appointments.
class AppointmentService {
  final Dio _dio;

  /// Creates the service with a shared Dio instance.
  AppointmentService(this._dio);

  /// Loads appointment type metadata.
  ///
  /// Returns:
  ///   List of appointment type info entries.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<List<AppointmentTypeInfo>> getAppointmentTypes() async {
    final response = await _dio.get(ApiEndpoints.appointmentTypes);
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(AppointmentTypeInfo.fromJson)
        .toList();
  }

  /// Fetches availability for a date range.
  ///
  /// Args:
  ///   appointmentType: Type of the appointment.
  ///   fromDate: Optional start date (defaults to today on backend).
  ///   toDate: Optional end date (defaults to +14 days on backend).
  ///   doctorId: Optional doctor filter.
  ///
  /// Returns:
  ///   List of day availability entries.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<List<DayAvailability>> getAvailability({
    required AppointmentType appointmentType,
    DateTime? fromDate,
    DateTime? toDate,
    String? doctorId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.appointmentAvailability,
      queryParameters: {
        'appointment_type': appointmentType.jsonValue,
        if (fromDate != null) 'from_date': formatAppointmentDate(fromDate),
        if (toDate != null) 'to_date': formatAppointmentDate(toDate),
        if (doctorId != null) 'doctor_id': doctorId,
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DayAvailability.fromJson)
        .toList();
  }

  /// Finds the next available time slot.
  ///
  /// Args:
  ///   appointmentType: Type of the appointment.
  ///   doctorId: Optional doctor filter.
  ///
  /// Returns:
  ///   Next available time slot.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<TimeSlot> getNextAvailableSlot({
    required AppointmentType appointmentType,
    String? doctorId,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.appointmentNextAvailable,
      queryParameters: {
        'appointment_type': appointmentType.jsonValue,
        if (doctorId != null) 'doctor_id': doctorId,
      },
    );
    return TimeSlot.fromJson(response.data as Map<String, dynamic>);
  }

  /// Books a new appointment.
  ///
  /// Args:
  ///   request: Booking request payload.
  ///
  /// Returns:
  ///   The created appointment.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<Appointment> bookAppointment(BookingRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.appointmentBook,
      data: request.toJson(),
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Loads current user's appointments.
  ///
  /// Args:
  ///   statusFilter: Optional status filter.
  ///   upcomingOnly: Whether to return future appointments only.
  ///
  /// Returns:
  ///   List of appointments.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<List<Appointment>> getMyAppointments({
    AppointmentStatus? statusFilter,
    bool upcomingOnly = true,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.myAppointments,
      queryParameters: {
        if (statusFilter != null) 'status_filter': statusFilter.jsonValue,
        'upcoming_only': upcomingOnly,
      },
    );
    final items = response.data as List<dynamic>? ?? [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(Appointment.fromJson)
        .toList();
  }

  /// Loads a single appointment by ID.
  ///
  /// Args:
  ///   appointmentId: Appointment identifier.
  ///
  /// Returns:
  ///   Appointment details.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<Appointment> getAppointment(String appointmentId) async {
    final response = await _dio.get(ApiEndpoints.appointment(appointmentId));
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Reschedules an appointment.
  ///
  /// Args:
  ///   appointmentId: Appointment identifier.
  ///   request: Reschedule request payload.
  ///
  /// Returns:
  ///   Updated appointment.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<Appointment> rescheduleAppointment(
    String appointmentId,
    RescheduleRequest request,
  ) async {
    final response = await _dio.put(
      ApiEndpoints.appointmentReschedule(appointmentId),
      data: request.toJson(),
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cancels an appointment.
  ///
  /// Args:
  ///   appointmentId: Appointment identifier.
  ///   reason: Cancellation reason.
  ///
  /// Returns:
  ///   Updated appointment.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<Appointment> cancelAppointment({
    required String appointmentId,
    required String reason,
  }) async {
    final response = await _dio.delete(
      ApiEndpoints.appointment(appointmentId),
      data: CancellationRequest(reason: reason).toJson(),
    );
    return Appointment.fromJson(response.data as Map<String, dynamic>);
  }

  /// Updates reminder settings for an appointment.
  ///
  /// Args:
  ///   appointmentId: Appointment identifier.
  ///   settings: Reminder settings payload.
  ///
  /// Returns:
  ///   Updated reminder settings.
  ///
  /// Raises:
  ///   DioException: On network/server failures.
  Future<ReminderSettings> updateReminderSettings({
    required String appointmentId,
    required ReminderSettings settings,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.appointmentReminderSettings(appointmentId),
      data: settings.toJson(),
    );
    return ReminderSettings.fromJson(response.data as Map<String, dynamic>);
  }
}
