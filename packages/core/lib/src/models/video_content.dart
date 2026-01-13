import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_content.freezed.dart';
part 'video_content.g.dart';

/// Video format (TikTok-style shorts)
enum VideoFormat {
  @JsonValue('short')
  short, // < 60 seconds
  @JsonValue('medium')
  medium, // 1-5 minutes
  @JsonValue('long')
  long, // > 5 minutes
}

/// Video category
enum VideoCategory {
  @JsonValue('health_tip')
  healthTip,
  @JsonValue('exercise')
  exercise,
  @JsonValue('nutrition')
  nutrition,
  @JsonValue('mental_health')
  mentalHealth,
  @JsonValue('procedure_info')
  procedureInfo,
  @JsonValue('prevention')
  prevention,
  @JsonValue('medication')
  medication,
  @JsonValue('general')
  general,
}

/// Short video content (TikTok-style)
@freezed
class VideoContent with _$VideoContent {
  const factory VideoContent({
    required String id,
    required String title,
    String? description,
    required String videoUrl,
    required String thumbnailUrl,
    required int durationSeconds,
    required VideoFormat format,
    required VideoCategory category,
    @Default([]) List<String> tags,
    @Default('de') String language,
    String? authorId,
    String? practiceId,
    @Default(true) bool isPublished,
    @Default(0) int viewCount,
    @Default(0) int likeCount,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _VideoContent;

  factory VideoContent.fromJson(Map<String, dynamic> json) =>
      _$VideoContentFromJson(json);
}

extension VideoContentExtension on VideoContent {
  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isShort => durationSeconds <= 60;
}
