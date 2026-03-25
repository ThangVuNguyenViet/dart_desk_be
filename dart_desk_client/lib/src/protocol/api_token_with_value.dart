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
import 'api_token.dart' as _i2;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i3;

abstract class ApiTokenWithValue implements _i1.SerializableModel {
  ApiTokenWithValue._({
    required this.token,
    required this.plaintextToken,
  });

  factory ApiTokenWithValue({
    required _i2.ApiToken token,
    required String plaintextToken,
  }) = _ApiTokenWithValueImpl;

  factory ApiTokenWithValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiTokenWithValue(
      token: _i3.Protocol().deserialize<_i2.ApiToken>(
        jsonSerialization['token'],
      ),
      plaintextToken: jsonSerialization['plaintextToken'] as String,
    );
  }

  _i2.ApiToken token;

  String plaintextToken;

  /// Returns a shallow copy of this [ApiTokenWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiTokenWithValue copyWith({
    _i2.ApiToken? token,
    String? plaintextToken,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiTokenWithValue',
      'token': token.toJson(),
      'plaintextToken': plaintextToken,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ApiTokenWithValueImpl extends ApiTokenWithValue {
  _ApiTokenWithValueImpl({
    required _i2.ApiToken token,
    required String plaintextToken,
  }) : super._(
         token: token,
         plaintextToken: plaintextToken,
       );

  /// Returns a shallow copy of this [ApiTokenWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiTokenWithValue copyWith({
    _i2.ApiToken? token,
    String? plaintextToken,
  }) {
    return ApiTokenWithValue(
      token: token ?? this.token.copyWith(),
      plaintextToken: plaintextToken ?? this.plaintextToken,
    );
  }
}
