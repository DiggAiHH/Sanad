// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoContentImpl _$$VideoContentImplFromJson(Map<String, dynamic> json) => _$VideoContentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      format: $enumDecodeNullable(_$VideoFormatEnumMap, json['format']) ?? VideoFormat.mp4,
      category: $enumDecodeNullable(_$VideoCategoryEnumMap, json['category']) ?? VideoCategory.educational,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      language: json['language'] as String? ?? 'de',
      authorId: json['authorId'] as String,
      practiceId: json['practiceId'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$VideoContentImplToJson(_$VideoContentImpl instance) => <String, dynamic>{
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
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$VideoFormatEnumMap = {
  VideoFormat.mp4: 'mp4',
  VideoFormat.webm: 'webm',
  VideoFormat.hls: 'hls',
  VideoFormat.youtube: 'youtube',
};

const _$VideoCategoryEnumMap = {
  VideoCategory.educational: 'educational',
  VideoCategory.procedural: 'procedural',
  VideoCategory.testimonial: 'testimonial',
  VideoCategory.promotional: 'promotional',
  VideoCategory.training: 'training',
};
