// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StaffMember _$StaffMemberFromJson(Map<String, dynamic> json) {
  return _StaffMember.fromJson(json);
}

/// @nodoc
mixin _$StaffMember {
  String get id => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError; // Dr., Prof., etc.
  Specialization? get specialization => throw _privateConstructorUsedError;
  String? get roomNumber => throw _privateConstructorUsedError;
  bool get acceptingPatients => throw _privateConstructorUsedError;
  List<String> get qualifications => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;
  DateTime? get availableFrom => throw _privateConstructorUsedError;
  DateTime? get availableUntil => throw _privateConstructorUsedError;

  /// Serializes this StaffMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StaffMemberCopyWith<StaffMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StaffMemberCopyWith<$Res> {
  factory $StaffMemberCopyWith(
          StaffMember value, $Res Function(StaffMember) then) =
      _$StaffMemberCopyWithImpl<$Res, StaffMember>;
  @useResult
  $Res call(
      {String id,
      User user,
      String? title,
      Specialization? specialization,
      String? roomNumber,
      bool acceptingPatients,
      List<String> qualifications,
      String? bio,
      bool isAvailable,
      DateTime? availableFrom,
      DateTime? availableUntil});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$StaffMemberCopyWithImpl<$Res, $Val extends StaffMember>
    implements $StaffMemberCopyWith<$Res> {
  _$StaffMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? title = freezed,
    Object? specialization = freezed,
    Object? roomNumber = freezed,
    Object? acceptingPatients = null,
    Object? qualifications = null,
    Object? bio = freezed,
    Object? isAvailable = null,
    Object? availableFrom = freezed,
    Object? availableUntil = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      specialization: freezed == specialization
          ? _value.specialization
          : specialization // ignore: cast_nullable_to_non_nullable
              as Specialization?,
      roomNumber: freezed == roomNumber
          ? _value.roomNumber
          : roomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptingPatients: null == acceptingPatients
          ? _value.acceptingPatients
          : acceptingPatients // ignore: cast_nullable_to_non_nullable
              as bool,
      qualifications: null == qualifications
          ? _value.qualifications
          : qualifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      availableFrom: freezed == availableFrom
          ? _value.availableFrom
          : availableFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      availableUntil: freezed == availableUntil
          ? _value.availableUntil
          : availableUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserCopyWith<$Res> get user {
    return $UserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StaffMemberImplCopyWith<$Res>
    implements $StaffMemberCopyWith<$Res> {
  factory _$$StaffMemberImplCopyWith(
          _$StaffMemberImpl value, $Res Function(_$StaffMemberImpl) then) =
      __$$StaffMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      User user,
      String? title,
      Specialization? specialization,
      String? roomNumber,
      bool acceptingPatients,
      List<String> qualifications,
      String? bio,
      bool isAvailable,
      DateTime? availableFrom,
      DateTime? availableUntil});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$StaffMemberImplCopyWithImpl<$Res>
    extends _$StaffMemberCopyWithImpl<$Res, _$StaffMemberImpl>
    implements _$$StaffMemberImplCopyWith<$Res> {
  __$$StaffMemberImplCopyWithImpl(
      _$StaffMemberImpl _value, $Res Function(_$StaffMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? title = freezed,
    Object? specialization = freezed,
    Object? roomNumber = freezed,
    Object? acceptingPatients = null,
    Object? qualifications = null,
    Object? bio = freezed,
    Object? isAvailable = null,
    Object? availableFrom = freezed,
    Object? availableUntil = freezed,
  }) {
    return _then(_$StaffMemberImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      specialization: freezed == specialization
          ? _value.specialization
          : specialization // ignore: cast_nullable_to_non_nullable
              as Specialization?,
      roomNumber: freezed == roomNumber
          ? _value.roomNumber
          : roomNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptingPatients: null == acceptingPatients
          ? _value.acceptingPatients
          : acceptingPatients // ignore: cast_nullable_to_non_nullable
              as bool,
      qualifications: null == qualifications
          ? _value._qualifications
          : qualifications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      availableFrom: freezed == availableFrom
          ? _value.availableFrom
          : availableFrom // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      availableUntil: freezed == availableUntil
          ? _value.availableUntil
          : availableUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StaffMemberImpl implements _StaffMember {
  const _$StaffMemberImpl(
      {required this.id,
      required this.user,
      this.title,
      this.specialization,
      this.roomNumber,
      this.acceptingPatients = true,
      final List<String> qualifications = const [],
      this.bio,
      this.isAvailable = true,
      this.availableFrom,
      this.availableUntil})
      : _qualifications = qualifications;

  factory _$StaffMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$StaffMemberImplFromJson(json);

  @override
  final String id;
  @override
  final User user;
  @override
  final String? title;
// Dr., Prof., etc.
  @override
  final Specialization? specialization;
  @override
  final String? roomNumber;
  @override
  @JsonKey()
  final bool acceptingPatients;
  final List<String> _qualifications;
  @override
  @JsonKey()
  List<String> get qualifications {
    if (_qualifications is EqualUnmodifiableListView) return _qualifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_qualifications);
  }

  @override
  final String? bio;
  @override
  @JsonKey()
  final bool isAvailable;
  @override
  final DateTime? availableFrom;
  @override
  final DateTime? availableUntil;

  @override
  String toString() {
    return 'StaffMember(id: $id, user: $user, title: $title, specialization: $specialization, roomNumber: $roomNumber, acceptingPatients: $acceptingPatients, qualifications: $qualifications, bio: $bio, isAvailable: $isAvailable, availableFrom: $availableFrom, availableUntil: $availableUntil)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StaffMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.specialization, specialization) ||
                other.specialization == specialization) &&
            (identical(other.roomNumber, roomNumber) ||
                other.roomNumber == roomNumber) &&
            (identical(other.acceptingPatients, acceptingPatients) ||
                other.acceptingPatients == acceptingPatients) &&
            const DeepCollectionEquality()
                .equals(other._qualifications, _qualifications) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.availableFrom, availableFrom) ||
                other.availableFrom == availableFrom) &&
            (identical(other.availableUntil, availableUntil) ||
                other.availableUntil == availableUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      title,
      specialization,
      roomNumber,
      acceptingPatients,
      const DeepCollectionEquality().hash(_qualifications),
      bio,
      isAvailable,
      availableFrom,
      availableUntil);

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StaffMemberImplCopyWith<_$StaffMemberImpl> get copyWith =>
      __$$StaffMemberImplCopyWithImpl<_$StaffMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StaffMemberImplToJson(
      this,
    );
  }
}

abstract class _StaffMember implements StaffMember {
  const factory _StaffMember(
      {required final String id,
      required final User user,
      final String? title,
      final Specialization? specialization,
      final String? roomNumber,
      final bool acceptingPatients,
      final List<String> qualifications,
      final String? bio,
      final bool isAvailable,
      final DateTime? availableFrom,
      final DateTime? availableUntil}) = _$StaffMemberImpl;

  factory _StaffMember.fromJson(Map<String, dynamic> json) =
      _$StaffMemberImpl.fromJson;

  @override
  String get id;
  @override
  User get user;
  @override
  String? get title; // Dr., Prof., etc.
  @override
  Specialization? get specialization;
  @override
  String? get roomNumber;
  @override
  bool get acceptingPatients;
  @override
  List<String> get qualifications;
  @override
  String? get bio;
  @override
  bool get isAvailable;
  @override
  DateTime? get availableFrom;
  @override
  DateTime? get availableUntil;

  /// Create a copy of StaffMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StaffMemberImplCopyWith<_$StaffMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
