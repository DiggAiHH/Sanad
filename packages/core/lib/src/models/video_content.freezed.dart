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
  String? get description => throw _privateConstructorUsedError;
  String get videoUrl => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  VideoFormat get format => throw _privateConstructorUsedError;
  VideoCategory get category => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  String? get authorId => throw _privateConstructorUsedError;
  String? get practiceId => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this VideoContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoContentCopyWith<VideoContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoContentCopyWith<$Res> {
  factory $VideoContentCopyWith(
          VideoContent value, $Res Function(VideoContent) then) =
      _$VideoContentCopyWithImpl<$Res, VideoContent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String videoUrl,
      String thumbnailUrl,
      int durationSeconds,
      VideoFormat format,
      VideoCategory category,
      List<String> tags,
      String language,
      String? authorId,
      String? practiceId,
      bool isPublished,
      int viewCount,
      int likeCount,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$VideoContentCopyWithImpl<$Res, $Val extends VideoContent>
    implements $VideoContentCopyWith<$Res> {
  _$VideoContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoUrl = null,
    Object? thumbnailUrl = null,
    Object? durationSeconds = null,
    Object? format = null,
    Object? category = null,
    Object? tags = null,
    Object? language = null,
    Object? authorId = freezed,
    Object? practiceId = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as VideoFormat,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as VideoCategory,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String?,
      practiceId: freezed == practiceId
          ? _value.practiceId
          : practiceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VideoContentImplCopyWith<$Res>
    implements $VideoContentCopyWith<$Res> {
  factory _$$VideoContentImplCopyWith(
          _$VideoContentImpl value, $Res Function(_$VideoContentImpl) then) =
      __$$VideoContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String? description,
      String videoUrl,
      String thumbnailUrl,
      int durationSeconds,
      VideoFormat format,
      VideoCategory category,
      List<String> tags,
      String language,
      String? authorId,
      String? practiceId,
      bool isPublished,
      int viewCount,
      int likeCount,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$VideoContentImplCopyWithImpl<$Res>
    extends _$VideoContentCopyWithImpl<$Res, _$VideoContentImpl>
    implements _$$VideoContentImplCopyWith<$Res> {
  __$$VideoContentImplCopyWithImpl(
      _$VideoContentImpl _value, $Res Function(_$VideoContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of VideoContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoUrl = null,
    Object? thumbnailUrl = null,
    Object? durationSeconds = null,
    Object? format = null,
    Object? category = null,
    Object? tags = null,
    Object? language = null,
    Object? authorId = freezed,
    Object? practiceId = freezed,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? likeCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$VideoContentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: null == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      durationSeconds: null == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as VideoFormat,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as VideoCategory,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: freezed == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String?,
      practiceId: freezed == practiceId
          ? _value.practiceId
          : practiceId // ignore: cast_nullable_to_non_nullable
              as String?,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoContentImpl implements _VideoContent {
  const _$VideoContentImpl(
      {required this.id,
      required this.title,
      this.description,
      required this.videoUrl,
      required this.thumbnailUrl,
      required this.durationSeconds,
      required this.format,
      required this.category,
      final List<String> tags = const [],
      this.language = 'de',
      this.authorId,
      this.practiceId,
      this.isPublished = true,
      this.viewCount = 0,
      this.likeCount = 0,
      required this.createdAt,
      this.updatedAt})
      : _tags = tags;

  factory _$VideoContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoContentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String videoUrl;
  @override
  final String thumbnailUrl;
  @override
  final int durationSeconds;
  @override
  final VideoFormat format;
  @override
  final VideoCategory category;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String language;
  @override
  final String? authorId;
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
  final DateTime? updatedAt;

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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.practiceId, practiceId) ||
                other.practiceId == practiceId) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      videoUrl,
      thumbnailUrl,
      durationSeconds,
      format,
      category,
      const DeepCollectionEquality().hash(_tags),
      language,
      authorId,
      practiceId,
      isPublished,
      viewCount,
      likeCount,
      createdAt,
      updatedAt);

  /// Create a copy of VideoContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith =>
      __$$VideoContentImplCopyWithImpl<_$VideoContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoContentImplToJson(
      this,
    );
  }
}

abstract class _VideoContent implements VideoContent {
  const factory _VideoContent(
      {required final String id,
      required final String title,
      final String? description,
      required final String videoUrl,
      required final String thumbnailUrl,
      required final int durationSeconds,
      required final VideoFormat format,
      required final VideoCategory category,
      final List<String> tags,
      final String language,
      final String? authorId,
      final String? practiceId,
      final bool isPublished,
      final int viewCount,
      final int likeCount,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$VideoContentImpl;

  factory _VideoContent.fromJson(Map<String, dynamic> json) =
      _$VideoContentImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get videoUrl;
  @override
  String get thumbnailUrl;
  @override
  int get durationSeconds;
  @override
  VideoFormat get format;
  @override
  VideoCategory get category;
  @override
  List<String> get tags;
  @override
  String get language;
  @override
  String? get authorId;
  @override
  String? get practiceId;
  @override
  bool get isPublished;
  @override
  int get viewCount;
  @override
  int get likeCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of VideoContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
