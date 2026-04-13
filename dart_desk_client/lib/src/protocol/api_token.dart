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
    _i1.UuidValue? id,
    required this.projectId,
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
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory ApiToken({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) = _ApiTokenImpl;

  factory ApiToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiToken(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      tokenSuffix: jsonSerialization['tokenSuffix'] as String,
      role: jsonSerialization['role'] as String,
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
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

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String name;

  String tokenHash;

  String tokenPrefix;

  String tokenSuffix;

  String role;

  _i1.UuidValue? createdByUserId;

  DateTime? lastUsedAt;

  DateTime? expiresAt;

  bool isActive;

  DateTime? createdAt;

  /// Returns a shallow copy of this [ApiToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiToken copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiToken',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
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
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : super._(
         id: id,
         projectId: projectId,
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
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
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
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      tokenSuffix: tokenSuffix ?? this.tokenSuffix,
      role: role ?? this.role,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
