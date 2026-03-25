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

abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    this.clientId,
    required this.email,
    this.name,
    String? role,
    bool? isActive,
    this.serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : role = role ?? 'viewer',
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory User({
    int? id,
    int? clientId,
    required String email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int?,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      role: jsonSerialization['role'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      serverpodUserId: jsonSerialization['serverpodUserId'] as String?,
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

  int? clientId;

  String email;

  String? name;

  String role;

  bool isActive;

  String? serverpodUserId;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    int? clientId,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id,
      if (clientId != null) 'clientId': clientId,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      'isActive': isActive,
      if (serverpodUserId != null) 'serverpodUserId': serverpodUserId,
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

class _UserImpl extends User {
  _UserImpl({
    int? id,
    int? clientId,
    required String email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         email: email,
         name: name,
         role: role,
         isActive: isActive,
         serverpodUserId: serverpodUserId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    Object? clientId = _Undefined,
    String? email,
    Object? name = _Undefined,
    String? role,
    bool? isActive,
    Object? serverpodUserId = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      clientId: clientId is int? ? clientId : this.clientId,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      serverpodUserId: serverpodUserId is String?
          ? serverpodUserId
          : this.serverpodUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
