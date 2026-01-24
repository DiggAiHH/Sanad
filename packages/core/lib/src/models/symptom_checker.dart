/// Models for symptom checker and triage.

enum TriageLevel {
  emergency,
  urgent,
  soon,
  routine,
  selfCare,
}

TriageLevel triageLevelFromJson(String value) {
  switch (value) {
    case 'emergency':
      return TriageLevel.emergency;
    case 'urgent':
      return TriageLevel.urgent;
    case 'soon':
      return TriageLevel.soon;
    case 'routine':
      return TriageLevel.routine;
    case 'self_care':
      return TriageLevel.selfCare;
    default:
      throw ArgumentError('Unknown TriageLevel: $value');
  }
}

String triageLevelToJson(TriageLevel level) {
  switch (level) {
    case TriageLevel.emergency:
      return 'emergency';
    case TriageLevel.urgent:
      return 'urgent';
    case TriageLevel.soon:
      return 'soon';
    case TriageLevel.routine:
      return 'routine';
    case TriageLevel.selfCare:
      return 'self_care';
  }
}

enum SymptomCategory {
  pain,
  respiratory,
  digestive,
  skin,
  neurological,
  cardiovascular,
  musculoskeletal,
  psychological,
  general,
  urogenital,
}

SymptomCategory symptomCategoryFromJson(String value) {
  switch (value) {
    case 'pain':
      return SymptomCategory.pain;
    case 'respiratory':
      return SymptomCategory.respiratory;
    case 'digestive':
      return SymptomCategory.digestive;
    case 'skin':
      return SymptomCategory.skin;
    case 'neurological':
      return SymptomCategory.neurological;
    case 'cardiovascular':
      return SymptomCategory.cardiovascular;
    case 'musculoskeletal':
      return SymptomCategory.musculoskeletal;
    case 'psychological':
      return SymptomCategory.psychological;
    case 'general':
      return SymptomCategory.general;
    case 'urogenital':
      return SymptomCategory.urogenital;
    default:
      throw ArgumentError('Unknown SymptomCategory: $value');
  }
}

class Symptom {
  final String id;
  final String name;
  final SymptomCategory category;
  final int severity;
  final int? durationHours;
  final String? location;
  final String? description;

  const Symptom({
    required this.id,
    required this.name,
    required this.category,
    required this.severity,
    this.durationHours,
    this.location,
    this.description,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] as String,
      name: json['name'] as String,
      category: symptomCategoryFromJson(json['category'] as String),
      severity: json['severity'] as int? ?? 0,
      durationHours: json['duration_hours'] as int?,
      location: json['location'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'severity': severity,
        if (durationHours != null) 'duration_hours': durationHours,
        if (location != null) 'location': location,
        if (description != null) 'description': description,
      };
}

class RedFlag {
  final String id;
  final String text;
  final TriageLevel urgency;

  const RedFlag({
    required this.id,
    required this.text,
    required this.urgency,
  });

  factory RedFlag.fromJson(Map<String, dynamic> json) {
    return RedFlag(
      id: json['id'] as String,
      text: json['text'] as String,
      urgency: triageLevelFromJson(json['urgency'] as String),
    );
  }
}

class FollowUpQuestion {
  final String id;
  final String text;
  final String type;
  final List<String>? options;

  const FollowUpQuestion({
    required this.id,
    required this.text,
    required this.type,
    this.options,
  });

  factory FollowUpQuestion.fromJson(Map<String, dynamic> json) {
    return FollowUpQuestion(
      id: json['id'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class TriageResult {
  final TriageLevel level;
  final String recommendation;
  final String reason;
  final String? suggestedAppointmentType;
  final List<String> redFlagsDetected;
  final List<String> selfCareTips;
  final List<String> whenToSeekHelp;

  const TriageResult({
    required this.level,
    required this.recommendation,
    required this.reason,
    required this.redFlagsDetected,
    required this.selfCareTips,
    required this.whenToSeekHelp,
    this.suggestedAppointmentType,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      level: triageLevelFromJson(json['level'] as String),
      recommendation: json['recommendation'] as String,
      reason: json['reason'] as String,
      suggestedAppointmentType: json['suggested_appointment_type'] as String?,
      redFlagsDetected: (json['red_flags_detected'] as List<dynamic>? ?? [])
          .cast<String>(),
      selfCareTips: (json['self_care_tips'] as List<dynamic>? ?? [])
          .cast<String>(),
      whenToSeekHelp: (json['when_to_seek_help'] as List<dynamic>? ?? [])
          .cast<String>(),
    );
  }
}

class SymptomCheckRequest {
  final List<Symptom> symptoms;
  final Map<String, bool> redFlagAnswers;
  final Map<String, String> followUpAnswers;
  final int? patientAge;
  final String? patientGender;
  final bool? isPregnant;
  final List<String> chronicConditions;

  const SymptomCheckRequest({
    required this.symptoms,
    this.redFlagAnswers = const {},
    this.followUpAnswers = const {},
    this.patientAge,
    this.patientGender,
    this.isPregnant,
    this.chronicConditions = const [],
  });

  Map<String, dynamic> toJson() => {
        'symptoms': symptoms.map((symptom) => symptom.toJson()).toList(),
        'red_flag_answers': redFlagAnswers,
        'follow_up_answers': followUpAnswers,
        if (patientAge != null) 'patient_age': patientAge,
        if (patientGender != null) 'patient_gender': patientGender,
        if (isPregnant != null) 'is_pregnant': isPregnant,
        'chronic_conditions': chronicConditions,
      };
}

class SymptomCheckResponse {
  final String sessionId;
  final TriageResult triage;
  final List<FollowUpQuestion> followUpQuestions;
  final String disclaimer;
  final DateTime createdAt;

  const SymptomCheckResponse({
    required this.sessionId,
    required this.triage,
    required this.followUpQuestions,
    required this.disclaimer,
    required this.createdAt,
  });

  factory SymptomCheckResponse.fromJson(Map<String, dynamic> json) {
    final followUps = (json['follow_up_questions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(FollowUpQuestion.fromJson)
        .toList();

    return SymptomCheckResponse(
      sessionId: json['session_id'] as String,
      triage: TriageResult.fromJson(json['triage'] as Map<String, dynamic>),
      followUpQuestions: followUps,
      disclaimer: json['disclaimer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class SymptomCatalog {
  final List<Symptom> symptoms;
  final List<String> categories;

  const SymptomCatalog({
    required this.symptoms,
    required this.categories,
  });

  factory SymptomCatalog.fromJson(Map<String, dynamic> json) {
    final symptoms = (json['symptoms'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Symptom.fromJson)
        .toList();

    return SymptomCatalog(
      symptoms: symptoms,
      categories: (json['categories'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

class SymptomSaveResponse {
  final String status;
  final String sessionId;

  const SymptomSaveResponse({
    required this.status,
    required this.sessionId,
  });

  factory SymptomSaveResponse.fromJson(Map<String, dynamic> json) {
    return SymptomSaveResponse(
      status: json['status'] as String,
      sessionId: json['session_id'] as String,
    );
  }
}
