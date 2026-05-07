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
import 'client_role.dart' as _i2;

abstract class Invite implements _i1.SerializableModel {
  Invite._({
    _i1.UuidValue? id,
    required this.clientId,
    required this.email,
    required this.role,
    required this.token,
    required this.invitedByUserId,
    required this.expiresAt,
    this.acceptedAt,
    this.acceptedUserId,
    this.revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Invite({
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String email,
    required _i2.ClientRole role,
    required String token,
    required _i1.UuidValue invitedByUserId,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InviteImpl;

  factory Invite.fromJson(Map<String, dynamic> jsonSerialization) {
    return Invite(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      clientId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientId'],
      ),
      email: jsonSerialization['email'] as String,
      role: _i2.ClientRole.fromJson((jsonSerialization['role'] as String)),
      token: jsonSerialization['token'] as String,
      invitedByUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitedByUserId'],
      ),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      acceptedUserId: jsonSerialization['acceptedUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['acceptedUserId'],
            ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The id of the object.
  _i1.UuidValue id;

  _i1.UuidValue clientId;

  String email;

  _i2.ClientRole role;

  String token;

  _i1.UuidValue invitedByUserId;

  DateTime expiresAt;

  DateTime? acceptedAt;

  _i1.UuidValue? acceptedUserId;

  DateTime? revokedAt;

  DateTime? createdAt;

  DateTime? updatedAt;

  /// Returns a shallow copy of this [Invite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Invite copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? email,
    _i2.ClientRole? role,
    String? token,
    _i1.UuidValue? invitedByUserId,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Invite',
      'id': id.toJson(),
      'clientId': clientId.toJson(),
      'email': email,
      'role': role.toJson(),
      'token': token,
      'invitedByUserId': invitedByUserId.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (acceptedUserId != null) 'acceptedUserId': acceptedUserId?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
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

class _InviteImpl extends Invite {
  _InviteImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String email,
    required _i2.ClientRole role,
    required String token,
    required _i1.UuidValue invitedByUserId,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         email: email,
         role: role,
         token: token,
         invitedByUserId: invitedByUserId,
         expiresAt: expiresAt,
         acceptedAt: acceptedAt,
         acceptedUserId: acceptedUserId,
         revokedAt: revokedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Invite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Invite copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? email,
    _i2.ClientRole? role,
    String? token,
    _i1.UuidValue? invitedByUserId,
    DateTime? expiresAt,
    Object? acceptedAt = _Undefined,
    Object? acceptedUserId = _Undefined,
    Object? revokedAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Invite(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      acceptedUserId: acceptedUserId is _i1.UuidValue?
          ? acceptedUserId
          : this.acceptedUserId,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}
