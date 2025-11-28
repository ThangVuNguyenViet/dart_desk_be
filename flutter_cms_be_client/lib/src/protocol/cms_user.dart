/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class CmsUser implements _i1.SerializableModel {
  CmsUser._({
    this.id,
    required this.email,
    this.name,
    String? role,
    DateTime? createdAt,
  })  : role = role ?? 'viewer',
        createdAt = createdAt ?? DateTime.now();

  factory CmsUser({
    int? id,
    required String email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) = _CmsUserImpl;

  factory CmsUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsUser(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      role: jsonSerialization['role'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String email;

  String? name;

  String role;

  DateTime? createdAt;

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsUser copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsUserImpl extends CmsUser {
  _CmsUserImpl({
    int? id,
    required String email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) : super._(
          id: id,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsUser copyWith({
    Object? id = _Undefined,
    String? email,
    Object? name = _Undefined,
    String? role,
    Object? createdAt = _Undefined,
  }) {
    return CmsUser(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      role: role ?? this.role,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
