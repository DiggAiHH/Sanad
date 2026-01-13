// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QueueCategory _$QueueCategoryFromJson(Map<String, dynamic> json) {
  return _QueueCategory.fromJson(json);
}

/// @nodoc
mixin _$QueueCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get prefix => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get currentNumber => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueueCategoryCopyWith<QueueCategory> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueCategoryCopyWith<$Res> {
  factory $QueueCategoryCopyWith(QueueCategory value, $Res Function(QueueCategory) then) =
      _$QueueCategoryCopyWithImpl<$Res, QueueCategory>;
  @useResult
  $Res call({String id, String name, String prefix, String? description, int currentNumber, bool isActive, String color});
}

/// @nodoc
class _$QueueCategoryCopyWithImpl<$Res, $Val extends QueueCategory> implements $QueueCategoryCopyWith<$Res> {
  _$QueueCategoryCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? prefix = null,
    Object? description = freezed,
    Object? currentNumber = null,
    Object? isActive = null,
    Object? color = null,
  }) {
    return _then(_value.copyWith(
      id: null == id ? _value.id : id as String,
      name: null == name ? _value.name : name as String,
      prefix: null == prefix ? _value.prefix : prefix as String,
      description: freezed == description ? _value.description : description as String?,
      currentNumber: null == currentNumber ? _value.currentNumber : currentNumber as int,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      color: null == color ? _value.color : color as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueCategoryImplCopyWith<$Res> implements $QueueCategoryCopyWith<$Res> {
  factory _$$QueueCategoryImplCopyWith(_$QueueCategoryImpl value, $Res Function(_$QueueCategoryImpl) then) =
      __$$QueueCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String prefix, String? description, int currentNumber, bool isActive, String color});
}

/// @nodoc
class __$$QueueCategoryImplCopyWithImpl<$Res> extends _$QueueCategoryCopyWithImpl<$Res, _$QueueCategoryImpl>
    implements _$$QueueCategoryImplCopyWith<$Res> {
  __$$QueueCategoryImplCopyWithImpl(_$QueueCategoryImpl _value, $Res Function(_$QueueCategoryImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? prefix = null,
    Object? description = freezed,
    Object? currentNumber = null,
    Object? isActive = null,
    Object? color = null,
  }) {
    return _then(_$QueueCategoryImpl(
      id: null == id ? _value.id : id as String,
      name: null == name ? _value.name : name as String,
      prefix: null == prefix ? _value.prefix : prefix as String,
      description: freezed == description ? _value.description : description as String?,
      currentNumber: null == currentNumber ? _value.currentNumber : currentNumber as int,
      isActive: null == isActive ? _value.isActive : isActive as bool,
      color: null == color ? _value.color : color as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueCategoryImpl implements _QueueCategory {
  const _$QueueCategoryImpl({
    required this.id,
    required this.name,
    required this.prefix,
    this.description,
    this.currentNumber = 0,
    this.isActive = true,
    this.color = '#2196F3',
  });

  factory _$QueueCategoryImpl.fromJson(Map<String, dynamic> json) => _$$QueueCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String prefix;
  @override
  final String? description;
  @override
  @JsonKey()
  final int currentNumber;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String color;

  @override
  String toString() {
    return 'QueueCategory(id: $id, name: $name, prefix: $prefix, description: $description, currentNumber: $currentNumber, isActive: $isActive, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.prefix, prefix) || other.prefix == prefix) &&
            (identical(other.description, description) || other.description == description) &&
            (identical(other.currentNumber, currentNumber) || other.currentNumber == currentNumber) &&
            (identical(other.isActive, isActive) || other.isActive == isActive) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, prefix, description, currentNumber, isActive, color);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueCategoryImplCopyWith<_$QueueCategoryImpl> get copyWith =>
      __$$QueueCategoryImplCopyWithImpl<_$QueueCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueCategoryImplToJson(this);
  }
}

abstract class _QueueCategory implements QueueCategory {
  const factory _QueueCategory({
    required final String id,
    required final String name,
    required final String prefix,
    final String? description,
    final int currentNumber,
    final bool isActive,
    final String color,
  }) = _$QueueCategoryImpl;

  factory _QueueCategory.fromJson(Map<String, dynamic> json) = _$QueueCategoryImpl.fromJson;

  @override String get id;
  @override String get name;
  @override String get prefix;
  @override String? get description;
  @override int get currentNumber;
  @override bool get isActive;
  @override String get color;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueueCategoryImplCopyWith<_$QueueCategoryImpl> get copyWith => throw _privateConstructorUsedError;
}

QueueState _$QueueStateFromJson(Map<String, dynamic> json) {
  return _QueueState.fromJson(json);
}

/// @nodoc
mixin _$QueueState {
  String get practiceId => throw _privateConstructorUsedError;
  List<QueueCategory> get categories => throw _privateConstructorUsedError;
  List<Ticket> get activeTickets => throw _privateConstructorUsedError;
  int get totalWaiting => throw _privateConstructorUsedError;
  int get totalInProgress => throw _privateConstructorUsedError;
  int? get averageWaitMinutes => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueueStateCopyWith<QueueState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueueStateCopyWith<$Res> {
  factory $QueueStateCopyWith(QueueState value, $Res Function(QueueState) then) =
      _$QueueStateCopyWithImpl<$Res, QueueState>;
  @useResult
  $Res call({
    String practiceId,
    List<QueueCategory> categories,
    List<Ticket> activeTickets,
    int totalWaiting,
    int totalInProgress,
    int? averageWaitMinutes,
    DateTime lastUpdated,
  });
}

/// @nodoc
class _$QueueStateCopyWithImpl<$Res, $Val extends QueueState> implements $QueueStateCopyWith<$Res> {
  _$QueueStateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? practiceId = null,
    Object? categories = null,
    Object? activeTickets = null,
    Object? totalWaiting = null,
    Object? totalInProgress = null,
    Object? averageWaitMinutes = freezed,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      categories: null == categories ? _value.categories : categories as List<QueueCategory>,
      activeTickets: null == activeTickets ? _value.activeTickets : activeTickets as List<Ticket>,
      totalWaiting: null == totalWaiting ? _value.totalWaiting : totalWaiting as int,
      totalInProgress: null == totalInProgress ? _value.totalInProgress : totalInProgress as int,
      averageWaitMinutes: freezed == averageWaitMinutes ? _value.averageWaitMinutes : averageWaitMinutes as int?,
      lastUpdated: null == lastUpdated ? _value.lastUpdated : lastUpdated as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QueueStateImplCopyWith<$Res> implements $QueueStateCopyWith<$Res> {
  factory _$$QueueStateImplCopyWith(_$QueueStateImpl value, $Res Function(_$QueueStateImpl) then) =
      __$$QueueStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String practiceId,
    List<QueueCategory> categories,
    List<Ticket> activeTickets,
    int totalWaiting,
    int totalInProgress,
    int? averageWaitMinutes,
    DateTime lastUpdated,
  });
}

/// @nodoc
class __$$QueueStateImplCopyWithImpl<$Res> extends _$QueueStateCopyWithImpl<$Res, _$QueueStateImpl>
    implements _$$QueueStateImplCopyWith<$Res> {
  __$$QueueStateImplCopyWithImpl(_$QueueStateImpl _value, $Res Function(_$QueueStateImpl) _then) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? practiceId = null,
    Object? categories = null,
    Object? activeTickets = null,
    Object? totalWaiting = null,
    Object? totalInProgress = null,
    Object? averageWaitMinutes = freezed,
    Object? lastUpdated = null,
  }) {
    return _then(_$QueueStateImpl(
      practiceId: null == practiceId ? _value.practiceId : practiceId as String,
      categories: null == categories ? _value._categories : categories as List<QueueCategory>,
      activeTickets: null == activeTickets ? _value._activeTickets : activeTickets as List<Ticket>,
      totalWaiting: null == totalWaiting ? _value.totalWaiting : totalWaiting as int,
      totalInProgress: null == totalInProgress ? _value.totalInProgress : totalInProgress as int,
      averageWaitMinutes: freezed == averageWaitMinutes ? _value.averageWaitMinutes : averageWaitMinutes as int?,
      lastUpdated: null == lastUpdated ? _value.lastUpdated : lastUpdated as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QueueStateImpl implements _QueueState {
  const _$QueueStateImpl({
    required this.practiceId,
    required final List<QueueCategory> categories,
    required final List<Ticket> activeTickets,
    required this.totalWaiting,
    required this.totalInProgress,
    this.averageWaitMinutes,
    required this.lastUpdated,
  })  : _categories = categories,
        _activeTickets = activeTickets;

  factory _$QueueStateImpl.fromJson(Map<String, dynamic> json) => _$$QueueStateImplFromJson(json);

  @override
  final String practiceId;
  final List<QueueCategory> _categories;
  @override
  List<QueueCategory> get categories {
    return List.unmodifiable(_categories);
  }

  final List<Ticket> _activeTickets;
  @override
  List<Ticket> get activeTickets {
    return List.unmodifiable(_activeTickets);
  }

  @override
  final int totalWaiting;
  @override
  final int totalInProgress;
  @override
  final int? averageWaitMinutes;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'QueueState(practiceId: $practiceId, categories: $categories, activeTickets: $activeTickets, totalWaiting: $totalWaiting, totalInProgress: $totalInProgress, averageWaitMinutes: $averageWaitMinutes, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueueStateImpl &&
            (identical(other.practiceId, practiceId) || other.practiceId == practiceId) &&
            const DeepCollectionEquality().equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._activeTickets, _activeTickets) &&
            (identical(other.totalWaiting, totalWaiting) || other.totalWaiting == totalWaiting) &&
            (identical(other.totalInProgress, totalInProgress) || other.totalInProgress == totalInProgress) &&
            (identical(other.averageWaitMinutes, averageWaitMinutes) || other.averageWaitMinutes == averageWaitMinutes) &&
            (identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      practiceId,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_activeTickets),
      totalWaiting,
      totalInProgress,
      averageWaitMinutes,
      lastUpdated);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueueStateImplCopyWith<_$QueueStateImpl> get copyWith =>
      __$$QueueStateImplCopyWithImpl<_$QueueStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QueueStateImplToJson(this);
  }
}

abstract class _QueueState implements QueueState {
  const factory _QueueState({
    required final String practiceId,
    required final List<QueueCategory> categories,
    required final List<Ticket> activeTickets,
    required final int totalWaiting,
    required final int totalInProgress,
    final int? averageWaitMinutes,
    required final DateTime lastUpdated,
  }) = _$QueueStateImpl;

  factory _QueueState.fromJson(Map<String, dynamic> json) = _$QueueStateImpl.fromJson;

  @override String get practiceId;
  @override List<QueueCategory> get categories;
  @override List<Ticket> get activeTickets;
  @override int get totalWaiting;
  @override int get totalInProgress;
  @override int? get averageWaitMinutes;
  @override DateTime get lastUpdated;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueueStateImplCopyWith<_$QueueStateImpl> get copyWith => throw _privateConstructorUsedError;
}
