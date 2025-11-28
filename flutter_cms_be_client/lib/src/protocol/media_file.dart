/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class MediaFile implements _i1.SerializableModel {
  MediaFile._({
    this.id,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.storagePath,
    required this.publicUrl,
    this.uploadedByUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MediaFile({
    int? id,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    int? uploadedByUserId,
    DateTime? createdAt,
  }) = _MediaFileImpl;

  factory MediaFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaFile(
      id: jsonSerialization['id'] as int?,
      fileName: jsonSerialization['fileName'] as String,
      fileType: jsonSerialization['fileType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      publicUrl: jsonSerialization['publicUrl'] as String,
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String fileName;

  String fileType;

  int fileSize;

  String storagePath;

  String publicUrl;

  int? uploadedByUserId;

  DateTime? createdAt;

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaFile copyWith({
    int? id,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    int? uploadedByUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      if (uploadedByUserId != null) 'uploadedByUserId': uploadedByUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MediaFileImpl extends MediaFile {
  _MediaFileImpl({
    int? id,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    int? uploadedByUserId,
    DateTime? createdAt,
  }) : super._(
          id: id,
          fileName: fileName,
          fileType: fileType,
          fileSize: fileSize,
          storagePath: storagePath,
          publicUrl: publicUrl,
          uploadedByUserId: uploadedByUserId,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaFile copyWith({
    Object? id = _Undefined,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    Object? uploadedByUserId = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return MediaFile(
      id: id is int? ? id : this.id,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      storagePath: storagePath ?? this.storagePath,
      publicUrl: publicUrl ?? this.publicUrl,
      uploadedByUserId:
          uploadedByUserId is int? ? uploadedByUserId : this.uploadedByUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
