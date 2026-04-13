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

abstract class MigrationHistory implements _i1.SerializableModel {
  MigrationHistory._({
    _i1.UuidValue? id,
    required this.projectId,
    required this.name,
    required this.documentType,
    DateTime? appliedAt,
    required this.operationsJson,
    required this.report,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       appliedAt = appliedAt ?? DateTime.now();

  factory MigrationHistory({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String documentType,
    DateTime? appliedAt,
    required String operationsJson,
    required String report,
  }) = _MigrationHistoryImpl;

  factory MigrationHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return MigrationHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      name: jsonSerialization['name'] as String,
      documentType: jsonSerialization['documentType'] as String,
      appliedAt: jsonSerialization['appliedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['appliedAt']),
      operationsJson: jsonSerialization['operationsJson'] as String,
      report: jsonSerialization['report'] as String,
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String name;

  String documentType;

  DateTime appliedAt;

  String operationsJson;

  String report;

  /// Returns a shallow copy of this [MigrationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MigrationHistory copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? documentType,
    DateTime? appliedAt,
    String? operationsJson,
    String? report,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MigrationHistory',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'documentType': documentType,
      'appliedAt': appliedAt.toJson(),
      'operationsJson': operationsJson,
      'report': report,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MigrationHistoryImpl extends MigrationHistory {
  _MigrationHistoryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String documentType,
    DateTime? appliedAt,
    required String operationsJson,
    required String report,
  }) : super._(
         id: id,
         projectId: projectId,
         name: name,
         documentType: documentType,
         appliedAt: appliedAt,
         operationsJson: operationsJson,
         report: report,
       );

  /// Returns a shallow copy of this [MigrationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MigrationHistory copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? documentType,
    DateTime? appliedAt,
    String? operationsJson,
    String? report,
  }) {
    return MigrationHistory(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      documentType: documentType ?? this.documentType,
      appliedAt: appliedAt ?? this.appliedAt,
      operationsJson: operationsJson ?? this.operationsJson,
      report: report ?? this.report,
    );
  }
}
