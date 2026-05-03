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
import 'api_key.dart' as _i2;
import 'package:dart_desk_client/src/protocol/protocol.dart' as _i3;

abstract class ApiKeyWithValue implements _i1.SerializableModel {
  ApiKeyWithValue._({
    required this.apiKey,
    required this.plaintextKey,
  });

  factory ApiKeyWithValue({
    required _i2.ApiKey apiKey,
    required String plaintextKey,
  }) = _ApiKeyWithValueImpl;

  factory ApiKeyWithValue.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiKeyWithValue(
      apiKey: _i3.Protocol().deserialize<_i2.ApiKey>(
        jsonSerialization['apiKey'],
      ),
      plaintextKey: jsonSerialization['plaintextKey'] as String,
    );
  }

  _i2.ApiKey apiKey;

  String plaintextKey;

  /// Returns a shallow copy of this [ApiKeyWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiKeyWithValue copyWith({
    _i2.ApiKey? apiKey,
    String? plaintextKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiKeyWithValue',
      'apiKey': apiKey.toJson(),
      'plaintextKey': plaintextKey,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ApiKeyWithValueImpl extends ApiKeyWithValue {
  _ApiKeyWithValueImpl({
    required _i2.ApiKey apiKey,
    required String plaintextKey,
  }) : super._(
         apiKey: apiKey,
         plaintextKey: plaintextKey,
       );

  /// Returns a shallow copy of this [ApiKeyWithValue]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiKeyWithValue copyWith({
    _i2.ApiKey? apiKey,
    String? plaintextKey,
  }) {
    return ApiKeyWithValue(
      apiKey: apiKey ?? this.apiKey.copyWith(),
      plaintextKey: plaintextKey ?? this.plaintextKey,
    );
  }
}
