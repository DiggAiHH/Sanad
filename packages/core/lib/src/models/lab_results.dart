/// Models for lab results and findings.

enum ResultStatus {
  pending,
  received,
  reviewed,
  released,
  discussed,
}

ResultStatus resultStatusFromJson(String value) {
  switch (value) {
    case 'pending':
      return ResultStatus.pending;
    case 'received':
      return ResultStatus.received;
    case 'reviewed':
      return ResultStatus.reviewed;
    case 'released':
      return ResultStatus.released;
    case 'discussed':
      return ResultStatus.discussed;
    default:
      throw ArgumentError('Unknown ResultStatus: $value');
  }
}

String resultStatusToJson(ResultStatus status) {
  switch (status) {
    case ResultStatus.pending:
      return 'pending';
    case ResultStatus.received:
      return 'received';
    case ResultStatus.reviewed:
      return 'reviewed';
    case ResultStatus.released:
      return 'released';
    case ResultStatus.discussed:
      return 'discussed';
  }
}

enum ValueStatus {
  normal,
  low,
  high,
  criticalLow,
  criticalHigh,
}

ValueStatus valueStatusFromJson(String value) {
  switch (value) {
    case 'normal':
      return ValueStatus.normal;
    case 'low':
      return ValueStatus.low;
    case 'high':
      return ValueStatus.high;
    case 'critical_low':
      return ValueStatus.criticalLow;
    case 'critical_high':
      return ValueStatus.criticalHigh;
    default:
      throw ArgumentError('Unknown ValueStatus: $value');
  }
}

enum LabCategory {
  bloodCount,
  metabolic,
  liver,
  kidney,
  thyroid,
  lipids,
  inflammation,
  coagulation,
  vitamins,
  hormones,
  other,
}

LabCategory labCategoryFromJson(String value) {
  switch (value) {
    case 'blood_count':
      return LabCategory.bloodCount;
    case 'metabolic':
      return LabCategory.metabolic;
    case 'liver':
      return LabCategory.liver;
    case 'kidney':
      return LabCategory.kidney;
    case 'thyroid':
      return LabCategory.thyroid;
    case 'lipids':
      return LabCategory.lipids;
    case 'inflammation':
      return LabCategory.inflammation;
    case 'coagulation':
      return LabCategory.coagulation;
    case 'vitamins':
      return LabCategory.vitamins;
    case 'hormones':
      return LabCategory.hormones;
    case 'other':
      return LabCategory.other;
    default:
      throw ArgumentError('Unknown LabCategory: $value');
  }
}

class LabValue {
  final String id;
  final String name;
  final String shortName;
  final double value;
  final String unit;
  final double? referenceMin;
  final double? referenceMax;
  final ValueStatus status;
  final LabCategory category;
  final String? note;

  const LabValue({
    required this.id,
    required this.name,
    required this.shortName,
    required this.value,
    required this.unit,
    required this.status,
    required this.category,
    this.referenceMin,
    this.referenceMax,
    this.note,
  });

  factory LabValue.fromJson(Map<String, dynamic> json) {
    return LabValue(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['short_name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      referenceMin: (json['reference_min'] as num?)?.toDouble(),
      referenceMax: (json['reference_max'] as num?)?.toDouble(),
      status: valueStatusFromJson(json['status'] as String),
      category: labCategoryFromJson(json['category'] as String),
      note: json['note'] as String?,
    );
  }
}

class LabResult {
  final String id;
  final String patientId;
  final DateTime orderDate;
  final DateTime? resultDate;
  final ResultStatus status;
  final String labName;
  final String orderingDoctor;
  final List<LabValue> values;
  final String? doctorComment;
  final bool patientVisible;
  final DateTime? releasedAt;
  final String? releasedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LabResult({
    required this.id,
    required this.patientId,
    required this.orderDate,
    required this.status,
    required this.labName,
    required this.orderingDoctor,
    required this.values,
    required this.patientVisible,
    required this.createdAt,
    required this.updatedAt,
    this.resultDate,
    this.doctorComment,
    this.releasedAt,
    this.releasedBy,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    final values = (json['values'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(LabValue.fromJson)
        .toList();

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return LabResult(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      resultDate: parseDate(json['result_date']),
      status: resultStatusFromJson(json['status'] as String),
      labName: json['lab_name'] as String,
      orderingDoctor: json['ordering_doctor'] as String,
      values: values,
      doctorComment: json['doctor_comment'] as String?,
      patientVisible: json['patient_visible'] as bool? ?? false,
      releasedAt: parseDate(json['released_at']),
      releasedBy: json['released_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class LabResultSummary {
  final String id;
  final DateTime orderDate;
  final DateTime? resultDate;
  final ResultStatus status;
  final String labName;
  final bool hasAbnormal;
  final int abnormalCount;
  final int totalValues;
  final bool patientVisible;

  const LabResultSummary({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.labName,
    required this.hasAbnormal,
    required this.abnormalCount,
    required this.totalValues,
    required this.patientVisible,
    this.resultDate,
  });

  factory LabResultSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return LabResultSummary(
      id: json['id'] as String,
      orderDate: DateTime.parse(json['order_date'] as String),
      resultDate: parseDate(json['result_date']),
      status: resultStatusFromJson(json['status'] as String),
      labName: json['lab_name'] as String,
      hasAbnormal: json['has_abnormal'] as bool? ?? false,
      abnormalCount: json['abnormal_count'] as int? ?? 0,
      totalValues: json['total_values'] as int? ?? 0,
      patientVisible: json['patient_visible'] as bool? ?? false,
    );
  }
}

class ReleaseResultRequest {
  final String resultId;
  final String? doctorComment;
  final bool notifyPatient;

  const ReleaseResultRequest({
    required this.resultId,
    this.doctorComment,
    this.notifyPatient = true,
  });

  Map<String, dynamic> toJson() => {
        'result_id': resultId,
        if (doctorComment != null) 'doctor_comment': doctorComment,
        'notify_patient': notifyPatient,
      };
}

class PendingCount {
  final int count;

  const PendingCount({required this.count});

  factory PendingCount.fromJson(Map<String, dynamic> json) {
    return PendingCount(count: json['pending_count'] as int? ?? 0);
  }
}

class ReferenceValue {
  final String name;
  final String unit;
  final String? range;
  final String? male;
  final String? female;

  const ReferenceValue({
    required this.name,
    required this.unit,
    this.range,
    this.male,
    this.female,
  });

  factory ReferenceValue.fromJson(Map<String, dynamic> json) {
    return ReferenceValue(
      name: json['name'] as String,
      unit: json['unit'] as String,
      range: json['range'] as String?,
      male: json['male'] as String?,
      female: json['female'] as String?,
    );
  }
}

class ReferenceValues {
  final Map<String, List<ReferenceValue>> categories;

  const ReferenceValues({required this.categories});

  factory ReferenceValues.fromJson(Map<String, dynamic> json) {
    final mapped = <String, List<ReferenceValue>>{};
    json.forEach((key, value) {
      final items = (value as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ReferenceValue.fromJson)
          .toList();
      mapped[key] = items;
    });
    return ReferenceValues(categories: mapped);
  }
}
