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
import 'document_version.dart' as _i2;
import 'document_crdt_operation.dart' as _i3;
import 'package:dart_desk_be_server/src/generated/protocol.dart' as _i4;

abstract class DocumentVersionWithOperations
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DocumentVersionWithOperations._({
    required this.version,
    required this.operationsSincePrevious,
  });

  factory DocumentVersionWithOperations({
    required _i2.DocumentVersion version,
    required List<_i3.DocumentCrdtOperation> operationsSincePrevious,
  }) = _DocumentVersionWithOperationsImpl;

  factory DocumentVersionWithOperations.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentVersionWithOperations(
      version: _i4.Protocol().deserialize<_i2.DocumentVersion>(
        jsonSerialization['version'],
      ),
      operationsSincePrevious: _i4.Protocol()
          .deserialize<List<_i3.DocumentCrdtOperation>>(
            jsonSerialization['operationsSincePrevious'],
          ),
    );
  }

  _i2.DocumentVersion version;

  List<_i3.DocumentCrdtOperation> operationsSincePrevious;

  /// Returns a shallow copy of this [DocumentVersionWithOperations]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentVersionWithOperations copyWith({
    _i2.DocumentVersion? version,
    List<_i3.DocumentCrdtOperation>? operationsSincePrevious,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentVersionWithOperations',
      'version': version.toJson(),
      'operationsSincePrevious': operationsSincePrevious.toJson(
        valueToJson: (v) => v.toJson(),
      ),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentVersionWithOperations',
      'version': version.toJsonForProtocol(),
      'operationsSincePrevious': operationsSincePrevious.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _DocumentVersionWithOperationsImpl extends DocumentVersionWithOperations {
  _DocumentVersionWithOperationsImpl({
    required _i2.DocumentVersion version,
    required List<_i3.DocumentCrdtOperation> operationsSincePrevious,
  }) : super._(
         version: version,
         operationsSincePrevious: operationsSincePrevious,
       );

  /// Returns a shallow copy of this [DocumentVersionWithOperations]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentVersionWithOperations copyWith({
    _i2.DocumentVersion? version,
    List<_i3.DocumentCrdtOperation>? operationsSincePrevious,
  }) {
    return DocumentVersionWithOperations(
      version: version ?? this.version.copyWith(),
      operationsSincePrevious:
          operationsSincePrevious ??
          this.operationsSincePrevious.map((e0) => e0.copyWith()).toList(),
    );
  }
}
