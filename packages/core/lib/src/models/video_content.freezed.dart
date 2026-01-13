// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VideoContent _$VideoContentFromJson(Map<String, dynamic> json) {
  return _VideoContent.fromJson(json);
}

/// @nodoc
mixin _$VideoContent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get videoUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  VideoFormat get format => throw _privateConstructorUsedError;
  VideoCategory get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String? get practiceId => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoContentCopyWith<VideoContent> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoContentCopyWith<$Res> {
  factory $VideoContentCopyWith(VideoContent value, $Res Function(VideoContent) then) = _$VideoContentCopyWithImpl<$Res, VideoContent>;
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String videoUrl,
    String? thumbnailUrl,
    int durationSeconds,
    VideoFormat format,
    VideoCategory category,
    List<String> tags,
    String language,
    String authorId,
    String? practiceId,
    bool isPublished,
    int viewCount,
    int likeCount,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$VideoContentCopyWithImpl<$Res, $Val extends VideoContent> implements $VideoContentCopyWith<$Res> {
  _$VideoContentCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? durationSeconds = null,
    Object? format = null,
    Object? category = null,
    Object? tags = null,
    Object? language = null,
    Object? authorId = null,
    Object? practiceId = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      description: null == description ? _value.description : description as String,
      videoUrl: null == videoUrl ? _value.videoUrl : videoUrl as String,
      thumbnailUrl: freezed == thumbnailUrl ? _value.thumbnailUrl : thumbnailUrl as String?,
      durationSeconds: null == durationSeconds ? _value.durationSeconds : durationSeconds as int,
      format: null == format ? _value.format : format as VideoFormat,
      category: null == category ? _value.category : category as VideoCategory,
      tags: null == tags ? _value.tags : tags as List<String>,
      language: null == language ? _value.language : language as String,
      authorId: null == authorId ? _value.authorId : authorId as String,
      practiceId: freezed == practiceId ? _value.practiceId : practiceId as String?,
      isPublished: null == isPublished ? _value.isPublished : isPublished as bool,
      viewCount: null == viewCount ? _value.viewCount : viewCount as int,
      likeCount: null == likeCount ? _value.likeCount : likeCount as int,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoContentImplCopyWith<$Res> implements $VideoContentCopyWith<$Res> {
  factory _$$VideoContentImplCopyWith(_$VideoContentImpl value, $Res Function(_$VideoContentImpl) then) = __$$VideoContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String description,
    String videoUrl,
    String? thumbnailUrl,
    int durationSeconds,
    VideoFormat format,
    VideoCategory category,
    List<String> tags,
    String language,
    String authorId,
    String? practiceId,
    bool isPublished,
    int viewCount,
    int likeCount,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$VideoContentImplCopyWithImpl<$Res> extends _$VideoContentCopyWithImpl<$Res, _$VideoContentImpl> implements _$$VideoContentImplCopyWith<$Res> {
  __$$VideoContentImplCopyWithImpl(_$VideoContentImpl _value, $Res Function(_$VideoContentImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? durationSeconds = null,
    Object? format = null,
    Object? category = null,
    Object? tags = null,
    Object? language = null,
    Object? authorId = null,
    Object? practiceId = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$VideoContentImpl(
      id: null == id ? _value.id : id as String,
      title: null == title ? _value.title : title as String,
      description: null == description ? _value.description : description as String,
      videoUrl: null == videoUrl ? _value.videoUrl : videoUrl as String,
      thumbnailUrl: freezed == thumbnailUrl ? _value.thumbnailUrl : thumbnailUrl as String?,
      durationSeconds: null == durationSeconds ? _value.durationSeconds : durationSeconds as int,
      format: null == format ? _value.format : format as VideoFormat,
      category: null == category ? _value.category : category as VideoCategory,
      tags: null == tags ? _value._tags : tags as List<String>,
      language: null == language ? _value.language : language as String,
      authorId: null == authorId ? _value.authorId : authorId as String,
      practiceId: freezed == practiceId ? _value.practiceId : practiceId as String?,
      isPublished: null == isPublished ? _value.isPublished : isPublished as bool,
      viewCount: null == viewCount ? _value.viewCount : viewCount as int,
      likeCount: null == likeCount ? _value.likeCount : likeCount as int,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: null == updatedAt ? _value.updatedAt : updatedAt as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoContentImpl implements _VideoContent {
  const _$VideoContentImpl({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    this.format = VideoFormat.mp4,
    this.category = VideoCategory.educational,
    final List<String> tags = const [],
    this.language = 'de',
    required this.authorId,
    this.practiceId,
    this.isPublished = false,
    this.viewCount = 0,
    this.likeCount = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : _tags = tags;

  factory _$VideoContentImpl.fromJson(Map<String, dynamic> json) => _$$VideoContentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String videoUrl;
  @override
  final String? thumbnailUrl;
  @override
  final int durationSeconds;
  @override
  @JsonKey()
  final VideoFormat format;
  @override
  @JsonKey()
  final VideoCategory category;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags => List.unmodifiable(_tags);
  @override
  @JsonKey()
  final String language;
  @override
  final String authorId;
  @override
  final String? practiceId;
  @override
  @JsonKey()
  final bool isPublished;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int likeCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'VideoContent(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, durationSeconds: $durationSeconds, format: $format, category: $category, tags: $tags, language: $language, authorId: $authorId, practiceId: $practiceId, isPublished: $isPublished, viewCount: $viewCount, likeCount: $likeCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.category, category) || other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.language, language) || other.language == language) &&
            (identical(other.authorId, authorId) || other.authorId == authorId) &&
            (identical(other.practiceId, practiceId) || other.practiceId == practiceId) &&
            (identical(other.isPublished, isPublished) || other.isPublished == isPublished) &&
            (identical(other.viewCount, viewCount) || other.viewCount == viewCount) &&
            (identical(other.likeCount, likeCount) || other.likeCount == likeCount) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, videoUrl, thumbnailUrl, durationSeconds, format, category, const DeepCollectionEquality().hash(_tags), language, authorId, practiceId, isPublished, viewCount, likeCount, createdAt, updatedAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith => __$$VideoContentImplCopyWithImpl<_$VideoContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoContentImplToJson(this);
  }
}

abstract class _VideoContent implements VideoContent {
  const factory _VideoContent({
    required final String id,
    required final String title,
    required final String description,
    required final String videoUrl,
    final String? thumbnailUrl,
    required final int durationSeconds,
    final VideoFormat format,
    final VideoCategory category,
    final List<String> tags,
    final String language,
    required final String authorId,
    final String? practiceId,
    final bool isPublished,
    final int viewCount,
    final int likeCount,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$VideoContentImpl;

  factory _VideoContent.fromJson(Map<String, dynamic> json) = _$VideoContentImpl.fromJson;

  @override String get id;
  @override String get title;
  @override String get description;
  @override String get videoUrl;
  @override String? get thumbnailUrl;
  @override int get durationSeconds;
  @override VideoFormat get format;
  @override VideoCategory get category;
  @override List<String> get tags;
  @override String get language;
  @override String get authorId;
  @override String? get practiceId;
  @override bool get isPublished;
  @override int get viewCount;
  @override int get likeCount;
  @override DateTime get createdAt;
  @override DateTime get updatedAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith => throw _privateConstructorUsedError;
}
