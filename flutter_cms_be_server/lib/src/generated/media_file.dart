/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class MediaFile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = MediaFileTable();

  static const db = MediaFileRepository._();

  @override
  int? id;

  String fileName;

  String fileType;

  int fileSize;

  String storagePath;

  String publicUrl;

  int? uploadedByUserId;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
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

  static MediaFileInclude include() {
    return MediaFileInclude._();
  }

  static MediaFileIncludeList includeList({
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    MediaFileInclude? include,
  }) {
    return MediaFileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaFile.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(MediaFile.t),
      include: include,
    );
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

class MediaFileTable extends _i1.Table<int?> {
  MediaFileTable({super.tableRelation}) : super(tableName: 'media_files') {
    fileName = _i1.ColumnString(
      'fileName',
      this,
    );
    fileType = _i1.ColumnString(
      'fileType',
      this,
    );
    fileSize = _i1.ColumnInt(
      'fileSize',
      this,
    );
    storagePath = _i1.ColumnString(
      'storagePath',
      this,
    );
    publicUrl = _i1.ColumnString(
      'publicUrl',
      this,
    );
    uploadedByUserId = _i1.ColumnInt(
      'uploadedByUserId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final _i1.ColumnString fileName;

  late final _i1.ColumnString fileType;

  late final _i1.ColumnInt fileSize;

  late final _i1.ColumnString storagePath;

  late final _i1.ColumnString publicUrl;

  late final _i1.ColumnInt uploadedByUserId;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        fileName,
        fileType,
        fileSize,
        storagePath,
        publicUrl,
        uploadedByUserId,
        createdAt,
      ];
}

class MediaFileInclude extends _i1.IncludeObject {
  MediaFileInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => MediaFile.t;
}

class MediaFileIncludeList extends _i1.IncludeList {
  MediaFileIncludeList._({
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MediaFile.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => MediaFile.t;
}

class MediaFileRepository {
  const MediaFileRepository._();

  /// Returns a list of [MediaFile]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<MediaFile>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [MediaFile] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<MediaFile?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [MediaFile] by its [id] or null if no such row exists.
  Future<MediaFile?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<MediaFile>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [MediaFile]s in the list and returns the inserted rows.
  ///
  /// The returned [MediaFile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<MediaFile>> insert(
    _i1.Session session,
    List<MediaFile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<MediaFile>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [MediaFile] and returns the inserted row.
  ///
  /// The returned [MediaFile] will have its `id` field set.
  Future<MediaFile> insertRow(
    _i1.Session session,
    MediaFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MediaFile>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MediaFile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MediaFile>> update(
    _i1.Session session,
    List<MediaFile> rows, {
    _i1.ColumnSelections<MediaFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MediaFile>(
      rows,
      columns: columns?.call(MediaFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MediaFile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MediaFile> updateRow(
    _i1.Session session,
    MediaFile row, {
    _i1.ColumnSelections<MediaFileTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MediaFile>(
      row,
      columns: columns?.call(MediaFile.t),
      transaction: transaction,
    );
  }

  /// Deletes all [MediaFile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MediaFile>> delete(
    _i1.Session session,
    List<MediaFile> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MediaFile>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [MediaFile].
  Future<MediaFile> deleteRow(
    _i1.Session session,
    MediaFile row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MediaFile>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<MediaFile>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<MediaFileTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MediaFile>(
      where: where(MediaFile.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MediaFile>(
      where: where?.call(MediaFile.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
