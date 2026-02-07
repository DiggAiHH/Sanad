/// Models for anamnesis templates and submissions.

enum QuestionType {
  text,
  textarea,
  number,
  date,
  singleChoice,
  multipleChoice,
  scale,
  yesNo,
  bodyMap,
}

QuestionType questionTypeFromJson(String value) {
  switch (value) {
    case 'text':
      return QuestionType.text;
    case 'textarea':
      return QuestionType.textarea;
    case 'number':
      return QuestionType.number;
    case 'date':
      return QuestionType.date;
    case 'single_choice':
      return QuestionType.singleChoice;
    case 'multiple_choice':
      return QuestionType.multipleChoice;
    case 'scale':
      return QuestionType.scale;
    case 'yes_no':
      return QuestionType.yesNo;
    case 'body_map':
      return QuestionType.bodyMap;
    default:
      throw ArgumentError('Unknown QuestionType: $value');
  }
}

String questionTypeToJson(QuestionType type) {
  switch (type) {
    case QuestionType.text:
      return 'text';
    case QuestionType.textarea:
      return 'textarea';
    case QuestionType.number:
      return 'number';
    case QuestionType.date:
      return 'date';
    case QuestionType.singleChoice:
      return 'single_choice';
    case QuestionType.multipleChoice:
      return 'multiple_choice';
    case QuestionType.scale:
      return 'scale';
    case QuestionType.yesNo:
      return 'yes_no';
    case QuestionType.bodyMap:
      return 'body_map';
  }
}

class QuestionCondition {
  final String questionId;
  final String operatorValue;
  final Object? value;

  const QuestionCondition({
    required this.questionId,
    required this.operatorValue,
    required this.value,
  });

  factory QuestionCondition.fromJson(Map<String, dynamic> json) {
    return QuestionCondition(
      questionId: json['question_id'] as String,
      operatorValue: json['operator'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'operator': operatorValue,
        'value': value,
      };
}

class Question {
  final String id;
  final String text;
  final String? description;
  final QuestionType type;
  final bool requiredAnswer;
  final List<String>? options;
  final int? minValue;
  final int? maxValue;
  final String? placeholder;
  final QuestionCondition? condition;
  final int order;

  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.requiredAnswer,
    required this.order,
    this.description,
    this.options,
    this.minValue,
    this.maxValue,
    this.placeholder,
    this.condition,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      description: json['description'] as String?,
      type: questionTypeFromJson(json['type'] as String),
      requiredAnswer: json['required'] as bool? ?? false,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      minValue: json['min_value'] as int?,
      maxValue: json['max_value'] as int?,
      placeholder: json['placeholder'] as String?,
      condition: json['condition'] == null
          ? null
          : QuestionCondition.fromJson(
              json['condition'] as Map<String, dynamic>,
            ),
      order: json['order'] as int? ?? 0,
    );
  }
}

class QuestionSection {
  final String id;
  final String title;
  final String? description;
  final List<Question> questions;
  final int order;

  const QuestionSection({
    required this.id,
    required this.title,
    required this.questions,
    required this.order,
    this.description,
  });

  factory QuestionSection.fromJson(Map<String, dynamic> json) {
    final items = (json['questions'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Question.fromJson)
        .toList();

    return QuestionSection(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questions: items,
      order: json['order'] as int? ?? 0,
    );
  }
}

class AnamnesisTemplate {
  final String id;
  final String name;
  final String description;
  final List<String> appointmentTypes;
  final List<QuestionSection> sections;
  final int estimatedMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnamnesisTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.appointmentTypes,
    required this.sections,
    required this.estimatedMinutes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnamnesisTemplate.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(QuestionSection.fromJson)
        .toList();

    return AnamnesisTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      appointmentTypes: (json['appointment_types'] as List<dynamic>? ?? [])
          .cast<String>(),
      sections: sections,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class Answer {
  final String questionId;
  final Object? value;

  const Answer({
    required this.questionId,
    required this.value,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      questionId: json['question_id'] as String,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() => {
        'question_id': questionId,
        'value': value,
      };
}

class AnamnesisSubmission {
  final String id;
  final String templateId;
  final String patientId;
  final String? appointmentId;
  final List<Answer> answers;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? pdfUrl;

  const AnamnesisSubmission({
    required this.id,
    required this.templateId,
    required this.patientId,
    required this.answers,
    required this.submittedAt,
    this.appointmentId,
    this.reviewedAt,
    this.reviewedBy,
    this.pdfUrl,
  });

  factory AnamnesisSubmission.fromJson(Map<String, dynamic> json) {
    final answers = (json['answers'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(Answer.fromJson)
        .toList();

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return AnamnesisSubmission(
      id: json['id'] as String,
      templateId: json['template_id'] as String,
      patientId: json['patient_id'] as String,
      appointmentId: json['appointment_id'] as String?,
      answers: answers,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      reviewedAt: parseDate(json['reviewed_at']),
      reviewedBy: json['reviewed_by'] as String?,
      pdfUrl: json['pdf_url'] as String?,
    );
  }
}

class SubmitAnamnesisRequest {
  final String templateId;
  final String? appointmentId;
  final List<Answer> answers;

  const SubmitAnamnesisRequest({
    required this.templateId,
    required this.answers,
    this.appointmentId,
  });

  Map<String, dynamic> toJson() => {
        'template_id': templateId,
        if (appointmentId != null) 'appointment_id': appointmentId,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      };
}
