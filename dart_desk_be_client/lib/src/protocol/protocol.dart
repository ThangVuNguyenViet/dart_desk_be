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
import 'client_with_token.dart' as _i2;
import 'cms_api_token.dart' as _i3;
import 'cms_api_token_with_value.dart' as _i4;
import 'cms_client.dart' as _i5;
import 'cms_client_list.dart' as _i6;
import 'cms_deployment.dart' as _i7;
import 'cms_document.dart' as _i8;
import 'cms_document_data.dart' as _i9;
import 'cms_user.dart' as _i10;
import 'crdt_operation_type.dart' as _i11;
import 'deployment_status.dart' as _i12;
import 'document_crdt_operation.dart' as _i13;
import 'document_crdt_snapshot.dart' as _i14;
import 'document_list.dart' as _i15;
import 'document_version.dart' as _i16;
import 'document_version_list.dart' as _i17;
import 'document_version_list_with_operations.dart' as _i18;
import 'document_version_status.dart' as _i19;
import 'document_version_with_operations.dart' as _i20;
import 'media_asset.dart' as _i21;
import 'media_asset_metadata_status.dart' as _i22;
import 'package:dart_desk_be_client/src/protocol/cms_api_token.dart' as _i23;
import 'package:dart_desk_be_client/src/protocol/cms_deployment.dart' as _i24;
import 'package:dart_desk_be_client/src/protocol/document_crdt_operation.dart'
    as _i25;
import 'package:dart_desk_be_client/src/protocol/cms_client.dart' as _i26;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i27;
import 'package:serverpod_admin_client/serverpod_admin_client.dart' as _i28;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i29;
export 'client_with_token.dart';
export 'cms_api_token.dart';
export 'cms_api_token_with_value.dart';
export 'cms_client.dart';
export 'cms_client_list.dart';
export 'cms_deployment.dart';
export 'cms_document.dart';
export 'cms_document_data.dart';
export 'cms_user.dart';
export 'crdt_operation_type.dart';
export 'deployment_status.dart';
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

    if (t == _i2.ClientWithToken) {
      return _i2.ClientWithToken.fromJson(data) as T;
    }
    if (t == _i3.CmsApiToken) {
      return _i3.CmsApiToken.fromJson(data) as T;
    }
    if (t == _i4.CmsApiTokenWithValue) {
      return _i4.CmsApiTokenWithValue.fromJson(data) as T;
    }
    if (t == _i5.CmsClient) {
      return _i5.CmsClient.fromJson(data) as T;
    }
    if (t == _i6.CmsClientList) {
      return _i6.CmsClientList.fromJson(data) as T;
    }
    if (t == _i7.CmsDeployment) {
      return _i7.CmsDeployment.fromJson(data) as T;
    }
    if (t == _i8.CmsDocument) {
      return _i8.CmsDocument.fromJson(data) as T;
    }
    if (t == _i9.CmsDocumentData) {
      return _i9.CmsDocumentData.fromJson(data) as T;
    }
    if (t == _i10.CmsUser) {
      return _i10.CmsUser.fromJson(data) as T;
    }
    if (t == _i11.CrdtOperationType) {
      return _i11.CrdtOperationType.fromJson(data) as T;
    }
    if (t == _i12.DeploymentStatus) {
      return _i12.DeploymentStatus.fromJson(data) as T;
    }
    if (t == _i13.DocumentCrdtOperation) {
      return _i13.DocumentCrdtOperation.fromJson(data) as T;
    }
    if (t == _i14.DocumentCrdtSnapshot) {
      return _i14.DocumentCrdtSnapshot.fromJson(data) as T;
    }
    if (t == _i15.DocumentList) {
      return _i15.DocumentList.fromJson(data) as T;
    }
    if (t == _i16.DocumentVersion) {
      return _i16.DocumentVersion.fromJson(data) as T;
    }
    if (t == _i17.DocumentVersionList) {
      return _i17.DocumentVersionList.fromJson(data) as T;
    }
    if (t == _i18.DocumentVersionListWithOperations) {
      return _i18.DocumentVersionListWithOperations.fromJson(data) as T;
    }
    if (t == _i19.DocumentVersionStatus) {
      return _i19.DocumentVersionStatus.fromJson(data) as T;
    }
    if (t == _i20.DocumentVersionWithOperations) {
      return _i20.DocumentVersionWithOperations.fromJson(data) as T;
    }
    if (t == _i21.MediaAsset) {
      return _i21.MediaAsset.fromJson(data) as T;
    }
    if (t == _i22.MediaAssetMetadataStatus) {
      return _i22.MediaAssetMetadataStatus.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ClientWithToken?>()) {
      return (data != null ? _i2.ClientWithToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.CmsApiToken?>()) {
      return (data != null ? _i3.CmsApiToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CmsApiTokenWithValue?>()) {
      return (data != null ? _i4.CmsApiTokenWithValue.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i5.CmsClient?>()) {
      return (data != null ? _i5.CmsClient.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CmsClientList?>()) {
      return (data != null ? _i6.CmsClientList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.CmsDeployment?>()) {
      return (data != null ? _i7.CmsDeployment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.CmsDocument?>()) {
      return (data != null ? _i8.CmsDocument.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CmsDocumentData?>()) {
      return (data != null ? _i9.CmsDocumentData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.CmsUser?>()) {
      return (data != null ? _i10.CmsUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.CrdtOperationType?>()) {
      return (data != null ? _i11.CrdtOperationType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.DeploymentStatus?>()) {
      return (data != null ? _i12.DeploymentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.DocumentCrdtOperation?>()) {
      return (data != null ? _i13.DocumentCrdtOperation.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.DocumentCrdtSnapshot?>()) {
      return (data != null ? _i14.DocumentCrdtSnapshot.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.DocumentList?>()) {
      return (data != null ? _i15.DocumentList.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.DocumentVersion?>()) {
      return (data != null ? _i16.DocumentVersion.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.DocumentVersionList?>()) {
      return (data != null ? _i17.DocumentVersionList.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.DocumentVersionListWithOperations?>()) {
      return (data != null
              ? _i18.DocumentVersionListWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.DocumentVersionStatus?>()) {
      return (data != null ? _i19.DocumentVersionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i20.DocumentVersionWithOperations?>()) {
      return (data != null
              ? _i20.DocumentVersionWithOperations.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i21.MediaAsset?>()) {
      return (data != null ? _i21.MediaAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.MediaAssetMetadataStatus?>()) {
      return (data != null
              ? _i22.MediaAssetMetadataStatus.fromJson(data)
              : null)
          as T;
    }
    if (t == List<_i5.CmsClient>) {
      return (data as List).map((e) => deserialize<_i5.CmsClient>(e)).toList()
          as T;
    }
    if (t == List<_i8.CmsDocument>) {
      return (data as List).map((e) => deserialize<_i8.CmsDocument>(e)).toList()
          as T;
    }
    if (t == List<_i16.DocumentVersion>) {
      return (data as List)
              .map((e) => deserialize<_i16.DocumentVersion>(e))
              .toList()
          as T;
    }
    if (t == List<_i20.DocumentVersionWithOperations>) {
      return (data as List)
              .map((e) => deserialize<_i20.DocumentVersionWithOperations>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i13.DocumentCrdtOperation>(e))
              .toList()
          as T;
    }
    if (t == List<_i23.CmsApiToken>) {
      return (data as List)
              .map((e) => deserialize<_i23.CmsApiToken>(e))
              .toList()
          as T;
    }
    if (t == List<_i24.CmsDeployment>) {
      return (data as List)
              .map((e) => deserialize<_i24.CmsDeployment>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.DocumentCrdtOperation>) {
      return (data as List)
              .map((e) => deserialize<_i25.DocumentCrdtOperation>(e))
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
    if (t == List<_i26.CmsClient>) {
      return (data as List).map((e) => deserialize<_i26.CmsClient>(e)).toList()
          as T;
    }
    try {
      return _i27.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i28.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i29.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ClientWithToken => 'ClientWithToken',
      _i3.CmsApiToken => 'CmsApiToken',
      _i4.CmsApiTokenWithValue => 'CmsApiTokenWithValue',
      _i5.CmsClient => 'CmsClient',
      _i6.CmsClientList => 'CmsClientList',
      _i7.CmsDeployment => 'CmsDeployment',
      _i8.CmsDocument => 'CmsDocument',
      _i9.CmsDocumentData => 'CmsDocumentData',
      _i10.CmsUser => 'CmsUser',
      _i11.CrdtOperationType => 'CrdtOperationType',
      _i12.DeploymentStatus => 'DeploymentStatus',
      _i13.DocumentCrdtOperation => 'DocumentCrdtOperation',
      _i14.DocumentCrdtSnapshot => 'DocumentCrdtSnapshot',
      _i15.DocumentList => 'DocumentList',
      _i16.DocumentVersion => 'DocumentVersion',
      _i17.DocumentVersionList => 'DocumentVersionList',
      _i18.DocumentVersionListWithOperations =>
        'DocumentVersionListWithOperations',
      _i19.DocumentVersionStatus => 'DocumentVersionStatus',
      _i20.DocumentVersionWithOperations => 'DocumentVersionWithOperations',
      _i21.MediaAsset => 'MediaAsset',
      _i22.MediaAssetMetadataStatus => 'MediaAssetMetadataStatus',
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
      case _i2.ClientWithToken():
        return 'ClientWithToken';
      case _i3.CmsApiToken():
        return 'CmsApiToken';
      case _i4.CmsApiTokenWithValue():
        return 'CmsApiTokenWithValue';
      case _i5.CmsClient():
        return 'CmsClient';
      case _i6.CmsClientList():
        return 'CmsClientList';
      case _i7.CmsDeployment():
        return 'CmsDeployment';
      case _i8.CmsDocument():
        return 'CmsDocument';
      case _i9.CmsDocumentData():
        return 'CmsDocumentData';
      case _i10.CmsUser():
        return 'CmsUser';
      case _i11.CrdtOperationType():
        return 'CrdtOperationType';
      case _i12.DeploymentStatus():
        return 'DeploymentStatus';
      case _i13.DocumentCrdtOperation():
        return 'DocumentCrdtOperation';
      case _i14.DocumentCrdtSnapshot():
        return 'DocumentCrdtSnapshot';
      case _i15.DocumentList():
        return 'DocumentList';
      case _i16.DocumentVersion():
        return 'DocumentVersion';
      case _i17.DocumentVersionList():
        return 'DocumentVersionList';
      case _i18.DocumentVersionListWithOperations():
        return 'DocumentVersionListWithOperations';
      case _i19.DocumentVersionStatus():
        return 'DocumentVersionStatus';
      case _i20.DocumentVersionWithOperations():
        return 'DocumentVersionWithOperations';
      case _i21.MediaAsset():
        return 'MediaAsset';
      case _i22.MediaAssetMetadataStatus():
        return 'MediaAssetMetadataStatus';
    }
    className = _i27.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i28.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_admin.$className';
    }
    className = _i29.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'ClientWithToken') {
      return deserialize<_i2.ClientWithToken>(data['data']);
    }
    if (dataClassName == 'CmsApiToken') {
      return deserialize<_i3.CmsApiToken>(data['data']);
    }
    if (dataClassName == 'CmsApiTokenWithValue') {
      return deserialize<_i4.CmsApiTokenWithValue>(data['data']);
    }
    if (dataClassName == 'CmsClient') {
      return deserialize<_i5.CmsClient>(data['data']);
    }
    if (dataClassName == 'CmsClientList') {
      return deserialize<_i6.CmsClientList>(data['data']);
    }
    if (dataClassName == 'CmsDeployment') {
      return deserialize<_i7.CmsDeployment>(data['data']);
    }
    if (dataClassName == 'CmsDocument') {
      return deserialize<_i8.CmsDocument>(data['data']);
    }
    if (dataClassName == 'CmsDocumentData') {
      return deserialize<_i9.CmsDocumentData>(data['data']);
    }
    if (dataClassName == 'CmsUser') {
      return deserialize<_i10.CmsUser>(data['data']);
    }
    if (dataClassName == 'CrdtOperationType') {
      return deserialize<_i11.CrdtOperationType>(data['data']);
    }
    if (dataClassName == 'DeploymentStatus') {
      return deserialize<_i12.DeploymentStatus>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtOperation') {
      return deserialize<_i13.DocumentCrdtOperation>(data['data']);
    }
    if (dataClassName == 'DocumentCrdtSnapshot') {
      return deserialize<_i14.DocumentCrdtSnapshot>(data['data']);
    }
    if (dataClassName == 'DocumentList') {
      return deserialize<_i15.DocumentList>(data['data']);
    }
    if (dataClassName == 'DocumentVersion') {
      return deserialize<_i16.DocumentVersion>(data['data']);
    }
    if (dataClassName == 'DocumentVersionList') {
      return deserialize<_i17.DocumentVersionList>(data['data']);
    }
    if (dataClassName == 'DocumentVersionListWithOperations') {
      return deserialize<_i18.DocumentVersionListWithOperations>(data['data']);
    }
    if (dataClassName == 'DocumentVersionStatus') {
      return deserialize<_i19.DocumentVersionStatus>(data['data']);
    }
    if (dataClassName == 'DocumentVersionWithOperations') {
      return deserialize<_i20.DocumentVersionWithOperations>(data['data']);
    }
    if (dataClassName == 'MediaAsset') {
      return deserialize<_i21.MediaAsset>(data['data']);
    }
    if (dataClassName == 'MediaAssetMetadataStatus') {
      return deserialize<_i22.MediaAssetMetadataStatus>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i27.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_admin.')) {
      data['className'] = dataClassName.substring(16);
      return _i28.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i29.Protocol().deserializeByClassName(data);
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
      return _i27.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i28.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i29.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
