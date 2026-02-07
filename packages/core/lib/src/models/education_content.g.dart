// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_content.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EducationContentImpl _$$EducationContentImplFromJson(
        Map<String, dynamic> json) =>
    _$EducationContentImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      type: $enumDecode(_$EducationContentTypeEnumMap, json['type']),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      audience: (json['audience'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$ContentAudienceEnumMap, e))
              .toList() ??
          const [ContentAudience.all],
      language: json['language'] as String? ?? 'de',
      readTimeMinutes: (json['readTimeMinutes'] as num?)?.toInt(),
      authorId: json['authorId'] as String,
      practiceId: json['practiceId'] as String,
      isPublished: json['isPublished'] as bool? ?? true,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
    );

Map<String, dynamic> _$$EducationContentImplToJson(
        _$EducationContentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'content': instance.content,
      'type': _$EducationContentTypeEnumMap[instance.type]!,
      'thumbnailUrl': instance.thumbnailUrl,
      'videoUrl': instance.videoUrl,
      'tags': instance.tags,
      'audience':
          instance.audience.map((e) => _$ContentAudienceEnumMap[e]!).toList(),
      'language': instance.language,
      'readTimeMinutes': instance.readTimeMinutes,
      'authorId': instance.authorId,
      'practiceId': instance.practiceId,
      'isPublished': instance.isPublished,
      'viewCount': instance.viewCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'publishedAt': instance.publishedAt?.toIso8601String(),
    };

const _$EducationContentTypeEnumMap = {
  EducationContentType.article: 'article',
  EducationContentType.video: 'video',
  EducationContentType.infographic: 'infographic',
  EducationContentType.checklist: 'checklist',
  EducationContentType.consentForm: 'consent_form',
  EducationContentType.instruction: 'instruction',
};

const _$ContentAudienceEnumMap = {
  ContentAudience.all: 'all',
  ContentAudience.preVisit: 'pre_visit',
  ContentAudience.postVisit: 'post_visit',
  ContentAudience.chronic: 'chronic',
  ContentAudience.pediatric: 'pediatric',
  ContentAudience.elderly: 'elderly',
};
