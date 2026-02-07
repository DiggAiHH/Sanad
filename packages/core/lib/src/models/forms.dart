/// Models for practice forms.

enum FormCategory {
  general,
  consent,
  medical,
  insurance,
  referral,
  prescription,
  certificate,
  travel,
}

FormCategory formCategoryFromJson(String value) {
  switch (value) {
    case 'general':
      return FormCategory.general;
    case 'consent':
      return FormCategory.consent;
    case 'medical':
      return FormCategory.medical;
    case 'insurance':
      return FormCategory.insurance;
    case 'referral':
      return FormCategory.referral;
    case 'prescription':
      return FormCategory.prescription;
    case 'certificate':
      return FormCategory.certificate;
    case 'travel':
      return FormCategory.travel;
    default:
      throw ArgumentError('Unknown FormCategory: $value');
  }
}

String formCategoryToJson(FormCategory category) {
  switch (category) {
    case FormCategory.general:
      return 'general';
    case FormCategory.consent:
      return 'consent';
    case FormCategory.medical:
      return 'medical';
    case FormCategory.insurance:
      return 'insurance';
    case FormCategory.referral:
      return 'referral';
    case FormCategory.prescription:
      return 'prescription';
    case FormCategory.certificate:
      return 'certificate';
    case FormCategory.travel:
      return 'travel';
  }
}

enum FormFormat {
  pdf,
  docx,
  online,
}

FormFormat formFormatFromJson(String value) {
  switch (value) {
    case 'pdf':
      return FormFormat.pdf;
    case 'docx':
      return FormFormat.docx;
    case 'online':
      return FormFormat.online;
    default:
      throw ArgumentError('Unknown FormFormat: $value');
  }
}

String formFormatToJson(FormFormat format) {
  switch (format) {
    case FormFormat.pdf:
      return 'pdf';
    case FormFormat.docx:
      return 'docx';
    case FormFormat.online:
      return 'online';
  }
}

class PracticeForm {
  final String id;
  final String name;
  final String description;
  final FormCategory category;
  final List<FormFormat> formats;
  final bool fillableOnline;
  final bool requiresAuth;
  final int downloadCount;
  final DateTime lastUpdated;
  final String? thumbnailUrl;

  const PracticeForm({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.formats,
    required this.fillableOnline,
    required this.requiresAuth,
    required this.downloadCount,
    required this.lastUpdated,
    this.thumbnailUrl,
  });

  factory PracticeForm.fromJson(Map<String, dynamic> json) {
    final formats = (json['formats'] as List<dynamic>? ?? [])
        .map((format) => formFormatFromJson(format as String))
        .toList();

    return PracticeForm(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: formCategoryFromJson(json['category'] as String),
      formats: formats,
      fillableOnline: json['fillable_online'] as bool? ?? false,
      requiresAuth: json['requires_auth'] as bool? ?? false,
      downloadCount: json['download_count'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

class FormCategoryInfo {
  final String id;
  final String name;
  final int count;

  const FormCategoryInfo({
    required this.id,
    required this.name,
    required this.count,
  });

  factory FormCategoryInfo.fromJson(Map<String, dynamic> json) {
    return FormCategoryInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      count: json['count'] as int,
    );
  }
}

class FormDownloadInfo {
  final String formId;
  final String format;
  final String downloadUrl;
  final int expiresIn;

  const FormDownloadInfo({
    required this.formId,
    required this.format,
    required this.downloadUrl,
    required this.expiresIn,
  });

  factory FormDownloadInfo.fromJson(Map<String, dynamic> json) {
    return FormDownloadInfo(
      formId: json['form_id'] as String,
      format: json['format'].toString(),
      downloadUrl: json['download_url'] as String,
      expiresIn: json['expires_in'] as int? ?? 0,
    );
  }
}

class FormSubmissionResponse {
  final String status;
  final String submissionId;
  final String formName;
  final DateTime submittedAt;
  final String message;

  const FormSubmissionResponse({
    required this.status,
    required this.submissionId,
    required this.formName,
    required this.submittedAt,
    required this.message,
  });

  factory FormSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return FormSubmissionResponse(
      status: json['status'] as String,
      submissionId: json['submission_id'] as String,
      formName: json['form_name'] as String,
      submittedAt: DateTime.parse(json['submitted_at'] as String),
      message: json['message'] as String,
    );
  }
}
