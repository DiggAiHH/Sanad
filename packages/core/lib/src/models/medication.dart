/// Medication models for patient medication plans.
class MedicationDosage {
  final String time;
  final double amount;
  final String unit;
  final String? specificTime;
  final bool? withFood;
  final String? note;

  const MedicationDosage({
    required this.time,
    required this.amount,
    required this.unit,
    this.specificTime,
    this.withFood,
    this.note,
  });

  factory MedicationDosage.fromJson(Map<String, dynamic> json) {
    return MedicationDosage(
      time: json['time']?.toString() ?? 'unknown',
      amount: (json['amount'] is num)
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      unit: json['unit']?.toString() ?? '',
      specificTime: json['specific_time']?.toString(),
      withFood: json['with_food'] as bool?,
      note: json['note']?.toString(),
    );
  }
}

enum MedicationStatus {
  active,
  paused,
  discontinued,
  completed,
}

MedicationStatus _statusFromJson(String? value) {
  switch (value) {
    case 'paused':
      return MedicationStatus.paused;
    case 'discontinued':
      return MedicationStatus.discontinued;
    case 'completed':
      return MedicationStatus.completed;
    case 'active':
    default:
      return MedicationStatus.active;
  }
}

class Medication {
  final String id;
  final String name;
  final String activeIngredient;
  final String strength;
  final String form;
  final List<MedicationDosage> dosages;
  final String indication;
  final String prescriber;
  final MedicationStatus status;
  final String? instructions;
  final DateTime? startDate;
  final DateTime? endDate;

  const Medication({
    required this.id,
    required this.name,
    required this.activeIngredient,
    required this.strength,
    required this.form,
    required this.dosages,
    required this.indication,
    required this.prescriber,
    required this.status,
    this.instructions,
    this.startDate,
    this.endDate,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    final dosageItems = (json['dosages'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MedicationDosage.fromJson)
        .toList();

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return Medication(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      activeIngredient: json['active_ingredient']?.toString() ?? '',
      strength: json['strength']?.toString() ?? '',
      form: json['form']?.toString() ?? '',
      dosages: dosageItems,
      indication: json['indication']?.toString() ?? '',
      prescriber: json['prescriber']?.toString() ?? '',
      status: _statusFromJson(json['status']?.toString()),
      instructions: json['instructions']?.toString(),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
    );
  }
}

class MedicationPlan {
  final String id;
  final String patientId;
  final List<Medication> medications;
  final DateTime? lastUpdated;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? notes;

  const MedicationPlan({
    required this.id,
    required this.patientId,
    required this.medications,
    this.lastUpdated,
    this.reviewedBy,
    this.reviewedAt,
    this.notes,
  });

  factory MedicationPlan.fromJson(Map<String, dynamic> json) {
    final meds = (json['medications'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Medication.fromJson)
        .toList();

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return MedicationPlan(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      medications: meds,
      lastUpdated: parseDate(json['last_updated']),
      reviewedBy: json['reviewed_by']?.toString(),
      reviewedAt: parseDate(json['reviewed_at']),
      notes: json['notes']?.toString(),
    );
  }
}
