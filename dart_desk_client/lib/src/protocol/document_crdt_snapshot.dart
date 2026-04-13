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

abstract class DocumentCrdtSnapshot implements _i1.SerializableModel {
  DocumentCrdtSnapshot._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.snapshotHlc,
    required this.snapshotData,
    required this.operationCountAtSnapshot,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtSnapshot({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) = _DocumentCrdtSnapshotImpl;

  factory DocumentCrdtSnapshot.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentCrdtSnapshot(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      snapshotHlc: jsonSerialization['snapshotHlc'] as String,
      snapshotData: jsonSerialization['snapshotData'] as String,
      operationCountAtSnapshot:
          jsonSerialization['operationCountAtSnapshot'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  String snapshotHlc;

  String snapshotData;

  int operationCountAtSnapshot;

  DateTime? createdAt;

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtSnapshot copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentCrdtSnapshot',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'snapshotHlc': snapshotHlc,
      'snapshotData': snapshotData,
      'operationCountAtSnapshot': operationCountAtSnapshot,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentCrdtSnapshotImpl extends DocumentCrdtSnapshot {
  _DocumentCrdtSnapshotImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) : super._(
         id: id,
         documentId: documentId,
         snapshotHlc: snapshotHlc,
         snapshotData: snapshotData,
         operationCountAtSnapshot: operationCountAtSnapshot,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentCrdtSnapshot copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    Object? createdAt = _Undefined,
  }) {
    return DocumentCrdtSnapshot(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      snapshotHlc: snapshotHlc ?? this.snapshotHlc,
      snapshotData: snapshotData ?? this.snapshotData,
      operationCountAtSnapshot:
          operationCountAtSnapshot ?? this.operationCountAtSnapshot,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
