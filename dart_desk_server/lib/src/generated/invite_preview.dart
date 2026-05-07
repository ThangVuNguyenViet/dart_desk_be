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
import 'package:serverpod/serverpod.dart' as _i1;
import 'client_role.dart' as _i2;

/// server-only DTO returned by InviteEndpoint.previewInvite
abstract class InvitePreview
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  InvitePreview._({
    required this.clientId,
    required this.clientName,
    required this.email,
    required this.role,
    required this.inviterName,
    required this.inviterEmail,
    required this.expiresAt,
    required this.hasExistingAccount,
  });

  factory InvitePreview({
    required _i1.UuidValue clientId,
    required String clientName,
    required String email,
    required _i2.ClientRole role,
    required String inviterName,
    required String inviterEmail,
    required DateTime expiresAt,
    required bool hasExistingAccount,
  }) = _InvitePreviewImpl;

  factory InvitePreview.fromJson(Map<String, dynamic> jsonSerialization) {
    return InvitePreview(
      clientId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientId'],
      ),
      clientName: jsonSerialization['clientName'] as String,
      email: jsonSerialization['email'] as String,
      role: _i2.ClientRole.fromJson((jsonSerialization['role'] as String)),
      inviterName: jsonSerialization['inviterName'] as String,
      inviterEmail: jsonSerialization['inviterEmail'] as String,
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      hasExistingAccount: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasExistingAccount'],
      ),
    );
  }

  _i1.UuidValue clientId;

  String clientName;

  String email;

  _i2.ClientRole role;

  String inviterName;

  String inviterEmail;

  DateTime expiresAt;

  bool hasExistingAccount;

  /// Returns a shallow copy of this [InvitePreview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InvitePreview copyWith({
    _i1.UuidValue? clientId,
    String? clientName,
    String? email,
    _i2.ClientRole? role,
    String? inviterName,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? hasExistingAccount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InvitePreview',
      'clientId': clientId.toJson(),
      'clientName': clientName,
      'email': email,
      'role': role.toJson(),
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'expiresAt': expiresAt.toJson(),
      'hasExistingAccount': hasExistingAccount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'InvitePreview',
      'clientId': clientId.toJson(),
      'clientName': clientName,
      'email': email,
      'role': role.toJson(),
      'inviterName': inviterName,
      'inviterEmail': inviterEmail,
      'expiresAt': expiresAt.toJson(),
      'hasExistingAccount': hasExistingAccount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _InvitePreviewImpl extends InvitePreview {
  _InvitePreviewImpl({
    required _i1.UuidValue clientId,
    required String clientName,
    required String email,
    required _i2.ClientRole role,
    required String inviterName,
    required String inviterEmail,
    required DateTime expiresAt,
    required bool hasExistingAccount,
  }) : super._(
         clientId: clientId,
         clientName: clientName,
         email: email,
         role: role,
         inviterName: inviterName,
         inviterEmail: inviterEmail,
         expiresAt: expiresAt,
         hasExistingAccount: hasExistingAccount,
       );

  /// Returns a shallow copy of this [InvitePreview]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InvitePreview copyWith({
    _i1.UuidValue? clientId,
    String? clientName,
    String? email,
    _i2.ClientRole? role,
    String? inviterName,
    String? inviterEmail,
    DateTime? expiresAt,
    bool? hasExistingAccount,
  }) {
    return InvitePreview(
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      email: email ?? this.email,
      role: role ?? this.role,
      inviterName: inviterName ?? this.inviterName,
      inviterEmail: inviterEmail ?? this.inviterEmail,
      expiresAt: expiresAt ?? this.expiresAt,
      hasExistingAccount: hasExistingAccount ?? this.hasExistingAccount,
    );
  }
}
