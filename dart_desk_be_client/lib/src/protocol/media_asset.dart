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
import 'media_asset_metadata_status.dart' as _i2;

abstract class MediaAsset implements _i1.SerializableModel {
  MediaAsset._({
    this.id,
    required this.clientId,
    required this.assetId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.storagePath,
    required this.publicUrl,
    required this.width,
    required this.height,
    required this.hasAlpha,
    required this.blurHash,
    this.lqip,
    this.paletteJson,
    this.exifJson,
    this.locationLat,
    this.locationLng,
    this.uploadedByUserId,
    DateTime? createdAt,
    required this.metadataStatus,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MediaAsset({
    int? id,
    required int clientId,
    required String assetId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    required int width,
    required int height,
    required bool hasAlpha,
    required String blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    DateTime? createdAt,
    required _i2.MediaAssetMetadataStatus metadataStatus,
  }) = _MediaAssetImpl;

  factory MediaAsset.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaAsset(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      assetId: jsonSerialization['assetId'] as String,
      fileName: jsonSerialization['fileName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      publicUrl: jsonSerialization['publicUrl'] as String,
      width: jsonSerialization['width'] as int,
      height: jsonSerialization['height'] as int,
      hasAlpha: _i1.BoolJsonExtension.fromJson(jsonSerialization['hasAlpha']),
      blurHash: jsonSerialization['blurHash'] as String,
      lqip: jsonSerialization['lqip'] as String?,
      paletteJson: jsonSerialization['paletteJson'] as String?,
      exifJson: jsonSerialization['exifJson'] as String?,
      locationLat: (jsonSerialization['locationLat'] as num?)?.toDouble(),
      locationLng: (jsonSerialization['locationLng'] as num?)?.toDouble(),
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      metadataStatus: _i2.MediaAssetMetadataStatus.fromJson(
        (jsonSerialization['metadataStatus'] as String),
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int clientId;

  String assetId;

  String fileName;

  String mimeType;

  int fileSize;

  String storagePath;

  String publicUrl;

  int width;

  int height;

  bool hasAlpha;

  String blurHash;

  String? lqip;

  String? paletteJson;

  String? exifJson;

  double? locationLat;

  double? locationLng;

  int? uploadedByUserId;

  DateTime? createdAt;

  _i2.MediaAssetMetadataStatus metadataStatus;

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaAsset copyWith({
    int? id,
    int? clientId,
    String? assetId,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    int? width,
    int? height,
    bool? hasAlpha,
    String? blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    DateTime? createdAt,
    _i2.MediaAssetMetadataStatus? metadataStatus,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaAsset',
      if (id != null) 'id': id,
      'clientId': clientId,
      'assetId': assetId,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      'width': width,
      'height': height,
      'hasAlpha': hasAlpha,
      'blurHash': blurHash,
      if (lqip != null) 'lqip': lqip,
      if (paletteJson != null) 'paletteJson': paletteJson,
      if (exifJson != null) 'exifJson': exifJson,
      if (locationLat != null) 'locationLat': locationLat,
      if (locationLng != null) 'locationLng': locationLng,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      'metadataStatus': metadataStatus.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaAssetImpl extends MediaAsset {
  _MediaAssetImpl({
    int? id,
    required int clientId,
    required String assetId,
    required String fileName,
    required String mimeType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    required int width,
    required int height,
    required bool hasAlpha,
    required String blurHash,
    String? lqip,
    String? paletteJson,
    String? exifJson,
    double? locationLat,
    double? locationLng,
    int? uploadedByUserId,
    DateTime? createdAt,
    required _i2.MediaAssetMetadataStatus metadataStatus,
  }) : super._(
         id: id,
         clientId: clientId,
         assetId: assetId,
         fileName: fileName,
         mimeType: mimeType,
         fileSize: fileSize,
         storagePath: storagePath,
         publicUrl: publicUrl,
         width: width,
         height: height,
         hasAlpha: hasAlpha,
         blurHash: blurHash,
         lqip: lqip,
         paletteJson: paletteJson,
         exifJson: exifJson,
         locationLat: locationLat,
         locationLng: locationLng,
         uploadedByUserId: uploadedByUserId,
         createdAt: createdAt,
         metadataStatus: metadataStatus,
       );

  /// Returns a shallow copy of this [MediaAsset]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaAsset copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? assetId,
    String? fileName,
    String? mimeType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    int? width,
    int? height,
    bool? hasAlpha,
    String? blurHash,
    Object? lqip = _Undefined,
    Object? paletteJson = _Undefined,
    Object? exifJson = _Undefined,
    Object? locationLat = _Undefined,
    Object? locationLng = _Undefined,
    Object? uploadedByUserId = _Undefined,
    Object? createdAt = _Undefined,
    _i2.MediaAssetMetadataStatus? metadataStatus,
  }) {
    return MediaAsset(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      assetId: assetId ?? this.assetId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      storagePath: storagePath ?? this.storagePath,
      publicUrl: publicUrl ?? this.publicUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      hasAlpha: hasAlpha ?? this.hasAlpha,
      blurHash: blurHash ?? this.blurHash,
      lqip: lqip is String? ? lqip : this.lqip,
      paletteJson: paletteJson is String? ? paletteJson : this.paletteJson,
      exifJson: exifJson is String? ? exifJson : this.exifJson,
      locationLat: locationLat is double? ? locationLat : this.locationLat,
      locationLng: locationLng is double? ? locationLng : this.locationLng,
      uploadedByUserId: uploadedByUserId is int?
          ? uploadedByUserId
          : this.uploadedByUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      metadataStatus: metadataStatus ?? this.metadataStatus,
    );
  }
}
