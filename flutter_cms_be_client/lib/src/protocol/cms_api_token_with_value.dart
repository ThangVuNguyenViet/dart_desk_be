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
import 'cms_api_token.dart' as _i2;
import 'package:flutter_cms_be_client/src/protocol/protocol.dart' as _i3;

abstract class CmsApiTokenWithValue implements _i1.SerializableModel {
  CmsApiTokenWithValue._({
    required this.token,
    required this.plaintextToken,
  });

  factory CmsApiTokenWithValue({
    required _i2.CmsApiToken token,
    required String plaintextToken,
  }) = _CmsApiTokenWithValueImpl;

  factory CmsApiTokenWithValue.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return CmsApiTokenWithValue(
      token: _i3.Protocol().deserialize<_i2.CmsApiToken>(
        jsonSerialization['token'],
      ),
      plaintextToken: jsonSerialization['plaintextToken'] as String,
    );
  }

  _i2.CmsApiToken token;

  String plaintextToken;

  /// Returns a shallow copy of this [CmsApiTokenWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsApiTokenWithValue copyWith({
    _i2.CmsApiToken? token,
    String? plaintextToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsApiTokenWithValue',
      'token': token.toJson(),
      'plaintextToken': plaintextToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _CmsApiTokenWithValueImpl extends CmsApiTokenWithValue {
  _CmsApiTokenWithValueImpl({
    required _i2.CmsApiToken token,
    required String plaintextToken,
  }) : super._(
         token: token,
         plaintextToken: plaintextToken,
       );

  /// Returns a shallow copy of this [CmsApiTokenWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsApiTokenWithValue copyWith({
    _i2.CmsApiToken? token,
    String? plaintextToken,
  }) {
    return CmsApiTokenWithValue(
      token: token ?? this.token.copyWith(),
      plaintextToken: plaintextToken ?? this.plaintextToken,
    );
  }
}
