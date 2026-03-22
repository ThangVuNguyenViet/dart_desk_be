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

abstract class ApiToken implements _i1.SerializableModel {
  ApiToken._({
    this.id,
    this.tenantId,
    required this.name,
    required this.tokenHash,
    required this.tokenPrefix,
    required this.tokenSuffix,
    required this.role,
    this.createdByUserId,
    this.lastUsedAt,
    this.expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory ApiToken({
    int? id,
    int? tenantId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) = _ApiTokenImpl;

  factory ApiToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiToken(
      id: jsonSerialization['id'] as int?,
      tenantId: jsonSerialization['tenantId'] as int?,
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      tokenSuffix: jsonSerialization['tokenSuffix'] as String,
      role: jsonSerialization['role'] as String,
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? tenantId;

  String name;

  String tokenHash;

  String tokenPrefix;

  String tokenSuffix;

  String role;

  int? createdByUserId;

  DateTime? lastUsedAt;

  DateTime? expiresAt;

  bool isActive;

  DateTime? createdAt;

  /// Returns a shallow copy of this [ApiToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiToken copyWith({
    int? id,
    int? tenantId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiToken',
      if (id != null) 'id': id,
      if (tenantId != null) 'tenantId': tenantId,
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ApiTokenImpl extends ApiToken {
  _ApiTokenImpl({
    int? id,
    int? tenantId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         name: name,
         tokenHash: tokenHash,
         tokenPrefix: tokenPrefix,
         tokenSuffix: tokenSuffix,
         role: role,
         createdByUserId: createdByUserId,
         lastUsedAt: lastUsedAt,
         expiresAt: expiresAt,
         isActive: isActive,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ApiToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiToken copyWith({
    Object? id = _Undefined,
    Object? tenantId = _Undefined,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    Object? createdByUserId = _Undefined,
    Object? lastUsedAt = _Undefined,
    Object? expiresAt = _Undefined,
    bool? isActive,
    Object? createdAt = _Undefined,
  }) {
    return ApiToken(
      id: id is int? ? id : this.id,
      tenantId: tenantId is int? ? tenantId : this.tenantId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      tokenSuffix: tokenSuffix ?? this.tokenSuffix,
      role: role ?? this.role,
      createdByUserId: createdByUserId is int?
          ? createdByUserId
          : this.createdByUserId,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
