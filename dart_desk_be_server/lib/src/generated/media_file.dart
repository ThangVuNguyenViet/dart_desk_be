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

abstract class MediaFile
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  MediaFile._({
    this.id,
    required this.clientId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.storagePath,
    required this.publicUrl,
    this.altText,
    this.metadata,
    required this.uploadedByUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MediaFile({
    int? id,
    required int clientId,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    String? altText,
    String? metadata,
    required int uploadedByUserId,
    DateTime? createdAt,
  }) = _MediaFileImpl;

  factory MediaFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaFile(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      fileName: jsonSerialization['fileName'] as String,
      fileType: jsonSerialization['fileType'] as String,
      fileSize: jsonSerialization['fileSize'] as int,
      storagePath: jsonSerialization['storagePath'] as String,
      publicUrl: jsonSerialization['publicUrl'] as String,
      altText: jsonSerialization['altText'] as String?,
      metadata: jsonSerialization['metadata'] as String?,
      uploadedByUserId: jsonSerialization['uploadedByUserId'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MediaFileTable();

  static const db = MediaFileRepository._();

  @override
  int? id;

  int clientId;

  String fileName;

  String fileType;

  int fileSize;

  String storagePath;

  String publicUrl;

  String? altText;

  String? metadata;

  int uploadedByUserId;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MediaFile copyWith({
    int? id,
    int? clientId,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    String? altText,
    String? metadata,
    int? uploadedByUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MediaFile',
      if (id != null) 'id': id,
      'clientId': clientId,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      if (altText != null) 'altText': altText,
      if (metadata != null) 'metadata': metadata,
      'uploadedByUserId': uploadedByUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MediaFile',
      if (id != null) 'id': id,
      'clientId': clientId,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'storagePath': storagePath,
      'publicUrl': publicUrl,
      if (altText != null) 'altText': altText,
      if (metadata != null) 'metadata': metadata,
      'uploadedByUserId': uploadedByUserId,
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
    required int clientId,
    required String fileName,
    required String fileType,
    required int fileSize,
    required String storagePath,
    required String publicUrl,
    String? altText,
    String? metadata,
    required int uploadedByUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         clientId: clientId,
         fileName: fileName,
         fileType: fileType,
         fileSize: fileSize,
         storagePath: storagePath,
         publicUrl: publicUrl,
         altText: altText,
         metadata: metadata,
         uploadedByUserId: uploadedByUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MediaFile copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? storagePath,
    String? publicUrl,
    Object? altText = _Undefined,
    Object? metadata = _Undefined,
    int? uploadedByUserId,
    Object? createdAt = _Undefined,
  }) {
    return MediaFile(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      storagePath: storagePath ?? this.storagePath,
      publicUrl: publicUrl ?? this.publicUrl,
      altText: altText is String? ? altText : this.altText,
      metadata: metadata is String? ? metadata : this.metadata,
      uploadedByUserId: uploadedByUserId ?? this.uploadedByUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class MediaFileUpdateTable extends _i1.UpdateTable<MediaFileTable> {
  MediaFileUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<String, String> fileName(String value) => _i1.ColumnValue(
    table.fileName,
    value,
  );

  _i1.ColumnValue<String, String> fileType(String value) => _i1.ColumnValue(
    table.fileType,
    value,
  );

  _i1.ColumnValue<int, int> fileSize(int value) => _i1.ColumnValue(
    table.fileSize,
    value,
  );

  _i1.ColumnValue<String, String> storagePath(String value) => _i1.ColumnValue(
    table.storagePath,
    value,
  );

  _i1.ColumnValue<String, String> publicUrl(String value) => _i1.ColumnValue(
    table.publicUrl,
    value,
  );

  _i1.ColumnValue<String, String> altText(String? value) => _i1.ColumnValue(
    table.altText,
    value,
  );

  _i1.ColumnValue<String, String> metadata(String? value) => _i1.ColumnValue(
    table.metadata,
    value,
  );

  _i1.ColumnValue<int, int> uploadedByUserId(int value) => _i1.ColumnValue(
    table.uploadedByUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class MediaFileTable extends _i1.Table<int?> {
  MediaFileTable({super.tableRelation}) : super(tableName: 'media_files') {
    updateTable = MediaFileUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
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
    altText = _i1.ColumnString(
      'altText',
      this,
    );
    metadata = _i1.ColumnString(
      'metadata',
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

  late final MediaFileUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString fileName;

  late final _i1.ColumnString fileType;

  late final _i1.ColumnInt fileSize;

  late final _i1.ColumnString storagePath;

  late final _i1.ColumnString publicUrl;

  late final _i1.ColumnString altText;

  late final _i1.ColumnString metadata;

  late final _i1.ColumnInt uploadedByUserId;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    fileName,
    fileType,
    fileSize,
    storagePath,
    publicUrl,
    altText,
    metadata,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MediaFileTable>? where,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MediaFile] by its [id] or null if no such row exists.
  Future<MediaFile?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MediaFile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MediaFile]s in the list and returns the inserted rows.
  ///
  /// The returned [MediaFile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MediaFile>> insert(
    _i1.DatabaseSession session,
    List<MediaFile> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MediaFile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MediaFile] and returns the inserted row.
  ///
  /// The returned [MediaFile] will have its `id` field set.
  Future<MediaFile> insertRow(
    _i1.DatabaseSession session,
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
    _i1.DatabaseSession session,
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
    _i1.DatabaseSession session,
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

  /// Updates a single [MediaFile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MediaFile?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<MediaFileUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MediaFile>(
      id,
      columnValues: columnValues(MediaFile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MediaFile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MediaFile>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MediaFileUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<MediaFileTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MediaFileTable>? orderBy,
    _i1.OrderByListBuilder<MediaFileTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MediaFile>(
      columnValues: columnValues(MediaFile.t.updateTable),
      where: where(MediaFile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MediaFile]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MediaFile>> delete(
    _i1.DatabaseSession session,
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
    _i1.DatabaseSession session,
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
    _i1.DatabaseSession session, {
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
    _i1.DatabaseSession session, {
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

  /// Acquires row-level locks on [MediaFile] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MediaFileTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MediaFile>(
      where: where(MediaFile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
