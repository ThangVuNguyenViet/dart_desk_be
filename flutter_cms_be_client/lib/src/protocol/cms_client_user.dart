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

abstract class CmsClientUser implements _i1.SerializableModel {
  CmsClientUser._({
    this.id,
    required this.clientId,
    required this.cmsUserId,
    required this.role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : isActive = isActive ?? true,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CmsClientUser({
    int? id,
    required int clientId,
    required int cmsUserId,
    required String role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CmsClientUserImpl;

  factory CmsClientUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsClientUser(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      cmsUserId: jsonSerialization['cmsUserId'] as int,
      role: jsonSerialization['role'] as String,
      isActive: jsonSerialization['isActive'] as bool,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int clientId;

  int cmsUserId;

  String role;

  bool isActive;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [CmsClientUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsClientUser copyWith({
    int? id,
    int? clientId,
    int? cmsUserId,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'cmsUserId': cmsUserId,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsClientUserImpl extends CmsClientUser {
  _CmsClientUserImpl({
    int? id,
    required int clientId,
    required int cmsUserId,
    required String role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          clientId: clientId,
          cmsUserId: cmsUserId,
          role: role,
          isActive: isActive,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [CmsClientUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsClientUser copyWith({
    Object? id = _Undefined,
    int? clientId,
    int? cmsUserId,
    String? role,
    bool? isActive,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CmsClientUser(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      cmsUserId: cmsUserId ?? this.cmsUserId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
