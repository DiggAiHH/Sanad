/// Models for vaccinations and recall notifications.

enum VaccineType {
  covid19,
  influenza,
  tetanus,
  diphtheria,
  pertussis,
  polio,
  hepatitisA,
  hepatitisB,
  measles,
  mumps,
  rubella,
  varicella,
  pneumococcal,
  meningococcal,
  hpv,
  rotavirus,
  tickBorne,
  rabies,
  typhoid,
  yellowFever,
  other,
}

VaccineType vaccineTypeFromJson(String value) {
  switch (value) {
    case 'covid19':
      return VaccineType.covid19;
    case 'influenza':
      return VaccineType.influenza;
    case 'tetanus':
      return VaccineType.tetanus;
    case 'diphtheria':
      return VaccineType.diphtheria;
    case 'pertussis':
      return VaccineType.pertussis;
    case 'polio':
      return VaccineType.polio;
    case 'hepatitis_a':
      return VaccineType.hepatitisA;
    case 'hepatitis_b':
      return VaccineType.hepatitisB;
    case 'measles':
      return VaccineType.measles;
    case 'mumps':
      return VaccineType.mumps;
    case 'rubella':
      return VaccineType.rubella;
    case 'varicella':
      return VaccineType.varicella;
    case 'pneumococcal':
      return VaccineType.pneumococcal;
    case 'meningococcal':
      return VaccineType.meningococcal;
    case 'hpv':
      return VaccineType.hpv;
    case 'rotavirus':
      return VaccineType.rotavirus;
    case 'tick_borne':
      return VaccineType.tickBorne;
    case 'rabies':
      return VaccineType.rabies;
    case 'typhoid':
      return VaccineType.typhoid;
    case 'yellow_fever':
      return VaccineType.yellowFever;
    case 'other':
      return VaccineType.other;
    default:
      throw ArgumentError('Unknown VaccineType: $value');
  }
}

String vaccineTypeToJson(VaccineType type) {
  switch (type) {
    case VaccineType.covid19:
      return 'covid19';
    case VaccineType.influenza:
      return 'influenza';
    case VaccineType.tetanus:
      return 'tetanus';
    case VaccineType.diphtheria:
      return 'diphtheria';
    case VaccineType.pertussis:
      return 'pertussis';
    case VaccineType.polio:
      return 'polio';
    case VaccineType.hepatitisA:
      return 'hepatitis_a';
    case VaccineType.hepatitisB:
      return 'hepatitis_b';
    case VaccineType.measles:
      return 'measles';
    case VaccineType.mumps:
      return 'mumps';
    case VaccineType.rubella:
      return 'rubella';
    case VaccineType.varicella:
      return 'varicella';
    case VaccineType.pneumococcal:
      return 'pneumococcal';
    case VaccineType.meningococcal:
      return 'meningococcal';
    case VaccineType.hpv:
      return 'hpv';
    case VaccineType.rotavirus:
      return 'rotavirus';
    case VaccineType.tickBorne:
      return 'tick_borne';
    case VaccineType.rabies:
      return 'rabies';
    case VaccineType.typhoid:
      return 'typhoid';
    case VaccineType.yellowFever:
      return 'yellow_fever';
    case VaccineType.other:
      return 'other';
  }
}

class VaccinationRecord {
  final String id;
  final String patientId;
  final VaccineType vaccineType;
  final String vaccineName;
  final String manufacturer;
  final String batchNumber;
  final int doseNumber;
  final DateTime date;
  final String administeringDoctor;
  final String location;
  final DateTime? nextDoseDue;
  final String? notes;
  final DateTime documentedAt;
  final String documentedBy;

  const VaccinationRecord({
    required this.id,
    required this.patientId,
    required this.vaccineType,
    required this.vaccineName,
    required this.manufacturer,
    required this.batchNumber,
    required this.doseNumber,
    required this.date,
    required this.administeringDoctor,
    required this.location,
    required this.documentedAt,
    required this.documentedBy,
    this.nextDoseDue,
    this.notes,
  });

  factory VaccinationRecord.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return VaccinationRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      vaccineType: vaccineTypeFromJson(json['vaccine_type'] as String),
      vaccineName: json['vaccine_name'] as String,
      manufacturer: json['manufacturer'] as String,
      batchNumber: json['batch_number'] as String,
      doseNumber: json['dose_number'] as int,
      date: DateTime.parse(json['date'] as String),
      administeringDoctor: json['administering_doctor'] as String,
      location: json['location'] as String,
      nextDoseDue: parseDate(json['next_dose_due']),
      notes: json['notes'] as String?,
      documentedAt: DateTime.parse(json['documented_at'] as String),
      documentedBy: json['documented_by'] as String,
    );
  }
}

class VaccinationRecommendation {
  final VaccineType vaccineType;
  final String vaccineName;
  final String reason;
  final String priority;
  final DateTime? dueDate;
  final String? notes;

  const VaccinationRecommendation({
    required this.vaccineType,
    required this.vaccineName,
    required this.reason,
    required this.priority,
    this.dueDate,
    this.notes,
  });

  factory VaccinationRecommendation.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return VaccinationRecommendation(
      vaccineType: vaccineTypeFromJson(json['vaccine_type'] as String),
      vaccineName: json['vaccine_name'] as String,
      reason: json['reason'] as String,
      priority: json['priority'] as String,
      dueDate: parseDate(json['due_date']),
      notes: json['notes'] as String?,
    );
  }
}

class VaccinationStatus {
  final VaccineType vaccineType;
  final String name;
  final String status;
  final DateTime? lastDose;
  final DateTime? nextDoseDue;
  final int dosesReceived;
  final int? dosesRequired;

  const VaccinationStatus({
    required this.vaccineType,
    required this.name,
    required this.status,
    required this.dosesReceived,
    this.lastDose,
    this.nextDoseDue,
    this.dosesRequired,
  });

  factory VaccinationStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return VaccinationStatus(
      vaccineType: vaccineTypeFromJson(json['vaccine_type'] as String),
      name: json['name'] as String,
      status: json['status'] as String,
      lastDose: parseDate(json['last_dose']),
      nextDoseDue: parseDate(json['next_dose_due']),
      dosesReceived: json['doses_received'] as int? ?? 0,
      dosesRequired: json['doses_required'] as int?,
    );
  }
}

class VaccinationPass {
  final String patientId;
  final List<VaccinationRecord> vaccinations;
  final List<VaccinationStatus> statusSummary;
  final List<VaccinationRecommendation> recommendations;
  final DateTime lastUpdated;

  const VaccinationPass({
    required this.patientId,
    required this.vaccinations,
    required this.statusSummary,
    required this.recommendations,
    required this.lastUpdated,
  });

  factory VaccinationPass.fromJson(Map<String, dynamic> json) {
    final vaccinations = (json['vaccinations'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VaccinationRecord.fromJson)
        .toList();
    final statusSummary = (json['status_summary'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VaccinationStatus.fromJson)
        .toList();
    final recommendations = (json['recommendations'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(VaccinationRecommendation.fromJson)
        .toList();

    return VaccinationPass(
      patientId: json['patient_id'] as String,
      vaccinations: vaccinations,
      statusSummary: statusSummary,
      recommendations: recommendations,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }
}

class RecallNotification {
  final String id;
  final String patientId;
  final String type;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority;
  final DateTime? sentAt;
  final DateTime? acknowledgedAt;
  final String? scheduledAppointmentId;

  const RecallNotification({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.sentAt,
    this.acknowledgedAt,
    this.scheduledAppointmentId,
  });

  factory RecallNotification.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return RecallNotification(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      priority: json['priority'] as String,
      sentAt: parseDate(json['sent_at']),
      acknowledgedAt: parseDate(json['acknowledged_at']),
      scheduledAppointmentId: json['scheduled_appointment_id'] as String?,
    );
  }
}

class UpcomingVaccination {
  final VaccineType vaccineType;
  final String vaccineName;
  final DateTime dueDate;
  final int daysUntil;
  final bool overdue;

  const UpcomingVaccination({
    required this.vaccineType,
    required this.vaccineName,
    required this.dueDate,
    required this.daysUntil,
    required this.overdue,
  });

  factory UpcomingVaccination.fromJson(Map<String, dynamic> json) {
    return UpcomingVaccination(
      vaccineType: vaccineTypeFromJson(json['vaccine_type'] as String),
      vaccineName: json['vaccine_name'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      daysUntil: json['days_until'] as int,
      overdue: json['overdue'] as bool? ?? false,
    );
  }
}

class VaccinationExportStatus {
  final String status;
  final String format;
  final String? downloadUrl;

  const VaccinationExportStatus({
    required this.status,
    required this.format,
    this.downloadUrl,
  });

  factory VaccinationExportStatus.fromJson(Map<String, dynamic> json) {
    return VaccinationExportStatus(
      status: json['status'] as String,
      format: json['format'] as String,
      downloadUrl: json['download_url'] as String?,
    );
  }
}
