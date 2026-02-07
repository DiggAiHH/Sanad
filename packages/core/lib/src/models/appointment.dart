import 'package:intl/intl.dart';

/// Appointment types for booking.
enum AppointmentType {
  acute,
  checkup,
  vaccination,
  followup,
  labResults,
  prescription,
  referral,
  telemedicine,
  emergency,
}

/// Appointment status values.
enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  noShow,
  rescheduled,
}

/// JSON helpers for appointment enums.
extension AppointmentTypeJson on AppointmentType {
  /// Returns the API JSON value for this type.
  String get jsonValue {
    switch (this) {
      case AppointmentType.acute:
        return 'acute';
      case AppointmentType.checkup:
        return 'checkup';
      case AppointmentType.vaccination:
        return 'vaccination';
      case AppointmentType.followup:
        return 'followup';
      case AppointmentType.labResults:
        return 'lab_results';
      case AppointmentType.prescription:
        return 'prescription';
      case AppointmentType.referral:
        return 'referral';
      case AppointmentType.telemedicine:
        return 'telemedicine';
      case AppointmentType.emergency:
        return 'emergency';
    }
  }
}

extension AppointmentStatusJson on AppointmentStatus {
  /// Returns the API JSON value for this status.
  String get jsonValue {
    switch (this) {
      case AppointmentStatus.pending:
        return 'pending';
      case AppointmentStatus.confirmed:
        return 'confirmed';
      case AppointmentStatus.cancelled:
        return 'cancelled';
      case AppointmentStatus.completed:
        return 'completed';
      case AppointmentStatus.noShow:
        return 'no_show';
      case AppointmentStatus.rescheduled:
        return 'rescheduled';
    }
  }
}

AppointmentType appointmentTypeFromJson(String value) {
  switch (value) {
    case 'acute':
      return AppointmentType.acute;
    case 'checkup':
      return AppointmentType.checkup;
    case 'vaccination':
      return AppointmentType.vaccination;
    case 'followup':
      return AppointmentType.followup;
    case 'lab_results':
      return AppointmentType.labResults;
    case 'prescription':
      return AppointmentType.prescription;
    case 'referral':
      return AppointmentType.referral;
    case 'telemedicine':
      return AppointmentType.telemedicine;
    case 'emergency':
      return AppointmentType.emergency;
    default:
      throw ArgumentError('Unknown AppointmentType: $value');
  }
}

AppointmentStatus appointmentStatusFromJson(String value) {
  switch (value) {
    case 'pending':
      return AppointmentStatus.pending;
    case 'confirmed':
      return AppointmentStatus.confirmed;
    case 'cancelled':
      return AppointmentStatus.cancelled;
    case 'completed':
      return AppointmentStatus.completed;
    case 'no_show':
      return AppointmentStatus.noShow;
    case 'rescheduled':
      return AppointmentStatus.rescheduled;
    default:
      throw ArgumentError('Unknown AppointmentStatus: $value');
  }
}

final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');
final DateFormat _timeFormatter = DateFormat('HH:mm:ss');

/// Formats a date for appointment APIs.
String formatAppointmentDate(DateTime date) => _dateFormatter.format(date);

/// Formats a time for appointment APIs.
String formatAppointmentTime(DateTime time) => _timeFormatter.format(time);

/// Available time slot for appointments.
class TimeSlot {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? doctorId;
  final String? doctorName;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.doctorId,
    this.doctorName,
  });

  /// Creates a slot from JSON.
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String?,
    );
  }

  /// Converts the slot to JSON.
  Map<String, dynamic> toJson() => {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'is_available': isAvailable,
        if (doctorId != null) 'doctor_id': doctorId,
        if (doctorName != null) 'doctor_name': doctorName,
      };
}

/// Availability for a day with multiple time slots.
class DayAvailability {
  final DateTime date;
  final List<TimeSlot> slots;
  final bool isHoliday;
  final bool isClosed;

  const DayAvailability({
    required this.date,
    required this.slots,
    required this.isHoliday,
    required this.isClosed,
  });

  /// Creates availability from JSON.
  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    final slotItems = json['slots'] as List<dynamic>? ?? [];
    return DayAvailability(
      date: DateTime.parse(json['date'] as String),
      slots: slotItems
          .whereType<Map<String, dynamic>>()
          .map(TimeSlot.fromJson)
          .toList(),
      isHoliday: json['is_holiday'] as bool? ?? false,
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }
}

/// Metadata about appointment types.
class AppointmentTypeInfo {
  final AppointmentType type;
  final String name;
  final String description;
  final int durationMinutes;
  final bool requiresReferral;
  final bool onlineBookable;
  final String? preparationNotes;

  const AppointmentTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.requiresReferral,
    required this.onlineBookable,
    this.preparationNotes,
  });

  /// Creates type info from JSON.
  factory AppointmentTypeInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentTypeInfo(
      type: appointmentTypeFromJson(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      durationMinutes: json['duration_minutes'] as int,
      requiresReferral: json['requires_referral'] as bool? ?? false,
      onlineBookable: json['online_bookable'] as bool? ?? true,
      preparationNotes: json['preparation_notes'] as String?,
    );
  }
}

/// Request payload for booking an appointment.
class BookingRequest {
  final AppointmentType appointmentType;
  final DateTime preferredDate;
  final DateTime preferredTime;
  final String? doctorId;
  final String reason;
  final String? notes;
  final bool isFirstVisit;

  const BookingRequest({
    required this.appointmentType,
    required this.preferredDate,
    required this.preferredTime,
    required this.reason,
    this.doctorId,
    this.notes,
    this.isFirstVisit = false,
  });

  /// Converts the request to backend JSON.
  Map<String, dynamic> toJson() => {
        'appointment_type': appointmentType.jsonValue,
        'preferred_date': formatAppointmentDate(preferredDate),
        'preferred_time': formatAppointmentTime(preferredTime),
        if (doctorId != null) 'doctor_id': doctorId,
        'reason': reason,
        if (notes != null) 'notes': notes,
        'is_first_visit': isFirstVisit,
      };
}

/// Appointment booking response model.
class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final AppointmentType appointmentType;
  final AppointmentStatus status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? doctorId;
  final String? doctorName;
  final String reason;
  final String? notes;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final bool reminderSent;

  const Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.appointmentType,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.reason,
    required this.createdAt,
    required this.reminderSent,
    this.doctorId,
    this.doctorName,
    this.notes,
    this.confirmedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// Creates an appointment from JSON.
  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      patientName: json['patient_name'] as String,
      appointmentType: appointmentTypeFromJson(json['appointment_type'] as String),
      status: appointmentStatusFromJson(json['status'] as String),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      doctorId: json['doctor_id'] as String?,
      doctorName: json['doctor_name'] as String?,
      reason: json['reason'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] == null
          ? null
          : DateTime.parse(json['confirmed_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
      reminderSent: json['reminder_sent'] as bool? ?? false,
    );
  }
}

/// Request for rescheduling an appointment.
class RescheduleRequest {
  final DateTime newDate;
  final DateTime newTime;
  final String? reason;

  const RescheduleRequest({
    required this.newDate,
    required this.newTime,
    this.reason,
  });

  /// Converts the request to JSON.
  Map<String, dynamic> toJson() => {
        'new_date': formatAppointmentDate(newDate),
        'new_time': formatAppointmentTime(newTime),
        if (reason != null) 'reason': reason,
      };
}

/// Request for cancelling an appointment.
class CancellationRequest {
  final String reason;

  const CancellationRequest({required this.reason});

  /// Converts the request to JSON.
  Map<String, dynamic> toJson() => {'reason': reason};
}

/// Reminder settings for an appointment.
class ReminderSettings {
  final bool email24h;
  final bool email1h;
  final bool push24h;
  final bool push1h;
  final bool sms24h;

  const ReminderSettings({
    this.email24h = true,
    this.email1h = false,
    this.push24h = true,
    this.push1h = true,
    this.sms24h = false,
  });

  /// Creates settings from JSON.
  factory ReminderSettings.fromJson(Map<String, dynamic> json) {
    return ReminderSettings(
      email24h: json['email_24h'] as bool? ?? true,
      email1h: json['email_1h'] as bool? ?? false,
      push24h: json['push_24h'] as bool? ?? true,
      push1h: json['push_1h'] as bool? ?? true,
      sms24h: json['sms_24h'] as bool? ?? false,
    );
  }

  /// Converts settings to JSON.
  Map<String, dynamic> toJson() => {
        'email_24h': email24h,
        'email_1h': email1h,
        'push_24h': push24h,
        'push_1h': push1h,
        'sms_24h': sms24h,
      };
}
