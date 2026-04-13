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

abstract class ApiException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  ApiException._({
    required this.message,
    required this.code,
    this.errorCode,
  });

  factory ApiException({
    required String message,
    required int code,
    String? errorCode,
  }) = _ApiExceptionImpl;

  factory ApiException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiException(
      message: jsonSerialization['message'] as String,
      code: jsonSerialization['code'] as int,
      errorCode: jsonSerialization['errorCode'] as String?,
    );
  }

  String message;

  int code;

  String? errorCode;

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiException copyWith({
    String? message,
    int? code,
    String? errorCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiException',
      'message': message,
      'code': code,
      if (errorCode != null) 'errorCode': errorCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ApiException',
      'message': message,
      'code': code,
      if (errorCode != null) 'errorCode': errorCode,
    };
  }

  @override
  String toString() {
    return 'ApiException(message: $message, code: $code, errorCode: $errorCode)';
  }
}

class _Undefined {}

class _ApiExceptionImpl extends ApiException {
  _ApiExceptionImpl({
    required String message,
    required int code,
    String? errorCode,
  }) : super._(
         message: message,
         code: code,
         errorCode: errorCode,
       );

  /// Returns a shallow copy of this [ApiException]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiException copyWith({
    String? message,
    int? code,
    Object? errorCode = _Undefined,
  }) {
    return ApiException(
      message: message ?? this.message,
      code: code ?? this.code,
      errorCode: errorCode is String? ? errorCode : this.errorCode,
    );
  }
}
