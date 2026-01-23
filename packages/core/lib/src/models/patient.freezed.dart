// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
  String get id => throw _privateConstructorUsedError;
  User get user => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String? get insuranceNumber => throw _privateConstructorUsedError;
  InsuranceType? get insuranceType => throw _privateConstructorUsedError;
  String? get insuranceProvider => throw _privateConstructorUsedError;
  String? get emergencyContactName => throw _privateConstructorUsedError;
  String? get emergencyContactPhone => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get medications => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get hasConsentForms => throw _privateConstructorUsedError;
  DateTime? get lastVisit => throw _privateConstructorUsedError;

  /// Serializes this Patient to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
  @useResult
  $Res call(
      {String id,
      User user,
      DateTime dateOfBirth,
      String? insuranceNumber,
      InsuranceType? insuranceType,
      String? insuranceProvider,
      String? emergencyContactName,
      String? emergencyContactPhone,
      List<String> allergies,
      List<String> medications,
      String? notes,
      bool hasConsentForms,
      DateTime? lastVisit});

  $UserCopyWith<$Res> get user;
}

/// @nodoc
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? dateOfBirth = null,
    Object? insuranceNumber = freezed,
    Object? insuranceType = freezed,
    Object? insuranceProvider = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? notes = freezed,
    Object? hasConsentForms = null,
    Object? lastVisit = freezed,
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
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      insuranceNumber: freezed == insuranceNumber
          ? _value.insuranceNumber
          : insuranceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      insuranceType: freezed == insuranceType
          ? _value.insuranceType
          : insuranceType // ignore: cast_nullable_to_non_nullable
              as InsuranceType?,
      insuranceProvider: freezed == insuranceProvider
          ? _value.insuranceProvider
          : insuranceProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactName: freezed == emergencyContactName
          ? _value.emergencyContactName
          : emergencyContactName // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactPhone: freezed == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: null == allergies
          ? _value.allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medications: null == medications
          ? _value.medications
          : medications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      hasConsentForms: null == hasConsentForms
          ? _value.hasConsentForms
          : hasConsentForms // ignore: cast_nullable_to_non_nullable
              as bool,
      lastVisit: freezed == lastVisit
          ? _value.lastVisit
          : lastVisit // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of Patient
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
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
          _$PatientImpl value, $Res Function(_$PatientImpl) then) =
      __$$PatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      User user,
      DateTime dateOfBirth,
      String? insuranceNumber,
      InsuranceType? insuranceType,
      String? insuranceProvider,
      String? emergencyContactName,
      String? emergencyContactPhone,
      List<String> allergies,
      List<String> medications,
      String? notes,
      bool hasConsentForms,
      DateTime? lastVisit});

  @override
  $UserCopyWith<$Res> get user;
}

/// @nodoc
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
      _$PatientImpl _value, $Res Function(_$PatientImpl) _then)
      : super(_value, _then);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? user = null,
    Object? dateOfBirth = null,
    Object? insuranceNumber = freezed,
    Object? insuranceType = freezed,
    Object? insuranceProvider = freezed,
    Object? emergencyContactName = freezed,
    Object? emergencyContactPhone = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? notes = freezed,
    Object? hasConsentForms = null,
    Object? lastVisit = freezed,
  }) {
    return _then(_$PatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as User,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      insuranceNumber: freezed == insuranceNumber
          ? _value.insuranceNumber
          : insuranceNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      insuranceType: freezed == insuranceType
          ? _value.insuranceType
          : insuranceType // ignore: cast_nullable_to_non_nullable
              as InsuranceType?,
      insuranceProvider: freezed == insuranceProvider
          ? _value.insuranceProvider
          : insuranceProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactName: freezed == emergencyContactName
          ? _value.emergencyContactName
          : emergencyContactName // ignore: cast_nullable_to_non_nullable
              as String?,
      emergencyContactPhone: freezed == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      allergies: null == allergies
          ? _value._allergies
          : allergies // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medications: null == medications
          ? _value._medications
          : medications // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      hasConsentForms: null == hasConsentForms
          ? _value.hasConsentForms
          : hasConsentForms // ignore: cast_nullable_to_non_nullable
              as bool,
      lastVisit: freezed == lastVisit
          ? _value.lastVisit
          : lastVisit // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientImpl implements _Patient {
  const _$PatientImpl(
      {required this.id,
      required this.user,
      required this.dateOfBirth,
      this.insuranceNumber,
      this.insuranceType,
      this.insuranceProvider,
      this.emergencyContactName,
      this.emergencyContactPhone,
      final List<String> allergies = const [],
      final List<String> medications = const [],
      this.notes,
      this.hasConsentForms = false,
      this.lastVisit})
      : _allergies = allergies,
        _medications = medications;

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

  @override
  final String id;
  @override
  final User user;
  @override
  final DateTime dateOfBirth;
  @override
  final String? insuranceNumber;
  @override
  final InsuranceType? insuranceType;
  @override
  final String? insuranceProvider;
  @override
  final String? emergencyContactName;
  @override
  final String? emergencyContactPhone;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _medications;
  @override
  @JsonKey()
  List<String> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  @override
  final String? notes;
  @override
  @JsonKey()
  final bool hasConsentForms;
  @override
  final DateTime? lastVisit;

  @override
  String toString() {
    return 'Patient(id: $id, user: $user, dateOfBirth: $dateOfBirth, insuranceNumber: $insuranceNumber, insuranceType: $insuranceType, insuranceProvider: $insuranceProvider, emergencyContactName: $emergencyContactName, emergencyContactPhone: $emergencyContactPhone, allergies: $allergies, medications: $medications, notes: $notes, hasConsentForms: $hasConsentForms, lastVisit: $lastVisit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.insuranceNumber, insuranceNumber) ||
                other.insuranceNumber == insuranceNumber) &&
            (identical(other.insuranceType, insuranceType) ||
                other.insuranceType == insuranceType) &&
            (identical(other.insuranceProvider, insuranceProvider) ||
                other.insuranceProvider == insuranceProvider) &&
            (identical(other.emergencyContactName, emergencyContactName) ||
                other.emergencyContactName == emergencyContactName) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            const DeepCollectionEquality()
                .equals(other._allergies, _allergies) &&
            const DeepCollectionEquality()
                .equals(other._medications, _medications) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.hasConsentForms, hasConsentForms) ||
                other.hasConsentForms == hasConsentForms) &&
            (identical(other.lastVisit, lastVisit) ||
                other.lastVisit == lastVisit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      user,
      dateOfBirth,
      insuranceNumber,
      insuranceType,
      insuranceProvider,
      emergencyContactName,
      emergencyContactPhone,
      const DeepCollectionEquality().hash(_allergies),
      const DeepCollectionEquality().hash(_medications),
      notes,
      hasConsentForms,
      lastVisit);

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(
      this,
    );
  }
}

abstract class _Patient implements Patient {
  const factory _Patient(
      {required final String id,
      required final User user,
      required final DateTime dateOfBirth,
      final String? insuranceNumber,
      final InsuranceType? insuranceType,
      final String? insuranceProvider,
      final String? emergencyContactName,
      final String? emergencyContactPhone,
      final List<String> allergies,
      final List<String> medications,
      final String? notes,
      final bool hasConsentForms,
      final DateTime? lastVisit}) = _$PatientImpl;

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

  @override
  String get id;
  @override
  User get user;
  @override
  DateTime get dateOfBirth;
  @override
  String? get insuranceNumber;
  @override
  InsuranceType? get insuranceType;
  @override
  String? get insuranceProvider;
  @override
  String? get emergencyContactName;
  @override
  String? get emergencyContactPhone;
  @override
  List<String> get allergies;
  @override
  List<String> get medications;
  @override
  String? get notes;
  @override
  bool get hasConsentForms;
  @override
  DateTime? get lastVisit;

  /// Create a copy of Patient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
