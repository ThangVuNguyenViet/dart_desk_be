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
    this.id,
    required this.projectId,
    required this.name,
    required this.documentType,
    DateTime? appliedAt,
    required this.operationsJson,
    required this.report,
  }) : appliedAt = appliedAt ?? DateTime.now();

  factory MigrationHistory({
    int? id,
    required int projectId,
    required String name,
    required String documentType,
    DateTime? appliedAt,
    required String operationsJson,
    required String report,
  }) = _MigrationHistoryImpl;

  factory MigrationHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return MigrationHistory(
      id: jsonSerialization['id'] as int?,
      projectId: jsonSerialization['projectId'] as int,
      name: jsonSerialization['name'] as String,
      documentType: jsonSerialization['documentType'] as String,
      appliedAt: jsonSerialization['appliedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['appliedAt']),
      operationsJson: jsonSerialization['operationsJson'] as String,
      report: jsonSerialization['report'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int projectId;

  String name;

  String documentType;

  DateTime appliedAt;

  String operationsJson;

  String report;

  /// Returns a shallow copy of this [MigrationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MigrationHistory copyWith({
    int? id,
    int? projectId,
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
      if (id != null) 'id': id,
      'projectId': projectId,
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

class _Undefined {}

class _MigrationHistoryImpl extends MigrationHistory {
  _MigrationHistoryImpl({
    int? id,
    required int projectId,
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
    Object? id = _Undefined,
    int? projectId,
    String? name,
    String? documentType,
    DateTime? appliedAt,
    String? operationsJson,
    String? report,
  }) {
    return MigrationHistory(
      id: id is int? ? id : this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      documentType: documentType ?? this.documentType,
      appliedAt: appliedAt ?? this.appliedAt,
      operationsJson: operationsJson ?? this.operationsJson,
      report: report ?? this.report,
    );
  }
}
