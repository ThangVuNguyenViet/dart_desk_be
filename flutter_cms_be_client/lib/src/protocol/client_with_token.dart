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
import 'package:flutter_cms_be_client/src/protocol/protocol.dart' as _i3;

abstract class ClientWithToken implements _i1.SerializableModel {
  ClientWithToken._({
    required this.client,
    required this.apiToken,
  });

  factory ClientWithToken({
    required _i2.CmsClient client,
    required String apiToken,
  }) = _ClientWithTokenImpl;

  factory ClientWithToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClientWithToken(
      client: _i3.Protocol().deserialize<_i2.CmsClient>(
        jsonSerialization['client'],
      ),
      apiToken: jsonSerialization['apiToken'] as String,
    );
  }

  _i2.CmsClient client;

  String apiToken;

  /// Returns a shallow copy of this [ClientWithToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ClientWithToken copyWith({
    _i2.CmsClient? client,
    String? apiToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClientWithToken',
      'client': client.toJson(),
      'apiToken': apiToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ClientWithTokenImpl extends ClientWithToken {
  _ClientWithTokenImpl({
    required _i2.CmsClient client,
    required String apiToken,
  }) : super._(
         client: client,
         apiToken: apiToken,
       );

  /// Returns a shallow copy of this [ClientWithToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ClientWithToken copyWith({
    _i2.CmsClient? client,
    String? apiToken,
  }) {
    return ClientWithToken(
      client: client ?? this.client.copyWith(),
      apiToken: apiToken ?? this.apiToken,
    );
  }
}
