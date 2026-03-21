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
import 'document_version_status.dart' as _i2;

abstract class DocumentVersion
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DocumentVersion._({
    this.id,
    required this.documentId,
    required this.versionNumber,
    required this.status,
    this.snapshotHlc,
    int? operationCount,
    this.changeLog,
    this.publishedAt,
    this.scheduledAt,
    this.archivedAt,
    DateTime? createdAt,
    this.createdByUserId,
  }) : operationCount = operationCount ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory DocumentVersion({
    int? id,
    required int documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    int? createdByUserId,
  }) = _DocumentVersionImpl;

  factory DocumentVersion.fromJson(Map<String, dynamic> jsonSerialization) {
    return DocumentVersion(
      id: jsonSerialization['id'] as int?,
      documentId: jsonSerialization['documentId'] as int,
      versionNumber: jsonSerialization['versionNumber'] as int,
      status: _i2.DocumentVersionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      snapshotHlc: jsonSerialization['snapshotHlc'] as String?,
      operationCount: jsonSerialization['operationCount'] as int?,
      changeLog: jsonSerialization['changeLog'] as String?,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
      scheduledAt: jsonSerialization['scheduledAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['scheduledAt'],
            ),
      archivedAt: jsonSerialization['archivedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['archivedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
    );
  }

  static final t = DocumentVersionTable();

  static const db = DocumentVersionRepository._();

  @override
  int? id;

  int documentId;

  int versionNumber;

  _i2.DocumentVersionStatus status;

  String? snapshotHlc;

  int operationCount;

  String? changeLog;

  DateTime? publishedAt;

  DateTime? scheduledAt;

  DateTime? archivedAt;

  DateTime? createdAt;

  int? createdByUserId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DocumentVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentVersion copyWith({
    int? id,
    int? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    int? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentVersion',
      if (id != null) 'id': id,
      'documentId': documentId,
      'versionNumber': versionNumber,
      'status': status.toJson(),
      if (snapshotHlc != null) 'snapshotHlc': snapshotHlc,
      'operationCount': operationCount,
      if (changeLog != null) 'changeLog': changeLog,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentVersion',
      if (id != null) 'id': id,
      'documentId': documentId,
      'versionNumber': versionNumber,
      'status': status.toJson(),
      if (snapshotHlc != null) 'snapshotHlc': snapshotHlc,
      'operationCount': operationCount,
      if (changeLog != null) 'changeLog': changeLog,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt?.toJson(),
      if (archivedAt != null) 'archivedAt': archivedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
    };
  }

  static DocumentVersionInclude include() {
    return DocumentVersionInclude._();
  }

  static DocumentVersionIncludeList includeList({
    _i1.WhereExpressionBuilder<DocumentVersionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentVersionTable>? orderByList,
    DocumentVersionInclude? include,
  }) {
    return DocumentVersionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentVersion.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DocumentVersion.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentVersionImpl extends DocumentVersion {
  _DocumentVersionImpl({
    int? id,
    required int documentId,
    required int versionNumber,
    required _i2.DocumentVersionStatus status,
    String? snapshotHlc,
    int? operationCount,
    String? changeLog,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? archivedAt,
    DateTime? createdAt,
    int? createdByUserId,
  }) : super._(
         id: id,
         documentId: documentId,
         versionNumber: versionNumber,
         status: status,
         snapshotHlc: snapshotHlc,
         operationCount: operationCount,
         changeLog: changeLog,
         publishedAt: publishedAt,
         scheduledAt: scheduledAt,
         archivedAt: archivedAt,
         createdAt: createdAt,
         createdByUserId: createdByUserId,
       );

  /// Returns a shallow copy of this [DocumentVersion]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentVersion copyWith({
    Object? id = _Undefined,
    int? documentId,
    int? versionNumber,
    _i2.DocumentVersionStatus? status,
    Object? snapshotHlc = _Undefined,
    int? operationCount,
    Object? changeLog = _Undefined,
    Object? publishedAt = _Undefined,
    Object? scheduledAt = _Undefined,
    Object? archivedAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? createdByUserId = _Undefined,
  }) {
    return DocumentVersion(
      id: id is int? ? id : this.id,
      documentId: documentId ?? this.documentId,
      versionNumber: versionNumber ?? this.versionNumber,
      status: status ?? this.status,
      snapshotHlc: snapshotHlc is String? ? snapshotHlc : this.snapshotHlc,
      operationCount: operationCount ?? this.operationCount,
      changeLog: changeLog is String? ? changeLog : this.changeLog,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
      scheduledAt: scheduledAt is DateTime? ? scheduledAt : this.scheduledAt,
      archivedAt: archivedAt is DateTime? ? archivedAt : this.archivedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      createdByUserId: createdByUserId is int?
          ? createdByUserId
          : this.createdByUserId,
    );
  }
}

class DocumentVersionUpdateTable extends _i1.UpdateTable<DocumentVersionTable> {
  DocumentVersionUpdateTable(super.table);

  _i1.ColumnValue<int, int> documentId(int value) => _i1.ColumnValue(
    table.documentId,
    value,
  );

  _i1.ColumnValue<int, int> versionNumber(int value) => _i1.ColumnValue(
    table.versionNumber,
    value,
  );

  _i1.ColumnValue<_i2.DocumentVersionStatus, _i2.DocumentVersionStatus> status(
    _i2.DocumentVersionStatus value,
  ) => _i1.ColumnValue(
    table.status,
    value,
  );

  _i1.ColumnValue<String, String> snapshotHlc(String? value) => _i1.ColumnValue(
    table.snapshotHlc,
    value,
  );

  _i1.ColumnValue<int, int> operationCount(int value) => _i1.ColumnValue(
    table.operationCount,
    value,
  );

  _i1.ColumnValue<String, String> changeLog(String? value) => _i1.ColumnValue(
    table.changeLog,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.publishedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> scheduledAt(DateTime? value) =>
      _i1.ColumnValue(
        table.scheduledAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> archivedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.archivedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<int, int> createdByUserId(int? value) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );
}

class DocumentVersionTable extends _i1.Table<int?> {
  DocumentVersionTable({super.tableRelation})
    : super(tableName: 'document_versions') {
    updateTable = DocumentVersionUpdateTable(this);
    documentId = _i1.ColumnInt(
      'documentId',
      this,
    );
    versionNumber = _i1.ColumnInt(
      'versionNumber',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
    snapshotHlc = _i1.ColumnString(
      'snapshotHlc',
      this,
    );
    operationCount = _i1.ColumnInt(
      'operationCount',
      this,
      hasDefault: true,
    );
    changeLog = _i1.ColumnString(
      'changeLog',
      this,
    );
    publishedAt = _i1.ColumnDateTime(
      'publishedAt',
      this,
    );
    scheduledAt = _i1.ColumnDateTime(
      'scheduledAt',
      this,
    );
    archivedAt = _i1.ColumnDateTime(
      'archivedAt',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    createdByUserId = _i1.ColumnInt(
      'createdByUserId',
      this,
    );
  }

  late final DocumentVersionUpdateTable updateTable;

  late final _i1.ColumnInt documentId;

  late final _i1.ColumnInt versionNumber;

  late final _i1.ColumnEnum<_i2.DocumentVersionStatus> status;

  late final _i1.ColumnString snapshotHlc;

  late final _i1.ColumnInt operationCount;

  late final _i1.ColumnString changeLog;

  late final _i1.ColumnDateTime publishedAt;

  late final _i1.ColumnDateTime scheduledAt;

  late final _i1.ColumnDateTime archivedAt;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnInt createdByUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    documentId,
    versionNumber,
    status,
    snapshotHlc,
    operationCount,
    changeLog,
    publishedAt,
    scheduledAt,
    archivedAt,
    createdAt,
    createdByUserId,
  ];
}

class DocumentVersionInclude extends _i1.IncludeObject {
  DocumentVersionInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DocumentVersion.t;
}

class DocumentVersionIncludeList extends _i1.IncludeList {
  DocumentVersionIncludeList._({
    _i1.WhereExpressionBuilder<DocumentVersionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DocumentVersion.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DocumentVersion.t;
}

class DocumentVersionRepository {
  const DocumentVersionRepository._();

  /// Returns a list of [DocumentVersion]s matching the given query parameters.
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
  Future<List<DocumentVersion>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentVersionTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentVersionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DocumentVersion>(
      where: where?.call(DocumentVersion.t),
      orderBy: orderBy?.call(DocumentVersion.t),
      orderByList: orderByList?.call(DocumentVersion.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DocumentVersion] matching the given query parameters.
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
  Future<DocumentVersion?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentVersionTable>? where,
    int? offset,
    _i1.OrderByBuilder<DocumentVersionTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentVersionTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DocumentVersion>(
      where: where?.call(DocumentVersion.t),
      orderBy: orderBy?.call(DocumentVersion.t),
      orderByList: orderByList?.call(DocumentVersion.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DocumentVersion] by its [id] or null if no such row exists.
  Future<DocumentVersion?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DocumentVersion>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DocumentVersion]s in the list and returns the inserted rows.
  ///
  /// The returned [DocumentVersion]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<DocumentVersion>> insert(
    _i1.DatabaseSession session,
    List<DocumentVersion> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<DocumentVersion>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [DocumentVersion] and returns the inserted row.
  ///
  /// The returned [DocumentVersion] will have its `id` field set.
  Future<DocumentVersion> insertRow(
    _i1.DatabaseSession session,
    DocumentVersion row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DocumentVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DocumentVersion]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DocumentVersion>> update(
    _i1.DatabaseSession session,
    List<DocumentVersion> rows, {
    _i1.ColumnSelections<DocumentVersionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DocumentVersion>(
      rows,
      columns: columns?.call(DocumentVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentVersion]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DocumentVersion> updateRow(
    _i1.DatabaseSession session,
    DocumentVersion row, {
    _i1.ColumnSelections<DocumentVersionTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DocumentVersion>(
      row,
      columns: columns?.call(DocumentVersion.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentVersion] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DocumentVersion?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<DocumentVersionUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DocumentVersion>(
      id,
      columnValues: columnValues(DocumentVersion.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DocumentVersion]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DocumentVersion>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DocumentVersionUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DocumentVersionTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentVersionTable>? orderBy,
    _i1.OrderByListBuilder<DocumentVersionTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DocumentVersion>(
      columnValues: columnValues(DocumentVersion.t.updateTable),
      where: where(DocumentVersion.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentVersion.t),
      orderByList: orderByList?.call(DocumentVersion.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DocumentVersion]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DocumentVersion>> delete(
    _i1.DatabaseSession session,
    List<DocumentVersion> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DocumentVersion>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DocumentVersion].
  Future<DocumentVersion> deleteRow(
    _i1.DatabaseSession session,
    DocumentVersion row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DocumentVersion>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DocumentVersion>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentVersionTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DocumentVersion>(
      where: where(DocumentVersion.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentVersionTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DocumentVersion>(
      where: where?.call(DocumentVersion.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DocumentVersion] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentVersionTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DocumentVersion>(
      where: where(DocumentVersion.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
