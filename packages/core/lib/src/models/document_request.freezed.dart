// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DocumentRequest _$DocumentRequestFromJson(Map<String, dynamic> json) {
  return _DocumentRequest.fromJson(json);
}

/// @nodoc
mixin _$DocumentRequest {
  String get id => throw _privateConstructorUsedError;
  String get patientId => throw _privateConstructorUsedError;
  String get practiceId => throw _privateConstructorUsedError;
  DocumentType get documentType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DocumentRequestStatus get status => throw _privateConstructorUsedError;
  DocumentRequestPriority get priority => throw _privateConstructorUsedError;
  DeliveryMethod get deliveryMethod => throw _privateConstructorUsedError;
  String? get medicationName => throw _privateConstructorUsedError;
  String? get medicationDosage => throw _privateConstructorUsedError;
  int? get medicationQuantity => throw _privateConstructorUsedError;
  String? get referralSpecialty => throw _privateConstructorUsedError;
  String? get referralReason => throw _privateConstructorUsedError;
  String? get preferredDoctor => throw _privateConstructorUsedError;
  DateTime? get auStartDate => throw _privateConstructorUsedError;
  DateTime? get auEndDate => throw _privateConstructorUsedError;
  String? get auReason => throw _privateConstructorUsedError;
  String? get purpose => throw _privateConstructorUsedError;
  String? get additionalNotes => throw _privateConstructorUsedError;
  String? get staffNotes => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;
  String? get processedById => throw _privateConstructorUsedError;
  DateTime? get processedAt => throw _privateConstructorUsedError;
  DateTime? get readyAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentRequestCopyWith<DocumentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentRequestCopyWith<$Res> {
  factory $DocumentRequestCopyWith(
          DocumentRequest value, $Res Function(DocumentRequest) then) =
      _$DocumentRequestCopyWithImpl<$Res, DocumentRequest>;
  @useResult
  $Res call({
    String id,
    String patientId,
    String practiceId,
    DocumentType documentType,
    String title,
    String? description,
    DocumentRequestStatus status,
    DocumentRequestPriority priority,
    DeliveryMethod deliveryMethod,
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    String? purpose,
    String? additionalNotes,
    String? staffNotes,
    String? rejectionReason,
    String? processedById,
    DateTime? processedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$DocumentRequestCopyWithImpl<$Res, $Val extends DocumentRequest>
    implements $DocumentRequestCopyWith<$Res> {
  _$DocumentRequestCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? documentType = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? priority = null,
    Object? deliveryMethod = null,
    Object? medicationName = freezed,
    Object? medicationDosage = freezed,
    Object? medicationQuantity = freezed,
    Object? referralSpecialty = freezed,
    Object? referralReason = freezed,
    Object? preferredDoctor = freezed,
    Object? auStartDate = freezed,
    Object? auEndDate = freezed,
    Object? auReason = freezed,
    Object? purpose = freezed,
    Object? additionalNotes = freezed,
    Object? staffNotes = freezed,
    Object? rejectionReason = freezed,
    Object? processedById = freezed,
    Object? processedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId as String,
      practiceId: null == practiceId
          ? _value.practiceId
          : practiceId as String,
      documentType: null == documentType
          ? _value.documentType
          : documentType as DocumentType,
      title: null == title
          ? _value.title
          : title as String,
      description: freezed == description
          ? _value.description
          : description as String?,
      status: null == status
          ? _value.status
          : status as DocumentRequestStatus,
      priority: null == priority
          ? _value.priority
          : priority as DocumentRequestPriority,
      deliveryMethod: null == deliveryMethod
          ? _value.deliveryMethod
          : deliveryMethod as DeliveryMethod,
      medicationName: freezed == medicationName
          ? _value.medicationName
          : medicationName as String?,
      medicationDosage: freezed == medicationDosage
          ? _value.medicationDosage
          : medicationDosage as String?,
      medicationQuantity: freezed == medicationQuantity
          ? _value.medicationQuantity
          : medicationQuantity as int?,
      referralSpecialty: freezed == referralSpecialty
          ? _value.referralSpecialty
          : referralSpecialty as String?,
      referralReason: freezed == referralReason
          ? _value.referralReason
          : referralReason as String?,
      preferredDoctor: freezed == preferredDoctor
          ? _value.preferredDoctor
          : preferredDoctor as String?,
      auStartDate: freezed == auStartDate
          ? _value.auStartDate
          : auStartDate as DateTime?,
      auEndDate: freezed == auEndDate
          ? _value.auEndDate
          : auEndDate as DateTime?,
      auReason: freezed == auReason
          ? _value.auReason
          : auReason as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose as String?,
      additionalNotes: freezed == additionalNotes
          ? _value.additionalNotes
          : additionalNotes as String?,
      staffNotes: freezed == staffNotes
          ? _value.staffNotes
          : staffNotes as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason as String?,
      processedById: freezed == processedById
          ? _value.processedById
          : processedById as String?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt as DateTime?,
      readyAt: freezed == readyAt
          ? _value.readyAt
          : readyAt as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentRequestImplCopyWith<$Res>
    implements $DocumentRequestCopyWith<$Res> {
  factory _$$DocumentRequestImplCopyWith(_$DocumentRequestImpl value,
          $Res Function(_$DocumentRequestImpl) then) =
      __$$DocumentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String patientId,
    String practiceId,
    DocumentType documentType,
    String title,
    String? description,
    DocumentRequestStatus status,
    DocumentRequestPriority priority,
    DeliveryMethod deliveryMethod,
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    String? purpose,
    String? additionalNotes,
    String? staffNotes,
    String? rejectionReason,
    String? processedById,
    DateTime? processedAt,
    DateTime? readyAt,
    DateTime? deliveredAt,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DocumentRequestImplCopyWithImpl<$Res>
    extends _$DocumentRequestCopyWithImpl<$Res, _$DocumentRequestImpl>
    implements _$$DocumentRequestImplCopyWith<$Res> {
  __$$DocumentRequestImplCopyWithImpl(
      _$DocumentRequestImpl _value, $Res Function(_$DocumentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? practiceId = null,
    Object? documentType = null,
    Object? title = null,
    Object? description = freezed,
    Object? status = null,
    Object? priority = null,
    Object? deliveryMethod = null,
    Object? medicationName = freezed,
    Object? medicationDosage = freezed,
    Object? medicationQuantity = freezed,
    Object? referralSpecialty = freezed,
    Object? referralReason = freezed,
    Object? preferredDoctor = freezed,
    Object? auStartDate = freezed,
    Object? auEndDate = freezed,
    Object? auReason = freezed,
    Object? purpose = freezed,
    Object? additionalNotes = freezed,
    Object? staffNotes = freezed,
    Object? rejectionReason = freezed,
    Object? processedById = freezed,
    Object? processedAt = freezed,
    Object? readyAt = freezed,
    Object? deliveredAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$DocumentRequestImpl(
      id: null == id
          ? _value.id
          : id as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId as String,
      practiceId: null == practiceId
          ? _value.practiceId
          : practiceId as String,
      documentType: null == documentType
          ? _value.documentType
          : documentType as DocumentType,
      title: null == title
          ? _value.title
          : title as String,
      description: freezed == description
          ? _value.description
          : description as String?,
      status: null == status
          ? _value.status
          : status as DocumentRequestStatus,
      priority: null == priority
          ? _value.priority
          : priority as DocumentRequestPriority,
      deliveryMethod: null == deliveryMethod
          ? _value.deliveryMethod
          : deliveryMethod as DeliveryMethod,
      medicationName: freezed == medicationName
          ? _value.medicationName
          : medicationName as String?,
      medicationDosage: freezed == medicationDosage
          ? _value.medicationDosage
          : medicationDosage as String?,
      medicationQuantity: freezed == medicationQuantity
          ? _value.medicationQuantity
          : medicationQuantity as int?,
      referralSpecialty: freezed == referralSpecialty
          ? _value.referralSpecialty
          : referralSpecialty as String?,
      referralReason: freezed == referralReason
          ? _value.referralReason
          : referralReason as String?,
      preferredDoctor: freezed == preferredDoctor
          ? _value.preferredDoctor
          : preferredDoctor as String?,
      auStartDate: freezed == auStartDate
          ? _value.auStartDate
          : auStartDate as DateTime?,
      auEndDate: freezed == auEndDate
          ? _value.auEndDate
          : auEndDate as DateTime?,
      auReason: freezed == auReason
          ? _value.auReason
          : auReason as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose as String?,
      additionalNotes: freezed == additionalNotes
          ? _value.additionalNotes
          : additionalNotes as String?,
      staffNotes: freezed == staffNotes
          ? _value.staffNotes
          : staffNotes as String?,
      rejectionReason: freezed == rejectionReason
          ? _value.rejectionReason
          : rejectionReason as String?,
      processedById: freezed == processedById
          ? _value.processedById
          : processedById as String?,
      processedAt: freezed == processedAt
          ? _value.processedAt
          : processedAt as DateTime?,
      readyAt: freezed == readyAt
          ? _value.readyAt
          : readyAt as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentRequestImpl implements _DocumentRequest {
  const _$DocumentRequestImpl({
    required this.id,
    required this.patientId,
    required this.practiceId,
    required this.documentType,
    required this.title,
    this.description,
    required this.status,
    this.priority = DocumentRequestPriority.normal,
    this.deliveryMethod = DeliveryMethod.pickup,
    this.medicationName,
    this.medicationDosage,
    this.medicationQuantity,
    this.referralSpecialty,
    this.referralReason,
    this.preferredDoctor,
    this.auStartDate,
    this.auEndDate,
    this.auReason,
    this.purpose,
    this.additionalNotes,
    this.staffNotes,
    this.rejectionReason,
    this.processedById,
    this.processedAt,
    this.readyAt,
    this.deliveredAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory _$DocumentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentRequestImplFromJson(json);

  @override
  final String id;
  @override
  final String patientId;
  @override
  final String practiceId;
  @override
  final DocumentType documentType;
  @override
  final String title;
  @override
  final String? description;
  @override
  final DocumentRequestStatus status;
  @override
  @JsonKey()
  final DocumentRequestPriority priority;
  @override
  @JsonKey()
  final DeliveryMethod deliveryMethod;
  @override
  final String? medicationName;
  @override
  final String? medicationDosage;
  @override
  final int? medicationQuantity;
  @override
  final String? referralSpecialty;
  @override
  final String? referralReason;
  @override
  final String? preferredDoctor;
  @override
  final DateTime? auStartDate;
  @override
  final DateTime? auEndDate;
  @override
  final String? auReason;
  @override
  final String? purpose;
  @override
  final String? additionalNotes;
  @override
  final String? staffNotes;
  @override
  final String? rejectionReason;
  @override
  final String? processedById;
  @override
  final DateTime? processedAt;
  @override
  final DateTime? readyAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DocumentRequest(id: $id, patientId: $patientId, practiceId: $practiceId, documentType: $documentType, title: $title, description: $description, status: $status, priority: $priority, deliveryMethod: $deliveryMethod, medicationName: $medicationName, medicationDosage: $medicationDosage, medicationQuantity: $medicationQuantity, referralSpecialty: $referralSpecialty, referralReason: $referralReason, preferredDoctor: $preferredDoctor, auStartDate: $auStartDate, auEndDate: $auEndDate, auReason: $auReason, purpose: $purpose, additionalNotes: $additionalNotes, staffNotes: $staffNotes, rejectionReason: $rejectionReason, processedById: $processedById, processedAt: $processedAt, readyAt: $readyAt, deliveredAt: $deliveredAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentRequestImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.practiceId, practiceId) ||
                other.practiceId == practiceId) &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.deliveryMethod, deliveryMethod) ||
                other.deliveryMethod == deliveryMethod) &&
            (identical(other.medicationName, medicationName) ||
                other.medicationName == medicationName) &&
            (identical(other.medicationDosage, medicationDosage) ||
                other.medicationDosage == medicationDosage) &&
            (identical(other.medicationQuantity, medicationQuantity) ||
                other.medicationQuantity == medicationQuantity) &&
            (identical(other.referralSpecialty, referralSpecialty) ||
                other.referralSpecialty == referralSpecialty) &&
            (identical(other.referralReason, referralReason) ||
                other.referralReason == referralReason) &&
            (identical(other.preferredDoctor, preferredDoctor) ||
                other.preferredDoctor == preferredDoctor) &&
            (identical(other.auStartDate, auStartDate) ||
                other.auStartDate == auStartDate) &&
            (identical(other.auEndDate, auEndDate) ||
                other.auEndDate == auEndDate) &&
            (identical(other.auReason, auReason) ||
                other.auReason == auReason) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.additionalNotes, additionalNotes) ||
                other.additionalNotes == additionalNotes) &&
            (identical(other.staffNotes, staffNotes) ||
                other.staffNotes == staffNotes) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.processedById, processedById) ||
                other.processedById == processedById) &&
            (identical(other.processedAt, processedAt) ||
                other.processedAt == processedAt) &&
            (identical(other.readyAt, readyAt) || other.readyAt == readyAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        patientId,
        practiceId,
        documentType,
        title,
        description,
        status,
        priority,
        deliveryMethod,
        medicationName,
        medicationDosage,
        medicationQuantity,
        referralSpecialty,
        referralReason,
        preferredDoctor,
        auStartDate,
        auEndDate,
        auReason,
        purpose,
        additionalNotes,
        staffNotes,
        rejectionReason,
        processedById,
        processedAt,
        readyAt,
        deliveredAt,
        createdAt,
        updatedAt,
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentRequestImplCopyWith<_$DocumentRequestImpl> get copyWith =>
      __$$DocumentRequestImplCopyWithImpl<_$DocumentRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentRequestImplToJson(this);
  }
}

abstract class _DocumentRequest implements DocumentRequest {
  const factory _DocumentRequest({
    required final String id,
    required final String patientId,
    required final String practiceId,
    required final DocumentType documentType,
    required final String title,
    final String? description,
    required final DocumentRequestStatus status,
    final DocumentRequestPriority priority,
    final DeliveryMethod deliveryMethod,
    final String? medicationName,
    final String? medicationDosage,
    final int? medicationQuantity,
    final String? referralSpecialty,
    final String? referralReason,
    final String? preferredDoctor,
    final DateTime? auStartDate,
    final DateTime? auEndDate,
    final String? auReason,
    final String? purpose,
    final String? additionalNotes,
    final String? staffNotes,
    final String? rejectionReason,
    final String? processedById,
    final DateTime? processedAt,
    final DateTime? readyAt,
    final DateTime? deliveredAt,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$DocumentRequestImpl;

  factory _DocumentRequest.fromJson(Map<String, dynamic> json) =
      _$DocumentRequestImpl.fromJson;

  @override
  String get id;
  @override
  String get patientId;
  @override
  String get practiceId;
  @override
  DocumentType get documentType;
  @override
  String get title;
  @override
  String? get description;
  @override
  DocumentRequestStatus get status;
  @override
  DocumentRequestPriority get priority;
  @override
  DeliveryMethod get deliveryMethod;
  @override
  String? get medicationName;
  @override
  String? get medicationDosage;
  @override
  int? get medicationQuantity;
  @override
  String? get referralSpecialty;
  @override
  String? get referralReason;
  @override
  String? get preferredDoctor;
  @override
  DateTime? get auStartDate;
  @override
  DateTime? get auEndDate;
  @override
  String? get auReason;
  @override
  String? get purpose;
  @override
  String? get additionalNotes;
  @override
  String? get staffNotes;
  @override
  String? get rejectionReason;
  @override
  String? get processedById;
  @override
  DateTime? get processedAt;
  @override
  DateTime? get readyAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$DocumentRequestImplCopyWith<_$DocumentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DocumentRequestCreate _$DocumentRequestCreateFromJson(
    Map<String, dynamic> json) {
  return _DocumentRequestCreate.fromJson(json);
}

/// @nodoc
mixin _$DocumentRequestCreate {
  DocumentType get documentType => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  DocumentRequestPriority get priority => throw _privateConstructorUsedError;
  DeliveryMethod get deliveryMethod => throw _privateConstructorUsedError;
  String? get medicationName => throw _privateConstructorUsedError;
  String? get medicationDosage => throw _privateConstructorUsedError;
  int? get medicationQuantity => throw _privateConstructorUsedError;
  String? get referralSpecialty => throw _privateConstructorUsedError;
  String? get referralReason => throw _privateConstructorUsedError;
  String? get preferredDoctor => throw _privateConstructorUsedError;
  DateTime? get auStartDate => throw _privateConstructorUsedError;
  DateTime? get auEndDate => throw _privateConstructorUsedError;
  String? get auReason => throw _privateConstructorUsedError;
  String? get purpose => throw _privateConstructorUsedError;
  String? get additionalNotes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DocumentRequestCreateCopyWith<DocumentRequestCreate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DocumentRequestCreateCopyWith<$Res> {
  factory $DocumentRequestCreateCopyWith(DocumentRequestCreate value,
          $Res Function(DocumentRequestCreate) then) =
      _$DocumentRequestCreateCopyWithImpl<$Res, DocumentRequestCreate>;
  @useResult
  $Res call({
    DocumentType documentType,
    String title,
    String? description,
    DocumentRequestPriority priority,
    DeliveryMethod deliveryMethod,
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    String? purpose,
    String? additionalNotes,
  });
}

/// @nodoc
class _$DocumentRequestCreateCopyWithImpl<$Res,
        $Val extends DocumentRequestCreate>
    implements $DocumentRequestCreateCopyWith<$Res> {
  _$DocumentRequestCreateCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentType = null,
    Object? title = null,
    Object? description = freezed,
    Object? priority = null,
    Object? deliveryMethod = null,
    Object? medicationName = freezed,
    Object? medicationDosage = freezed,
    Object? medicationQuantity = freezed,
    Object? referralSpecialty = freezed,
    Object? referralReason = freezed,
    Object? preferredDoctor = freezed,
    Object? auStartDate = freezed,
    Object? auEndDate = freezed,
    Object? auReason = freezed,
    Object? purpose = freezed,
    Object? additionalNotes = freezed,
  }) {
    return _then(_value.copyWith(
      documentType: null == documentType
          ? _value.documentType
          : documentType as DocumentType,
      title: null == title
          ? _value.title
          : title as String,
      description: freezed == description
          ? _value.description
          : description as String?,
      priority: null == priority
          ? _value.priority
          : priority as DocumentRequestPriority,
      deliveryMethod: null == deliveryMethod
          ? _value.deliveryMethod
          : deliveryMethod as DeliveryMethod,
      medicationName: freezed == medicationName
          ? _value.medicationName
          : medicationName as String?,
      medicationDosage: freezed == medicationDosage
          ? _value.medicationDosage
          : medicationDosage as String?,
      medicationQuantity: freezed == medicationQuantity
          ? _value.medicationQuantity
          : medicationQuantity as int?,
      referralSpecialty: freezed == referralSpecialty
          ? _value.referralSpecialty
          : referralSpecialty as String?,
      referralReason: freezed == referralReason
          ? _value.referralReason
          : referralReason as String?,
      preferredDoctor: freezed == preferredDoctor
          ? _value.preferredDoctor
          : preferredDoctor as String?,
      auStartDate: freezed == auStartDate
          ? _value.auStartDate
          : auStartDate as DateTime?,
      auEndDate: freezed == auEndDate
          ? _value.auEndDate
          : auEndDate as DateTime?,
      auReason: freezed == auReason
          ? _value.auReason
          : auReason as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose as String?,
      additionalNotes: freezed == additionalNotes
          ? _value.additionalNotes
          : additionalNotes as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DocumentRequestCreateImplCopyWith<$Res>
    implements $DocumentRequestCreateCopyWith<$Res> {
  factory _$$DocumentRequestCreateImplCopyWith(
          _$DocumentRequestCreateImpl value,
          $Res Function(_$DocumentRequestCreateImpl) then) =
      __$$DocumentRequestCreateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DocumentType documentType,
    String title,
    String? description,
    DocumentRequestPriority priority,
    DeliveryMethod deliveryMethod,
    String? medicationName,
    String? medicationDosage,
    int? medicationQuantity,
    String? referralSpecialty,
    String? referralReason,
    String? preferredDoctor,
    DateTime? auStartDate,
    DateTime? auEndDate,
    String? auReason,
    String? purpose,
    String? additionalNotes,
  });
}

/// @nodoc
class __$$DocumentRequestCreateImplCopyWithImpl<$Res>
    extends _$DocumentRequestCreateCopyWithImpl<$Res,
        _$DocumentRequestCreateImpl>
    implements _$$DocumentRequestCreateImplCopyWith<$Res> {
  __$$DocumentRequestCreateImplCopyWithImpl(_$DocumentRequestCreateImpl _value,
      $Res Function(_$DocumentRequestCreateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? documentType = null,
    Object? title = null,
    Object? description = freezed,
    Object? priority = null,
    Object? deliveryMethod = null,
    Object? medicationName = freezed,
    Object? medicationDosage = freezed,
    Object? medicationQuantity = freezed,
    Object? referralSpecialty = freezed,
    Object? referralReason = freezed,
    Object? preferredDoctor = freezed,
    Object? auStartDate = freezed,
    Object? auEndDate = freezed,
    Object? auReason = freezed,
    Object? purpose = freezed,
    Object? additionalNotes = freezed,
  }) {
    return _then(_$DocumentRequestCreateImpl(
      documentType: null == documentType
          ? _value.documentType
          : documentType as DocumentType,
      title: null == title
          ? _value.title
          : title as String,
      description: freezed == description
          ? _value.description
          : description as String?,
      priority: null == priority
          ? _value.priority
          : priority as DocumentRequestPriority,
      deliveryMethod: null == deliveryMethod
          ? _value.deliveryMethod
          : deliveryMethod as DeliveryMethod,
      medicationName: freezed == medicationName
          ? _value.medicationName
          : medicationName as String?,
      medicationDosage: freezed == medicationDosage
          ? _value.medicationDosage
          : medicationDosage as String?,
      medicationQuantity: freezed == medicationQuantity
          ? _value.medicationQuantity
          : medicationQuantity as int?,
      referralSpecialty: freezed == referralSpecialty
          ? _value.referralSpecialty
          : referralSpecialty as String?,
      referralReason: freezed == referralReason
          ? _value.referralReason
          : referralReason as String?,
      preferredDoctor: freezed == preferredDoctor
          ? _value.preferredDoctor
          : preferredDoctor as String?,
      auStartDate: freezed == auStartDate
          ? _value.auStartDate
          : auStartDate as DateTime?,
      auEndDate: freezed == auEndDate
          ? _value.auEndDate
          : auEndDate as DateTime?,
      auReason: freezed == auReason
          ? _value.auReason
          : auReason as String?,
      purpose: freezed == purpose
          ? _value.purpose
          : purpose as String?,
      additionalNotes: freezed == additionalNotes
          ? _value.additionalNotes
          : additionalNotes as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DocumentRequestCreateImpl implements _DocumentRequestCreate {
  const _$DocumentRequestCreateImpl({
    required this.documentType,
    required this.title,
    this.description,
    this.priority = DocumentRequestPriority.normal,
    this.deliveryMethod = DeliveryMethod.pickup,
    this.medicationName,
    this.medicationDosage,
    this.medicationQuantity,
    this.referralSpecialty,
    this.referralReason,
    this.preferredDoctor,
    this.auStartDate,
    this.auEndDate,
    this.auReason,
    this.purpose,
    this.additionalNotes,
  });

  factory _$DocumentRequestCreateImpl.fromJson(Map<String, dynamic> json) =>
      _$$DocumentRequestCreateImplFromJson(json);

  @override
  final DocumentType documentType;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey()
  final DocumentRequestPriority priority;
  @override
  @JsonKey()
  final DeliveryMethod deliveryMethod;
  @override
  final String? medicationName;
  @override
  final String? medicationDosage;
  @override
  final int? medicationQuantity;
  @override
  final String? referralSpecialty;
  @override
  final String? referralReason;
  @override
  final String? preferredDoctor;
  @override
  final DateTime? auStartDate;
  @override
  final DateTime? auEndDate;
  @override
  final String? auReason;
  @override
  final String? purpose;
  @override
  final String? additionalNotes;

  @override
  String toString() {
    return 'DocumentRequestCreate(documentType: $documentType, title: $title, description: $description, priority: $priority, deliveryMethod: $deliveryMethod, medicationName: $medicationName, medicationDosage: $medicationDosage, medicationQuantity: $medicationQuantity, referralSpecialty: $referralSpecialty, referralReason: $referralReason, preferredDoctor: $preferredDoctor, auStartDate: $auStartDate, auEndDate: $auEndDate, auReason: $auReason, purpose: $purpose, additionalNotes: $additionalNotes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DocumentRequestCreateImpl &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.deliveryMethod, deliveryMethod) ||
                other.deliveryMethod == deliveryMethod) &&
            (identical(other.medicationName, medicationName) ||
                other.medicationName == medicationName) &&
            (identical(other.medicationDosage, medicationDosage) ||
                other.medicationDosage == medicationDosage) &&
            (identical(other.medicationQuantity, medicationQuantity) ||
                other.medicationQuantity == medicationQuantity) &&
            (identical(other.referralSpecialty, referralSpecialty) ||
                other.referralSpecialty == referralSpecialty) &&
            (identical(other.referralReason, referralReason) ||
                other.referralReason == referralReason) &&
            (identical(other.preferredDoctor, preferredDoctor) ||
                other.preferredDoctor == preferredDoctor) &&
            (identical(other.auStartDate, auStartDate) ||
                other.auStartDate == auStartDate) &&
            (identical(other.auEndDate, auEndDate) ||
                other.auEndDate == auEndDate) &&
            (identical(other.auReason, auReason) ||
                other.auReason == auReason) &&
            (identical(other.purpose, purpose) || other.purpose == purpose) &&
            (identical(other.additionalNotes, additionalNotes) ||
                other.additionalNotes == additionalNotes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
        runtimeType,
        documentType,
        title,
        description,
        priority,
        deliveryMethod,
        medicationName,
        medicationDosage,
        medicationQuantity,
        referralSpecialty,
        referralReason,
        preferredDoctor,
        auStartDate,
        auEndDate,
        auReason,
        purpose,
        additionalNotes,
      );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DocumentRequestCreateImplCopyWith<_$DocumentRequestCreateImpl>
      get copyWith => __$$DocumentRequestCreateImplCopyWithImpl<
          _$DocumentRequestCreateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DocumentRequestCreateImplToJson(this);
  }
}

abstract class _DocumentRequestCreate implements DocumentRequestCreate {
  const factory _DocumentRequestCreate({
    required final DocumentType documentType,
    required final String title,
    final String? description,
    final DocumentRequestPriority priority,
    final DeliveryMethod deliveryMethod,
    final String? medicationName,
    final String? medicationDosage,
    final int? medicationQuantity,
    final String? referralSpecialty,
    final String? referralReason,
    final String? preferredDoctor,
    final DateTime? auStartDate,
    final DateTime? auEndDate,
    final String? auReason,
    final String? purpose,
    final String? additionalNotes,
  }) = _$DocumentRequestCreateImpl;

  factory _DocumentRequestCreate.fromJson(Map<String, dynamic> json) =
      _$DocumentRequestCreateImpl.fromJson;

  @override
  DocumentType get documentType;
  @override
  String get title;
  @override
  String? get description;
  @override
  DocumentRequestPriority get priority;
  @override
  DeliveryMethod get deliveryMethod;
  @override
  String? get medicationName;
  @override
  String? get medicationDosage;
  @override
  int? get medicationQuantity;
  @override
  String? get referralSpecialty;
  @override
  String? get referralReason;
  @override
  String? get preferredDoctor;
  @override
  DateTime? get auStartDate;
  @override
  DateTime? get auEndDate;
  @override
  String? get auReason;
  @override
  String? get purpose;
  @override
  String? get additionalNotes;
  @override
  @JsonKey(ignore: true)
  _$$DocumentRequestCreateImplCopyWith<_$DocumentRequestCreateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
