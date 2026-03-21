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
import 'cms_api_token_with_value.dart' as _i3;
import 'cms_document.dart' as _i4;
import 'cms_document_data.dart' as _i5;
import 'cms_user.dart' as _i6;
import 'crdt_operation_type.dart' as _i7;
import 'document_crdt_operation.dart' as _i8;
import 'document_crdt_snapshot.dart' as _i9;
import 'document_list.dart' as _i10;
import 'document_version.dart' as _i11;
import 'document_version_list.dart' as _i12;
import 'document_version_list_with_operations.dart' as _i13;
import 'document_version_status.dart' as _i14;
import 'document_version_with_operations.dart' as _i15;
import 'media_asset.dart' as _i16;
import 'media_asset_metadata_status.dart' as _i17;
import 'package:dart_desk_be_client/src/protocol/cms_api_token.dart' as _i18;
import 'package:dart_desk_be_client/src/protocol/document_crdt_operation.dart'
    as _i19;
import 'package:dart_desk_be_client/src/protocol/media_asset.dart' as _i20;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i21;
import 'package:serverpod_admin_client/serverpod_admin_client.dart' as _i22;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i23;
export 'cms_api_token.dart';
export 'cms_api_token_with_value.dart';
export 'cms_document.dart';
export 'cms_document_data.dart';
export 'cms_user.dart';
export 'crdt_operation_type.dart';
export 'document_crdt_operation.dart';
export 'document_crdt_snapshot.dart';
export 'document_list.dart';
export 'document_version.dart';
export 'document_version_list.dart';
export 'document_version_list_with_operations.dart';
export 'document_version_status.dart';
export 'document_version_with_operations.dart';
export 'media_asset.dart';
export 'media_asset_metadata_status.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ApiToken) {
      return _i2.ApiToken.fromJson(data) as T;
    }
    if (t == _i3.ApiTokenWithValue) {
      return _i3.ApiTokenWithValue.fromJson(data) as T;
    }
    if (t == _i4.Document) {
      return _i4.Document.fromJson(data) as T;
    }
    if (t == _i5.DocumentData) {
      return _i5.DocumentData.fromJson(data) as T;
    }
    if (t == _i6.User) {
      return _i6.User.fromJson(data) as T;
    }
    if (t == _i7.CrdtOperationType) {
      return _i7.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i8.DocumentCrdtOperation) {
      return _i8.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i9.DocumentCrdtSnapshot) {
      return _i9.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i10.DocumentList) {
      return _i10.DocumentList.fromJson(data) as T;
    }
    if (t == _i11.DocumentVersion) {
      return _i11.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i12.DocumentVersionList) {
      return _i12.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i13.DocumentVersionListWithOperations) {
      return _i13.DocumentVersionListWithOperations.fromJson(data) as T;
    }
    if (t == _i14.DocumentVersionStatus) {
      return _i14.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i15.DocumentVersionWithOperations) {
      return _i15.DocumentVersionWithOperations.fromJson(data) as T;
    }
    if (t == _i16.MediaAsset) {
      return _i16.MediaAsset.fromJson(data) as T;
    }
    if (t == _i17.MediaAssetMetadataStatus) {
      return _i17.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ApiToken?>()) {
      return (data != null ? _i2.ApiToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ApiTokenWithValue?>()) {
      return (data != null ? _i3.ApiTokenWithValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Document?>()) {
      return (data != null ? _i4.Document.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DocumentData?>()) {
      return (data != null ? _i5.DocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.User?>()) {
      return (data != null ? _i6.User.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CrdtOperationType?>()) {
      return (data != null ? _i7.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DocumentCrdtOperation?>()) {
      return (data != null ? _i8.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i9.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.DocumentList?>()) {
      return (data != null ? _i10.DocumentList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.DocumentVersion?>()) {
      return (data != null ? _i11.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DocumentVersionList?>()) {
      return (data != null ? _i12.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.DocumentVersionListWithOperations?>()) {
      return (data != null
              ? _i13.DocumentVersionListWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i14.DocumentVersionStatus?>()) {
      return (data != null ? _i14.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DocumentVersionWithOperations?>()) {
      return (data != null
              ? _i15.DocumentVersionWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i16.MediaAsset?>()) {
      return (data != null ? _i16.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i17.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_i4.Document>) {
      return (data as List).map((e) => deserialize<_i4.Document>(e)).toList()
          as T;
    }
    if (t == List<_i11.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i11.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i15.DocumentVersionWithOperations>) {
      return (data as List)
              .map((e) => deserialize<_i15.DocumentVersionWithOperations>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i8.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<_i18.ApiToken>) {
      return (data as List).map((e) => deserialize<_i18.ApiToken>(e)).toList()
          as T;
    }
    if (t == List<_i19.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i19.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == Map<String, dynamic>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
          )
          as T;
    }
    if (t == List<Map<String, dynamic>>) {
      return (data as List)
              .map((e) => deserialize<Map<String, dynamic>>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _i1.getType<Map<String, dynamic>?>()) {
      return (data != null
              ? (data as Map).map(
                  (k, v) =>
                      MapEntry(deserialize<String>(k), deserialize<dynamic>(v)),
                )
              : null)
          as T;
    }
    if (t == List<_i20.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i20.MediaAsset>(e)).toList()
          as T;
    }
    try {
      return _i21.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i22.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i23.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ApiToken => 'ApiToken',
      _i3.ApiTokenWithValue => 'ApiTokenWithValue',
      _i4.Document => 'Document',
      _i5.DocumentData => 'DocumentData',
      _i6.User => 'User',
      _i7.CrdtOperationType => 'CrdtOperationType',
      _i8.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i9.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i10.DocumentList => 'DocumentList',
      _i11.DocumentVersion => 'DocumentVersion',
      _i12.DocumentVersionList => 'DocumentVersionList',
      _i13.DocumentVersionListWithOperations =>
        'DocumentVersionListWithOperations',
      _i14.DocumentVersionStatus => 'DocumentVersionStatus',
      _i15.DocumentVersionWithOperations => 'DocumentVersionWithOperations',
      _i16.MediaAsset => 'MediaAsset',
      _i17.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'dart_desk_be.',
        '',
      );
    }

    switch (data) {
      case _i2.ApiToken():
        return 'ApiToken';
      case _i3.ApiTokenWithValue():
        return 'ApiTokenWithValue';
      case _i4.Document():
        return 'Document';
      case _i5.DocumentData():
        return 'DocumentData';
      case _i6.User():
        return 'User';
      case _i7.CrdtOperationType():
        return 'CrdtOperationType';
      case _i8.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i9.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i10.DocumentList():
        return 'DocumentList';
      case _i11.DocumentVersion():
        return 'DocumentVersion';
      case _i12.DocumentVersionList():
        return 'DocumentVersionList';
      case _i13.DocumentVersionListWithOperations():
        return 'DocumentVersionListWithOperations';
      case _i14.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i15.DocumentVersionWithOperations():
        return 'DocumentVersionWithOperations';
      case _i16.MediaAsset():
        return 'MediaAsset';
      case _i17.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
    }
    className = _i21.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i22.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_admin.$className';
    }
    className = _i23.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ApiToken') {
      return deserialize<_i2.ApiToken>(data['data']);
    }
    if (dataClassName == 'ApiTokenWithValue') {
      return deserialize<_i3.ApiTokenWithValue>(data['data']);
    }
    if (dataClassName == 'Document') {
      return deserialize<_i4.Document>(data['data']);
    }
    if (dataClassName == 'DocumentData') {
      return deserialize<_i5.DocumentData>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i6.User>(data['data']);
    }
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i7.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i8.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i9.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentList') {
      return deserialize<_i10.DocumentList>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i11.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i12.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'DocumentVersionListWithOperations') {
      return deserialize<_i13.DocumentVersionListWithOperations>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i14.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'DocumentVersionWithOperations') {
      return deserialize<_i15.DocumentVersionWithOperations>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i16.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i17.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i21.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_admin.')) {
      data['className'] = dataClassName.substring(16);
      return _i22.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i23.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i21.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i22.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i23.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
