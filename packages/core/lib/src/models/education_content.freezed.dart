// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'education_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EducationContent _$EducationContentFromJson(Map<String, dynamic> json) {
  return _EducationContent.fromJson(json);
}

/// @nodoc
mixin _$EducationContent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError; // Markdown or HTML
  EducationContentType get type => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<ContentAudience> get audience => throw _privateConstructorUsedError;
  String get language => throw _privateConstructorUsedError;
  int? get readTimeMinutes => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get practiceId => throw _privateConstructorUsedError;
  bool get isPublished => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get publishedAt => throw _privateConstructorUsedError;

  /// Serializes this EducationContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EducationContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EducationContentCopyWith<EducationContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EducationContentCopyWith<$Res> {
  factory $EducationContentCopyWith(
          EducationContent value, $Res Function(EducationContent) then) =
      _$EducationContentCopyWithImpl<$Res, EducationContent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      String content,
      EducationContentType type,
      String? thumbnailUrl,
      String? videoUrl,
      List<String> tags,
      List<ContentAudience> audience,
      String language,
      int? readTimeMinutes,
      String authorId,
      String practiceId,
      bool isPublished,
      int viewCount,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? publishedAt});
}

/// @nodoc
class _$EducationContentCopyWithImpl<$Res, $Val extends EducationContent>
    implements $EducationContentCopyWith<$Res> {
  _$EducationContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EducationContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? content = null,
    Object? type = null,
    Object? thumbnailUrl = freezed,
    Object? videoUrl = freezed,
    Object? tags = null,
    Object? audience = null,
    Object? language = null,
    Object? readTimeMinutes = freezed,
    Object? authorId = null,
    Object? practiceId = null,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? publishedAt = freezed,
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
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EducationContentType,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      audience: null == audience
          ? _value.audience
          : audience // ignore: cast_nullable_to_non_nullable
              as List<ContentAudience>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      readTimeMinutes: freezed == readTimeMinutes
          ? _value.readTimeMinutes
          : readTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      practiceId: null == practiceId
          ? _value.practiceId
          : practiceId // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EducationContentImplCopyWith<$Res>
    implements $EducationContentCopyWith<$Res> {
  factory _$$EducationContentImplCopyWith(_$EducationContentImpl value,
          $Res Function(_$EducationContentImpl) then) =
      __$$EducationContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      String content,
      EducationContentType type,
      String? thumbnailUrl,
      String? videoUrl,
      List<String> tags,
      List<ContentAudience> audience,
      String language,
      int? readTimeMinutes,
      String authorId,
      String practiceId,
      bool isPublished,
      int viewCount,
      DateTime createdAt,
      DateTime? updatedAt,
      DateTime? publishedAt});
}

/// @nodoc
class __$$EducationContentImplCopyWithImpl<$Res>
    extends _$EducationContentCopyWithImpl<$Res, _$EducationContentImpl>
    implements _$$EducationContentImplCopyWith<$Res> {
  __$$EducationContentImplCopyWithImpl(_$EducationContentImpl _value,
      $Res Function(_$EducationContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of EducationContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? content = null,
    Object? type = null,
    Object? thumbnailUrl = freezed,
    Object? videoUrl = freezed,
    Object? tags = null,
    Object? audience = null,
    Object? language = null,
    Object? readTimeMinutes = freezed,
    Object? authorId = null,
    Object? practiceId = null,
    Object? isPublished = null,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? publishedAt = freezed,
  }) {
    return _then(_$EducationContentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as EducationContentType,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      audience: null == audience
          ? _value._audience
          : audience // ignore: cast_nullable_to_non_nullable
              as List<ContentAudience>,
      language: null == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      readTimeMinutes: freezed == readTimeMinutes
          ? _value.readTimeMinutes
          : readTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      practiceId: null == practiceId
          ? _value.practiceId
          : practiceId // ignore: cast_nullable_to_non_nullable
              as String,
      isPublished: null == isPublished
          ? _value.isPublished
          : isPublished // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      publishedAt: freezed == publishedAt
          ? _value.publishedAt
          : publishedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EducationContentImpl implements _EducationContent {
  const _$EducationContentImpl(
      {required this.id,
      required this.title,
      required this.summary,
      required this.content,
      required this.type,
      this.thumbnailUrl,
      this.videoUrl,
      final List<String> tags = const [],
      final List<ContentAudience> audience = const [ContentAudience.all],
      this.language = 'de',
      this.readTimeMinutes,
      required this.authorId,
      required this.practiceId,
      this.isPublished = true,
      this.viewCount = 0,
      required this.createdAt,
      this.updatedAt,
      this.publishedAt})
      : _tags = tags,
        _audience = audience;

  factory _$EducationContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$EducationContentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String summary;
  @override
  final String content;
// Markdown or HTML
  @override
  final EducationContentType type;
  @override
  final String? thumbnailUrl;
  @override
  final String? videoUrl;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<ContentAudience> _audience;
  @override
  @JsonKey()
  List<ContentAudience> get audience {
    if (_audience is EqualUnmodifiableListView) return _audience;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_audience);
  }

  @override
  @JsonKey()
  final String language;
  @override
  final int? readTimeMinutes;
  @override
  final String authorId;
  @override
  final String practiceId;
  @override
  @JsonKey()
  final bool isPublished;
  @override
  @JsonKey()
  final int viewCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? publishedAt;

  @override
  String toString() {
    return 'EducationContent(id: $id, title: $title, summary: $summary, content: $content, type: $type, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl, tags: $tags, audience: $audience, language: $language, readTimeMinutes: $readTimeMinutes, authorId: $authorId, practiceId: $practiceId, isPublished: $isPublished, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EducationContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(other._audience, _audience) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.readTimeMinutes, readTimeMinutes) ||
                other.readTimeMinutes == readTimeMinutes) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.practiceId, practiceId) ||
                other.practiceId == practiceId) &&
            (identical(other.isPublished, isPublished) ||
                other.isPublished == isPublished) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.publishedAt, publishedAt) ||
                other.publishedAt == publishedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      summary,
      content,
      type,
      thumbnailUrl,
      videoUrl,
      const DeepCollectionEquality().hash(_tags),
      const DeepCollectionEquality().hash(_audience),
      language,
      readTimeMinutes,
      authorId,
      practiceId,
      isPublished,
      viewCount,
      createdAt,
      updatedAt,
      publishedAt);

  /// Create a copy of EducationContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EducationContentImplCopyWith<_$EducationContentImpl> get copyWith =>
      __$$EducationContentImplCopyWithImpl<_$EducationContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EducationContentImplToJson(
      this,
    );
  }
}

abstract class _EducationContent implements EducationContent {
  const factory _EducationContent(
      {required final String id,
      required final String title,
      required final String summary,
      required final String content,
      required final EducationContentType type,
      final String? thumbnailUrl,
      final String? videoUrl,
      final List<String> tags,
      final List<ContentAudience> audience,
      final String language,
      final int? readTimeMinutes,
      required final String authorId,
      required final String practiceId,
      final bool isPublished,
      final int viewCount,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final DateTime? publishedAt}) = _$EducationContentImpl;

  factory _EducationContent.fromJson(Map<String, dynamic> json) =
      _$EducationContentImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get summary;
  @override
  String get content; // Markdown or HTML
  @override
  EducationContentType get type;
  @override
  String? get thumbnailUrl;
  @override
  String? get videoUrl;
  @override
  List<String> get tags;
  @override
  List<ContentAudience> get audience;
  @override
  String get language;
  @override
  int? get readTimeMinutes;
  @override
  String get authorId;
  @override
  String get practiceId;
  @override
  bool get isPublished;
  @override
  int get viewCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get publishedAt;

  /// Create a copy of EducationContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EducationContentImplCopyWith<_$EducationContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
