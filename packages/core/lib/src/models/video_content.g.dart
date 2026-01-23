// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoContentImpl _$$VideoContentImplFromJson(Map<String, dynamic> json) =>
    _$VideoContentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      format: $enumDecode(_$VideoFormatEnumMap, json['format']),
      category: $enumDecode(_$VideoCategoryEnumMap, json['category']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      language: json['language'] as String? ?? 'de',
      authorId: json['authorId'] as String?,
      practiceId: json['practiceId'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VideoContentImplToJson(_$VideoContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'videoUrl': instance.videoUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'durationSeconds': instance.durationSeconds,
      'format': _$VideoFormatEnumMap[instance.format]!,
      'category': _$VideoCategoryEnumMap[instance.category]!,
      'tags': instance.tags,
      'language': instance.language,
      'authorId': instance.authorId,
      'practiceId': instance.practiceId,
      'isPublished': instance.isPublished,
      'viewCount': instance.viewCount,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$VideoFormatEnumMap = {
  VideoFormat.short: 'short',
  VideoFormat.medium: 'medium',
  VideoFormat.long: 'long',
};

const _$VideoCategoryEnumMap = {
  VideoCategory.healthTip: 'health_tip',
  VideoCategory.exercise: 'exercise',
  VideoCategory.nutrition: 'nutrition',
  VideoCategory.mentalHealth: 'mental_health',
  VideoCategory.procedureInfo: 'procedure_info',
  VideoCategory.prevention: 'prevention',
  VideoCategory.medication: 'medication',
  VideoCategory.general: 'general',
};
