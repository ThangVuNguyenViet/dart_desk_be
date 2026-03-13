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

abstract class DocumentCrdtSnapshot
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DocumentCrdtSnapshot._({
    this.id,
    required this.documentId,
    required this.snapshotHlc,
    required this.snapshotData,
    required this.operationCountAtSnapshot,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtSnapshot({
    int? id,
    required int documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) = _DocumentCrdtSnapshotImpl;

  factory DocumentCrdtSnapshot.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentCrdtSnapshot(
      id: jsonSerialization['id'] as int?,
      documentId: jsonSerialization['documentId'] as int,
      snapshotHlc: jsonSerialization['snapshotHlc'] as String,
      snapshotData: jsonSerialization['snapshotData'] as String,
      operationCountAtSnapshot:
          jsonSerialization['operationCountAtSnapshot'] as int,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = DocumentCrdtSnapshotTable();

  static const db = DocumentCrdtSnapshotRepository._();

  @override
  int? id;

  int documentId;

  String snapshotHlc;

  String snapshotData;

  int operationCountAtSnapshot;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtSnapshot copyWith({
    int? id,
    int? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentCrdtSnapshot',
      if (id != null) 'id': id,
      'documentId': documentId,
      'snapshotHlc': snapshotHlc,
      'snapshotData': snapshotData,
      'operationCountAtSnapshot': operationCountAtSnapshot,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentCrdtSnapshot',
      if (id != null) 'id': id,
      'documentId': documentId,
      'snapshotHlc': snapshotHlc,
      'snapshotData': snapshotData,
      'operationCountAtSnapshot': operationCountAtSnapshot,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static DocumentCrdtSnapshotInclude include() {
    return DocumentCrdtSnapshotInclude._();
  }

  static DocumentCrdtSnapshotIncludeList includeList({
    _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtSnapshotTable>? orderByList,
    DocumentCrdtSnapshotInclude? include,
  }) {
    return DocumentCrdtSnapshotIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentCrdtSnapshot.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DocumentCrdtSnapshot.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentCrdtSnapshotImpl extends DocumentCrdtSnapshot {
  _DocumentCrdtSnapshotImpl({
    int? id,
    required int documentId,
    required String snapshotHlc,
    required String snapshotData,
    required int operationCountAtSnapshot,
    DateTime? createdAt,
  }) : super._(
         id: id,
         documentId: documentId,
         snapshotHlc: snapshotHlc,
         snapshotData: snapshotData,
         operationCountAtSnapshot: operationCountAtSnapshot,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DocumentCrdtSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentCrdtSnapshot copyWith({
    Object? id = _Undefined,
    int? documentId,
    String? snapshotHlc,
    String? snapshotData,
    int? operationCountAtSnapshot,
    Object? createdAt = _Undefined,
  }) {
    return DocumentCrdtSnapshot(
      id: id is int? ? id : this.id,
      documentId: documentId ?? this.documentId,
      snapshotHlc: snapshotHlc ?? this.snapshotHlc,
      snapshotData: snapshotData ?? this.snapshotData,
      operationCountAtSnapshot:
          operationCountAtSnapshot ?? this.operationCountAtSnapshot,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class DocumentCrdtSnapshotUpdateTable
    extends _i1.UpdateTable<DocumentCrdtSnapshotTable> {
  DocumentCrdtSnapshotUpdateTable(super.table);

  _i1.ColumnValue<int, int> documentId(int value) => _i1.ColumnValue(
    table.documentId,
    value,
  );

  _i1.ColumnValue<String, String> snapshotHlc(String value) => _i1.ColumnValue(
    table.snapshotHlc,
    value,
  );

  _i1.ColumnValue<String, String> snapshotData(String value) => _i1.ColumnValue(
    table.snapshotData,
    value,
  );

  _i1.ColumnValue<int, int> operationCountAtSnapshot(int value) =>
      _i1.ColumnValue(
        table.operationCountAtSnapshot,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DocumentCrdtSnapshotTable extends _i1.Table<int?> {
  DocumentCrdtSnapshotTable({super.tableRelation})
    : super(tableName: 'document_crdt_snapshots') {
    updateTable = DocumentCrdtSnapshotUpdateTable(this);
    documentId = _i1.ColumnInt(
      'documentId',
      this,
    );
    snapshotHlc = _i1.ColumnString(
      'snapshotHlc',
      this,
    );
    snapshotData = _i1.ColumnString(
      'snapshotData',
      this,
    );
    operationCountAtSnapshot = _i1.ColumnInt(
      'operationCountAtSnapshot',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final DocumentCrdtSnapshotUpdateTable updateTable;

  late final _i1.ColumnInt documentId;

  late final _i1.ColumnString snapshotHlc;

  late final _i1.ColumnString snapshotData;

  late final _i1.ColumnInt operationCountAtSnapshot;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    documentId,
    snapshotHlc,
    snapshotData,
    operationCountAtSnapshot,
    createdAt,
  ];
}

class DocumentCrdtSnapshotInclude extends _i1.IncludeObject {
  DocumentCrdtSnapshotInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DocumentCrdtSnapshot.t;
}

class DocumentCrdtSnapshotIncludeList extends _i1.IncludeList {
  DocumentCrdtSnapshotIncludeList._({
    _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DocumentCrdtSnapshot.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DocumentCrdtSnapshot.t;
}

class DocumentCrdtSnapshotRepository {
  const DocumentCrdtSnapshotRepository._();

  /// Returns a list of [DocumentCrdtSnapshot]s matching the given query parameters.
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
  Future<List<DocumentCrdtSnapshot>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DocumentCrdtSnapshot>(
      where: where?.call(DocumentCrdtSnapshot.t),
      orderBy: orderBy?.call(DocumentCrdtSnapshot.t),
      orderByList: orderByList?.call(DocumentCrdtSnapshot.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DocumentCrdtSnapshot] matching the given query parameters.
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
  Future<DocumentCrdtSnapshot?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable>? where,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtSnapshotTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtSnapshotTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DocumentCrdtSnapshot>(
      where: where?.call(DocumentCrdtSnapshot.t),
      orderBy: orderBy?.call(DocumentCrdtSnapshot.t),
      orderByList: orderByList?.call(DocumentCrdtSnapshot.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DocumentCrdtSnapshot] by its [id] or null if no such row exists.
  Future<DocumentCrdtSnapshot?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DocumentCrdtSnapshot>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DocumentCrdtSnapshot]s in the list and returns the inserted rows.
  ///
  /// The returned [DocumentCrdtSnapshot]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<DocumentCrdtSnapshot>> insert(
    _i1.DatabaseSession session,
    List<DocumentCrdtSnapshot> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<DocumentCrdtSnapshot>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [DocumentCrdtSnapshot] and returns the inserted row.
  ///
  /// The returned [DocumentCrdtSnapshot] will have its `id` field set.
  Future<DocumentCrdtSnapshot> insertRow(
    _i1.DatabaseSession session,
    DocumentCrdtSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DocumentCrdtSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DocumentCrdtSnapshot]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DocumentCrdtSnapshot>> update(
    _i1.DatabaseSession session,
    List<DocumentCrdtSnapshot> rows, {
    _i1.ColumnSelections<DocumentCrdtSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DocumentCrdtSnapshot>(
      rows,
      columns: columns?.call(DocumentCrdtSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentCrdtSnapshot]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DocumentCrdtSnapshot> updateRow(
    _i1.DatabaseSession session,
    DocumentCrdtSnapshot row, {
    _i1.ColumnSelections<DocumentCrdtSnapshotTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DocumentCrdtSnapshot>(
      row,
      columns: columns?.call(DocumentCrdtSnapshot.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentCrdtSnapshot] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DocumentCrdtSnapshot?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<DocumentCrdtSnapshotUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DocumentCrdtSnapshot>(
      id,
      columnValues: columnValues(DocumentCrdtSnapshot.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DocumentCrdtSnapshot]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DocumentCrdtSnapshot>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DocumentCrdtSnapshotUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtSnapshotTable>? orderBy,
    _i1.OrderByListBuilder<DocumentCrdtSnapshotTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DocumentCrdtSnapshot>(
      columnValues: columnValues(DocumentCrdtSnapshot.t.updateTable),
      where: where(DocumentCrdtSnapshot.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentCrdtSnapshot.t),
      orderByList: orderByList?.call(DocumentCrdtSnapshot.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DocumentCrdtSnapshot]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DocumentCrdtSnapshot>> delete(
    _i1.DatabaseSession session,
    List<DocumentCrdtSnapshot> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DocumentCrdtSnapshot>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DocumentCrdtSnapshot].
  Future<DocumentCrdtSnapshot> deleteRow(
    _i1.DatabaseSession session,
    DocumentCrdtSnapshot row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DocumentCrdtSnapshot>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DocumentCrdtSnapshot>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DocumentCrdtSnapshot>(
      where: where(DocumentCrdtSnapshot.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DocumentCrdtSnapshot>(
      where: where?.call(DocumentCrdtSnapshot.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DocumentCrdtSnapshot] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentCrdtSnapshotTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DocumentCrdtSnapshot>(
      where: where(DocumentCrdtSnapshot.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
