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
import 'api_token_with_value.dart' as _i3;
import 'crdt_operation_type.dart' as _i4;
import 'deployment.dart' as _i5;
import 'deployment_status.dart' as _i6;
import 'document.dart' as _i7;
import 'document_crdt_operation.dart' as _i8;
import 'document_crdt_snapshot.dart' as _i9;
import 'document_data.dart' as _i10;
import 'document_list.dart' as _i11;
import 'document_version.dart' as _i12;
import 'document_version_list.dart' as _i13;
import 'document_version_list_with_operations.dart' as _i14;
import 'document_version_status.dart' as _i15;
import 'document_version_with_operations.dart' as _i16;
import 'media_asset.dart' as _i17;
import 'media_asset_metadata_status.dart' as _i18;
import 'project.dart' as _i19;
import 'project_list.dart' as _i20;
import 'user.dart' as _i21;
import 'package:dart_desk_be_client/src/protocol/api_token.dart' as _i22;
import 'package:dart_desk_be_client/src/protocol/deployment.dart' as _i23;
import 'package:dart_desk_be_client/src/protocol/document_crdt_operation.dart'
    as _i24;
import 'package:dart_desk_be_client/src/protocol/media_asset.dart' as _i25;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i26;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i27;
export 'api_token.dart';
export 'api_token_with_value.dart';
export 'crdt_operation_type.dart';
export 'deployment.dart';
export 'deployment_status.dart';
export 'document.dart';
export 'document_crdt_operation.dart';
export 'document_crdt_snapshot.dart';
export 'document_data.dart';
export 'document_list.dart';
export 'document_version.dart';
export 'document_version_list.dart';
export 'document_version_list_with_operations.dart';
export 'document_version_status.dart';
export 'document_version_with_operations.dart';
export 'media_asset.dart';
export 'media_asset_metadata_status.dart';
export 'project.dart';
export 'project_list.dart';
export 'user.dart';
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
    if (t == _i4.CrdtOperationType) {
      return _i4.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i5.Deployment) {
      return _i5.Deployment.fromJson(data) as T;
    }
    if (t == _i6.DeploymentStatus) {
      return _i6.DeploymentStatus.fromJson(data) as T;
    }
    if (t == _i7.Document) {
      return _i7.Document.fromJson(data) as T;
    }
    if (t == _i8.DocumentCrdtOperation) {
      return _i8.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i9.DocumentCrdtSnapshot) {
      return _i9.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i10.DocumentData) {
      return _i10.DocumentData.fromJson(data) as T;
    }
    if (t == _i11.DocumentList) {
      return _i11.DocumentList.fromJson(data) as T;
    }
    if (t == _i12.DocumentVersion) {
      return _i12.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i13.DocumentVersionList) {
      return _i13.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i14.DocumentVersionListWithOperations) {
      return _i14.DocumentVersionListWithOperations.fromJson(data) as T;
    }
    if (t == _i15.DocumentVersionStatus) {
      return _i15.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i16.DocumentVersionWithOperations) {
      return _i16.DocumentVersionWithOperations.fromJson(data) as T;
    }
    if (t == _i17.MediaAsset) {
      return _i17.MediaAsset.fromJson(data) as T;
    }
    if (t == _i18.MediaAssetMetadataStatus) {
      return _i18.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i19.Project) {
      return _i19.Project.fromJson(data) as T;
    }
    if (t == _i20.ProjectList) {
      return _i20.ProjectList.fromJson(data) as T;
    }
    if (t == _i21.User) {
      return _i21.User.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ApiToken?>()) {
      return (data != null ? _i2.ApiToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ApiTokenWithValue?>()) {
      return (data != null ? _i3.ApiTokenWithValue.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CrdtOperationType?>()) {
      return (data != null ? _i4.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Deployment?>()) {
      return (data != null ? _i5.Deployment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DeploymentStatus?>()) {
      return (data != null ? _i6.DeploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Document?>()) {
      return (data != null ? _i7.Document.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.DocumentCrdtOperation?>()) {
      return (data != null ? _i8.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i9.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.DocumentData?>()) {
      return (data != null ? _i10.DocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.DocumentList?>()) {
      return (data != null ? _i11.DocumentList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DocumentVersion?>()) {
      return (data != null ? _i12.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DocumentVersionList?>()) {
      return (data != null ? _i13.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DocumentVersionListWithOperations?>()) {
      return (data != null
              ? _i14.DocumentVersionListWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i15.DocumentVersionStatus?>()) {
      return (data != null ? _i15.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.DocumentVersionWithOperations?>()) {
      return (data != null
              ? _i16.DocumentVersionWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i17.MediaAsset?>()) {
      return (data != null ? _i17.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i18.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.Project?>()) {
      return (data != null ? _i19.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ProjectList?>()) {
      return (data != null ? _i20.ProjectList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.User?>()) {
      return (data != null ? _i21.User.fromJson(data) : null) as T;
    }
    if (t == List<_i7.Document>) {
      return (data as List).map((e) => deserialize<_i7.Document>(e)).toList()
          as T;
    }
    if (t == List<_i12.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i12.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i16.DocumentVersionWithOperations>) {
      return (data as List)
              .map((e) => deserialize<_i16.DocumentVersionWithOperations>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i8.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<_i19.Project>) {
      return (data as List).map((e) => deserialize<_i19.Project>(e)).toList()
          as T;
    }
    if (t == List<_i22.ApiToken>) {
      return (data as List).map((e) => deserialize<_i22.ApiToken>(e)).toList()
          as T;
    }
    if (t == List<_i23.Deployment>) {
      return (data as List).map((e) => deserialize<_i23.Deployment>(e)).toList()
          as T;
    }
    if (t == List<_i24.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i24.DocumentCrdtOperation>(e))
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
    if (t == List<_i25.MediaAsset>) {
      return (data as List).map((e) => deserialize<_i25.MediaAsset>(e)).toList()
          as T;
    }
    try {
      return _i26.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i27.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ApiToken => 'ApiToken',
      _i3.ApiTokenWithValue => 'ApiTokenWithValue',
      _i4.CrdtOperationType => 'CrdtOperationType',
      _i5.Deployment => 'Deployment',
      _i6.DeploymentStatus => 'DeploymentStatus',
      _i7.Document => 'Document',
      _i8.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i9.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i10.DocumentData => 'DocumentData',
      _i11.DocumentList => 'DocumentList',
      _i12.DocumentVersion => 'DocumentVersion',
      _i13.DocumentVersionList => 'DocumentVersionList',
      _i14.DocumentVersionListWithOperations =>
        'DocumentVersionListWithOperations',
      _i15.DocumentVersionStatus => 'DocumentVersionStatus',
      _i16.DocumentVersionWithOperations => 'DocumentVersionWithOperations',
      _i17.MediaAsset => 'MediaAsset',
      _i18.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
      _i19.Project => 'Project',
      _i20.ProjectList => 'ProjectList',
      _i21.User => 'User',
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
      case _i4.CrdtOperationType():
        return 'CrdtOperationType';
      case _i5.Deployment():
        return 'Deployment';
      case _i6.DeploymentStatus():
        return 'DeploymentStatus';
      case _i7.Document():
        return 'Document';
      case _i8.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i9.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i10.DocumentData():
        return 'DocumentData';
      case _i11.DocumentList():
        return 'DocumentList';
      case _i12.DocumentVersion():
        return 'DocumentVersion';
      case _i13.DocumentVersionList():
        return 'DocumentVersionList';
      case _i14.DocumentVersionListWithOperations():
        return 'DocumentVersionListWithOperations';
      case _i15.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i16.DocumentVersionWithOperations():
        return 'DocumentVersionWithOperations';
      case _i17.MediaAsset():
        return 'MediaAsset';
      case _i18.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
      case _i19.Project():
        return 'Project';
      case _i20.ProjectList():
        return 'ProjectList';
      case _i21.User():
        return 'User';
    }
    className = _i26.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    className = _i27.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
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
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i4.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'Deployment') {
      return deserialize<_i5.Deployment>(data['data']);
    }
    if (dataClassName == 'DeploymentStatus') {
      return deserialize<_i6.DeploymentStatus>(data['data']);
    }
    if (dataClassName == 'Document') {
      return deserialize<_i7.Document>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i8.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i9.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentData') {
      return deserialize<_i10.DocumentData>(data['data']);
    }
    if (dataClassName == 'DocumentList') {
      return deserialize<_i11.DocumentList>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i12.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i13.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'DocumentVersionListWithOperations') {
      return deserialize<_i14.DocumentVersionListWithOperations>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i15.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'DocumentVersionWithOperations') {
      return deserialize<_i16.DocumentVersionWithOperations>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i17.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i18.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i19.Project>(data['data']);
    }
    if (dataClassName == 'ProjectList') {
      return deserialize<_i20.ProjectList>(data['data']);
    }
    if (dataClassName == 'User') {
      return deserialize<_i21.User>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i26.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i27.Protocol().deserializeByClassName(data);
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
      return _i26.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i27.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
