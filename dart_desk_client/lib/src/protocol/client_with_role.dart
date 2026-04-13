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
import 'cms_client.dart' as _i2;
import 'client_role.dart' as _i3;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i4;

abstract class ClientWithRole implements _i1.SerializableModel {
  ClientWithRole._({
    required this.client,
    required this.role,
    required this.projectCount,
  });

  factory ClientWithRole({
    required _i2.CmsClient client,
    required _i3.ClientRole role,
    required int projectCount,
  }) = _ClientWithRoleImpl;

  factory ClientWithRole.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClientWithRole(
      client: _i4.Protocol().deserialize<_i2.CmsClient>(
        jsonSerialization['client'],
      ),
      role: _i3.ClientRole.fromJson((jsonSerialization['role'] as String)),
      projectCount: jsonSerialization['projectCount'] as int,
    );
  }

  _i2.CmsClient client;

  _i3.ClientRole role;

  int projectCount;

  /// Returns a shallow copy of this [ClientWithRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClientWithRole copyWith({
    _i2.CmsClient? client,
    _i3.ClientRole? role,
    int? projectCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClientWithRole',
      'client': client.toJson(),
      'role': role.toJson(),
      'projectCount': projectCount,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ClientWithRoleImpl extends ClientWithRole {
  _ClientWithRoleImpl({
    required _i2.CmsClient client,
    required _i3.ClientRole role,
    required int projectCount,
  }) : super._(
         client: client,
         role: role,
         projectCount: projectCount,
       );

  /// Returns a shallow copy of this [ClientWithRole]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClientWithRole copyWith({
    _i2.CmsClient? client,
    _i3.ClientRole? role,
    int? projectCount,
  }) {
    return ClientWithRole(
      client: client ?? this.client.copyWith(),
      role: role ?? this.role,
      projectCount: projectCount ?? this.projectCount,
    );
  }
}
