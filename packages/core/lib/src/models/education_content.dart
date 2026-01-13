import 'package:freezed_annotation/freezed_annotation.dart';

part 'education_content.freezed.dart';
part 'education_content.g.dart';

/// Content type for patient education
enum EducationContentType {
  @JsonValue('article')
  article,
  @JsonValue('video')
  video,
  @JsonValue('infographic')
  infographic,
  @JsonValue('checklist')
  checklist,
  @JsonValue('consent_form')
  consentForm,
  @JsonValue('instruction')
  instruction,
}

/// Target audience for content
enum ContentAudience {
  @JsonValue('all')
  all,
  @JsonValue('pre_visit')
  preVisit,
  @JsonValue('post_visit')
  postVisit,
  @JsonValue('chronic')
  chronic,
  @JsonValue('pediatric')
  pediatric,
  @JsonValue('elderly')
  elderly,
}

/// Patient education content model
@freezed
class EducationContent with _$EducationContent {
  const factory EducationContent({
    required String id,
    required String title,
    required String summary,
    required String content, // Markdown or HTML
    required EducationContentType type,
    String? thumbnailUrl,
    String? videoUrl,
    @Default([]) List<String> tags,
    @Default([ContentAudience.all]) List<ContentAudience> audience,
    @Default('de') String language,
    int? readTimeMinutes,
    required String authorId,
    required String practiceId,
    @Default(true) bool isPublished,
    @Default(0) int viewCount,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
  }) = _EducationContent;

  factory EducationContent.fromJson(Map<String, dynamic> json) =>
      _$EducationContentFromJson(json);
}
