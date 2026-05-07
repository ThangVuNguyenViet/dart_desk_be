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
import 'invite.dart' as _i2;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i3;

/// server-only DTO returned by inviteMember and resendInvite
abstract class InviteResult implements _i1.SerializableModel {
  InviteResult._({
    required this.invite,
    required this.emailSent,
  });

  factory InviteResult({
    required _i2.Invite invite,
    required bool emailSent,
  }) = _InviteResultImpl;

  factory InviteResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return InviteResult(
      invite: _i3.Protocol().deserialize<_i2.Invite>(
        jsonSerialization['invite'],
      ),
      emailSent: _i1.BoolJsonExtension.fromJson(jsonSerialization['emailSent']),
    );
  }

  _i2.Invite invite;

  bool emailSent;

  /// Returns a shallow copy of this [InviteResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  InviteResult copyWith({
    _i2.Invite? invite,
    bool? emailSent,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'InviteResult',
      'invite': invite.toJson(),
      'emailSent': emailSent,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _InviteResultImpl extends InviteResult {
  _InviteResultImpl({
    required _i2.Invite invite,
    required bool emailSent,
  }) : super._(
         invite: invite,
         emailSent: emailSent,
       );

  /// Returns a shallow copy of this [InviteResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  InviteResult copyWith({
    _i2.Invite? invite,
    bool? emailSent,
  }) {
    return InviteResult(
      invite: invite ?? this.invite.copyWith(),
      emailSent: emailSent ?? this.emailSent,
    );
  }
}
