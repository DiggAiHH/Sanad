// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'practice.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Practice _$PracticeFromJson(Map<String, dynamic> json) {
  return _Practice.fromJson(json);
}

/// @nodoc
mixin _$Practice {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get postalCode => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  List<String> get specializations => throw _privateConstructorUsedError;
  PracticeSettings get settings => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PracticeCopyWith<Practice> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PracticeCopyWith<$Res> {
  factory $PracticeCopyWith(Practice value, $Res Function(Practice) then) = _$PracticeCopyWithImpl<$Res, Practice>;
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String city,
    String postalCode,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    List<String> specializations,
    PracticeSettings settings,
    DateTime createdAt,
    DateTime? updatedAt,
  });

  $PracticeSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$PracticeCopyWithImpl<$Res, $Val extends Practice> implements $PracticeCopyWith<$Res> {
  _$PracticeCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? postalCode = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? logoUrl = freezed,
    Object? specializations = null,
    Object? settings = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      name: null == name ? _value.name : name as String,
      address: null == address ? _value.address : address as String,
      city: null == city ? _value.city : city as String,
      postalCode: null == postalCode ? _value.postalCode : postalCode as String,
      phoneNumber: freezed == phoneNumber ? _value.phoneNumber : phoneNumber as String?,
      email: freezed == email ? _value.email : email as String?,
      website: freezed == website ? _value.website : website as String?,
      logoUrl: freezed == logoUrl ? _value.logoUrl : logoUrl as String?,
      specializations: null == specializations ? _value.specializations : specializations as List<String>,
      settings: null == settings ? _value.settings : settings as PracticeSettings,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PracticeSettingsCopyWith<$Res> get settings {
    return $PracticeSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PracticeImplCopyWith<$Res> implements $PracticeCopyWith<$Res> {
  factory _$$PracticeImplCopyWith(_$PracticeImpl value, $Res Function(_$PracticeImpl) then) = __$$PracticeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String address,
    String city,
    String postalCode,
    String? phoneNumber,
    String? email,
    String? website,
    String? logoUrl,
    List<String> specializations,
    PracticeSettings settings,
    DateTime createdAt,
    DateTime? updatedAt,
  });

  @override
  $PracticeSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$PracticeImplCopyWithImpl<$Res> extends _$PracticeCopyWithImpl<$Res, _$PracticeImpl> implements _$$PracticeImplCopyWith<$Res> {
  __$$PracticeImplCopyWithImpl(_$PracticeImpl _value, $Res Function(_$PracticeImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? address = null,
    Object? city = null,
    Object? postalCode = null,
    Object? phoneNumber = freezed,
    Object? email = freezed,
    Object? website = freezed,
    Object? logoUrl = freezed,
    Object? specializations = null,
    Object? settings = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PracticeImpl(
      id: null == id ? _value.id : id as String,
      name: null == name ? _value.name : name as String,
      address: null == address ? _value.address : address as String,
      city: null == city ? _value.city : city as String,
      postalCode: null == postalCode ? _value.postalCode : postalCode as String,
      phoneNumber: freezed == phoneNumber ? _value.phoneNumber : phoneNumber as String?,
      email: freezed == email ? _value.email : email as String?,
      website: freezed == website ? _value.website : website as String?,
      logoUrl: freezed == logoUrl ? _value.logoUrl : logoUrl as String?,
      specializations: null == specializations ? _value._specializations : specializations as List<String>,
      settings: null == settings ? _value.settings : settings as PracticeSettings,
      createdAt: null == createdAt ? _value.createdAt : createdAt as DateTime,
      updatedAt: freezed == updatedAt ? _value.updatedAt : updatedAt as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PracticeImpl implements _Practice {
  const _$PracticeImpl({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    this.phoneNumber,
    this.email,
    this.website,
    this.logoUrl,
    final List<String> specializations = const [],
    required this.settings,
    required this.createdAt,
    this.updatedAt,
  }) : _specializations = specializations;

  factory _$PracticeImpl.fromJson(Map<String, dynamic> json) => _$$PracticeImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String address;
  @override
  final String city;
  @override
  final String postalCode;
  @override
  final String? phoneNumber;
  @override
  final String? email;
  @override
  final String? website;
  @override
  final String? logoUrl;
  final List<String> _specializations;
  @override
  @JsonKey()
  List<String> get specializations => List.unmodifiable(_specializations);
  @override
  final PracticeSettings settings;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Practice(id: $id, name: $name, address: $address, city: $city, postalCode: $postalCode, phoneNumber: $phoneNumber, email: $email, website: $website, logoUrl: $logoUrl, specializations: $specializations, settings: $settings, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PracticeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.postalCode, postalCode) || other.postalCode == postalCode) &&
            (identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            const DeepCollectionEquality().equals(other._specializations, _specializations) &&
            (identical(other.settings, settings) || other.settings == settings) &&
            (identical(other.createdAt, createdAt) || other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, address, city, postalCode, phoneNumber, email, website, logoUrl, const DeepCollectionEquality().hash(_specializations), settings, createdAt, updatedAt);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PracticeImplCopyWith<_$PracticeImpl> get copyWith => __$$PracticeImplCopyWithImpl<_$PracticeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PracticeImplToJson(this);
  }
}

abstract class _Practice implements Practice {
  const factory _Practice({
    required final String id,
    required final String name,
    required final String address,
    required final String city,
    required final String postalCode,
    final String? phoneNumber,
    final String? email,
    final String? website,
    final String? logoUrl,
    final List<String> specializations,
    required final PracticeSettings settings,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$PracticeImpl;

  factory _Practice.fromJson(Map<String, dynamic> json) = _$PracticeImpl.fromJson;

  @override String get id;
  @override String get name;
  @override String get address;
  @override String get city;
  @override String get postalCode;
  @override String? get phoneNumber;
  @override String? get email;
  @override String? get website;
  @override String? get logoUrl;
  @override List<String> get specializations;
  @override PracticeSettings get settings;
  @override DateTime get createdAt;
  @override DateTime? get updatedAt;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PracticeImplCopyWith<_$PracticeImpl> get copyWith => throw _privateConstructorUsedError;
}

PracticeSettings _$PracticeSettingsFromJson(Map<String, dynamic> json) {
  return _PracticeSettings.fromJson(json);
}

/// @nodoc
mixin _$PracticeSettings {
  bool get qrCodeEnabled => throw _privateConstructorUsedError;
  bool get nfcEnabled => throw _privateConstructorUsedError;
  int get defaultAppointmentDuration => throw _privateConstructorUsedError;
  String get openingTime => throw _privateConstructorUsedError;
  String get closingTime => throw _privateConstructorUsedError;
  List<int> get workingDays => throw _privateConstructorUsedError;
  String get defaultLanguage => throw _privateConstructorUsedError;
  bool get patientEducationEnabled => throw _privateConstructorUsedError;
  bool get videoContentEnabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PracticeSettingsCopyWith<PracticeSettings> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PracticeSettingsCopyWith<$Res> {
  factory $PracticeSettingsCopyWith(PracticeSettings value, $Res Function(PracticeSettings) then) = _$PracticeSettingsCopyWithImpl<$Res, PracticeSettings>;
  @useResult
  $Res call({
    bool qrCodeEnabled,
    bool nfcEnabled,
    int defaultAppointmentDuration,
    String openingTime,
    String closingTime,
    List<int> workingDays,
    String defaultLanguage,
    bool patientEducationEnabled,
    bool videoContentEnabled,
  });
}

/// @nodoc
class _$PracticeSettingsCopyWithImpl<$Res, $Val extends PracticeSettings> implements $PracticeSettingsCopyWith<$Res> {
  _$PracticeSettingsCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrCodeEnabled = null,
    Object? nfcEnabled = null,
    Object? defaultAppointmentDuration = null,
    Object? openingTime = null,
    Object? closingTime = null,
    Object? workingDays = null,
    Object? defaultLanguage = null,
    Object? patientEducationEnabled = null,
    Object? videoContentEnabled = null,
  }) {
    return _then(_value.copyWith(
      qrCodeEnabled: null == qrCodeEnabled ? _value.qrCodeEnabled : qrCodeEnabled as bool,
      nfcEnabled: null == nfcEnabled ? _value.nfcEnabled : nfcEnabled as bool,
      defaultAppointmentDuration: null == defaultAppointmentDuration ? _value.defaultAppointmentDuration : defaultAppointmentDuration as int,
      openingTime: null == openingTime ? _value.openingTime : openingTime as String,
      closingTime: null == closingTime ? _value.closingTime : closingTime as String,
      workingDays: null == workingDays ? _value.workingDays : workingDays as List<int>,
      defaultLanguage: null == defaultLanguage ? _value.defaultLanguage : defaultLanguage as String,
      patientEducationEnabled: null == patientEducationEnabled ? _value.patientEducationEnabled : patientEducationEnabled as bool,
      videoContentEnabled: null == videoContentEnabled ? _value.videoContentEnabled : videoContentEnabled as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PracticeSettingsImplCopyWith<$Res> implements $PracticeSettingsCopyWith<$Res> {
  factory _$$PracticeSettingsImplCopyWith(_$PracticeSettingsImpl value, $Res Function(_$PracticeSettingsImpl) then) = __$$PracticeSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool qrCodeEnabled,
    bool nfcEnabled,
    int defaultAppointmentDuration,
    String openingTime,
    String closingTime,
    List<int> workingDays,
    String defaultLanguage,
    bool patientEducationEnabled,
    bool videoContentEnabled,
  });
}

/// @nodoc
class __$$PracticeSettingsImplCopyWithImpl<$Res> extends _$PracticeSettingsCopyWithImpl<$Res, _$PracticeSettingsImpl> implements _$$PracticeSettingsImplCopyWith<$Res> {
  __$$PracticeSettingsImplCopyWithImpl(_$PracticeSettingsImpl _value, $Res Function(_$PracticeSettingsImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrCodeEnabled = null,
    Object? nfcEnabled = null,
    Object? defaultAppointmentDuration = null,
    Object? openingTime = null,
    Object? closingTime = null,
    Object? workingDays = null,
    Object? defaultLanguage = null,
    Object? patientEducationEnabled = null,
    Object? videoContentEnabled = null,
  }) {
    return _then(_$PracticeSettingsImpl(
      qrCodeEnabled: null == qrCodeEnabled ? _value.qrCodeEnabled : qrCodeEnabled as bool,
      nfcEnabled: null == nfcEnabled ? _value.nfcEnabled : nfcEnabled as bool,
      defaultAppointmentDuration: null == defaultAppointmentDuration ? _value.defaultAppointmentDuration : defaultAppointmentDuration as int,
      openingTime: null == openingTime ? _value.openingTime : openingTime as String,
      closingTime: null == closingTime ? _value.closingTime : closingTime as String,
      workingDays: null == workingDays ? _value._workingDays : workingDays as List<int>,
      defaultLanguage: null == defaultLanguage ? _value.defaultLanguage : defaultLanguage as String,
      patientEducationEnabled: null == patientEducationEnabled ? _value.patientEducationEnabled : patientEducationEnabled as bool,
      videoContentEnabled: null == videoContentEnabled ? _value.videoContentEnabled : videoContentEnabled as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PracticeSettingsImpl implements _PracticeSettings {
  const _$PracticeSettingsImpl({
    this.qrCodeEnabled = true,
    this.nfcEnabled = true,
    this.defaultAppointmentDuration = 30,
    this.openingTime = '08:00',
    this.closingTime = '18:00',
    final List<int> workingDays = const [1, 2, 3, 4, 5],
    this.defaultLanguage = 'de',
    this.patientEducationEnabled = true,
    this.videoContentEnabled = true,
  }) : _workingDays = workingDays;

  factory _$PracticeSettingsImpl.fromJson(Map<String, dynamic> json) => _$$PracticeSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool qrCodeEnabled;
  @override
  @JsonKey()
  final bool nfcEnabled;
  @override
  @JsonKey()
  final int defaultAppointmentDuration;
  @override
  @JsonKey()
  final String openingTime;
  @override
  @JsonKey()
  final String closingTime;
  final List<int> _workingDays;
  @override
  @JsonKey()
  List<int> get workingDays => List.unmodifiable(_workingDays);
  @override
  @JsonKey()
  final String defaultLanguage;
  @override
  @JsonKey()
  final bool patientEducationEnabled;
  @override
  @JsonKey()
  final bool videoContentEnabled;

  @override
  String toString() {
    return 'PracticeSettings(qrCodeEnabled: $qrCodeEnabled, nfcEnabled: $nfcEnabled, defaultAppointmentDuration: $defaultAppointmentDuration, openingTime: $openingTime, closingTime: $closingTime, workingDays: $workingDays, defaultLanguage: $defaultLanguage, patientEducationEnabled: $patientEducationEnabled, videoContentEnabled: $videoContentEnabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PracticeSettingsImpl &&
            (identical(other.qrCodeEnabled, qrCodeEnabled) || other.qrCodeEnabled == qrCodeEnabled) &&
            (identical(other.nfcEnabled, nfcEnabled) || other.nfcEnabled == nfcEnabled) &&
            (identical(other.defaultAppointmentDuration, defaultAppointmentDuration) || other.defaultAppointmentDuration == defaultAppointmentDuration) &&
            (identical(other.openingTime, openingTime) || other.openingTime == openingTime) &&
            (identical(other.closingTime, closingTime) || other.closingTime == closingTime) &&
            const DeepCollectionEquality().equals(other._workingDays, _workingDays) &&
            (identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage) &&
            (identical(other.patientEducationEnabled, patientEducationEnabled) || other.patientEducationEnabled == patientEducationEnabled) &&
            (identical(other.videoContentEnabled, videoContentEnabled) || other.videoContentEnabled == videoContentEnabled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, qrCodeEnabled, nfcEnabled, defaultAppointmentDuration, openingTime, closingTime, const DeepCollectionEquality().hash(_workingDays), defaultLanguage, patientEducationEnabled, videoContentEnabled);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PracticeSettingsImplCopyWith<_$PracticeSettingsImpl> get copyWith => __$$PracticeSettingsImplCopyWithImpl<_$PracticeSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PracticeSettingsImplToJson(this);
  }
}

abstract class _PracticeSettings implements PracticeSettings {
  const factory _PracticeSettings({
    final bool qrCodeEnabled,
    final bool nfcEnabled,
    final int defaultAppointmentDuration,
    final String openingTime,
    final String closingTime,
    final List<int> workingDays,
    final String defaultLanguage,
    final bool patientEducationEnabled,
    final bool videoContentEnabled,
  }) = _$PracticeSettingsImpl;

  factory _PracticeSettings.fromJson(Map<String, dynamic> json) = _$PracticeSettingsImpl.fromJson;

  @override bool get qrCodeEnabled;
  @override bool get nfcEnabled;
  @override int get defaultAppointmentDuration;
  @override String get openingTime;
  @override String get closingTime;
  @override List<int> get workingDays;
  @override String get defaultLanguage;
  @override bool get patientEducationEnabled;
  @override bool get videoContentEnabled;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PracticeSettingsImplCopyWith<_$PracticeSettingsImpl> get copyWith => throw _privateConstructorUsedError;
}
