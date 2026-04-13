/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'crdt_operation_type.dart' as _i2;

abstract class DocumentCrdtOperation implements _i1.SerializableModel {
  DocumentCrdtOperation._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.hlc,
    required this.nodeId,
    required this.operationType,
    required this.fieldPath,
    this.fieldValue,
    DateTime? createdAt,
    this.createdByUserId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtOperation({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) = _DocumentCrdtOperationImpl;

  factory DocumentCrdtOperation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentCrdtOperation(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      hlc: jsonSerialization['hlc'] as String,
      nodeId: jsonSerialization['nodeId'] as String,
      operationType: _i2.CrdtOperationType.fromJson(
        (jsonSerialization['operationType'] as String),
      ),
      fieldPath: jsonSerialization['fieldPath'] as String,
      fieldValue: jsonSerialization['fieldValue'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  String hlc;

  String nodeId;

  _i2.CrdtOperationType operationType;

  String fieldPath;

  String? fieldValue;

  DateTime? createdAt;

  _i1.UuidValue? createdByUserId;

  /// Returns a shallow copy of this [DocumentCrdtOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtOperation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentCrdtOperation',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'hlc': hlc,
      'nodeId': nodeId,
      'operationType': operationType.toJson(),
      'fieldPath': fieldPath,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentCrdtOperationImpl extends DocumentCrdtOperation {
  _DocumentCrdtOperationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) : super._(
         id: id,
         documentId: documentId,
         hlc: hlc,
         nodeId: nodeId,
         operationType: operationType,
         fieldPath: fieldPath,
         fieldValue: fieldValue,
         createdAt: createdAt,
         createdByUserId: createdByUserId,
       );

  /// Returns a shallow copy of this [DocumentCrdtOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentCrdtOperation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    Object? fieldValue = _Undefined,
    Object? createdAt = _Undefined,
    Object? createdByUserId = _Undefined,
  }) {
    return DocumentCrdtOperation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      hlc: hlc ?? this.hlc,
      nodeId: nodeId ?? this.nodeId,
      operationType: operationType ?? this.operationType,
      fieldPath: fieldPath ?? this.fieldPath,
      fieldValue: fieldValue is String? ? fieldValue : this.fieldValue,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
    );
  }
}
