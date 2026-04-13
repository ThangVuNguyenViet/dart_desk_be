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
import 'project_role.dart' as _i2;

abstract class ProjectMember implements _i1.SerializableModel {
  ProjectMember._({
    _i1.UuidValue? id,
    required this.userId,
    required this.projectId,
    required this.role,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory ProjectMember({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required _i1.UuidValue projectId,
    required _i2.ProjectRole role,
    DateTime? createdAt,
  }) = _ProjectMemberImpl;

  factory ProjectMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProjectMember(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _i1.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      role: _i2.ProjectRole.fromJson((jsonSerialization['role'] as String)),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue userId;

  _i1.UuidValue projectId;

  _i2.ProjectRole role;

  DateTime? createdAt;

  /// Returns a shallow copy of this [ProjectMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProjectMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    _i1.UuidValue? projectId,
    _i2.ProjectRole? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProjectMember',
      'id': id.toJson(),
      'userId': userId.toJson(),
      'projectId': projectId.toJson(),
      'role': role.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProjectMemberImpl extends ProjectMember {
  _ProjectMemberImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue userId,
    required _i1.UuidValue projectId,
    required _i2.ProjectRole role,
    DateTime? createdAt,
  }) : super._(
         id: id,
         userId: userId,
         projectId: projectId,
         role: role,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ProjectMember]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProjectMember copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? userId,
    _i1.UuidValue? projectId,
    _i2.ProjectRole? role,
    Object? createdAt = _Undefined,
  }) {
    return ProjectMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      role: role ?? this.role,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
