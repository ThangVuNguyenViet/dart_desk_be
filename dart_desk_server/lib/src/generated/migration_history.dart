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

abstract class MigrationHistory
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  MigrationHistory._({
    _i1.UuidValue? id,
    required this.projectId,
    required this.name,
    required this.documentType,
    DateTime? appliedAt,
    required this.operationsJson,
    required this.report,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       appliedAt = appliedAt ?? DateTime.now();

  factory MigrationHistory({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String documentType,
    DateTime? appliedAt,
    required String operationsJson,
    required String report,
  }) = _MigrationHistoryImpl;

  factory MigrationHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return MigrationHistory(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      name: jsonSerialization['name'] as String,
      documentType: jsonSerialization['documentType'] as String,
      appliedAt: jsonSerialization['appliedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['appliedAt']),
      operationsJson: jsonSerialization['operationsJson'] as String,
      report: jsonSerialization['report'] as String,
    );
  }

  static final t = MigrationHistoryTable();

  static const db = MigrationHistoryRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String name;

  String documentType;

  DateTime appliedAt;

  String operationsJson;

  String report;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [MigrationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MigrationHistory copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? documentType,
    DateTime? appliedAt,
    String? operationsJson,
    String? report,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MigrationHistory',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'documentType': documentType,
      'appliedAt': appliedAt.toJson(),
      'operationsJson': operationsJson,
      'report': report,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MigrationHistory',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'documentType': documentType,
      'appliedAt': appliedAt.toJson(),
      'operationsJson': operationsJson,
      'report': report,
    };
  }

  static MigrationHistoryInclude include() {
    return MigrationHistoryInclude._();
  }

  static MigrationHistoryIncludeList includeList({
    _i1.WhereExpressionBuilder<MigrationHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    MigrationHistoryInclude? include,
  }) {
    return MigrationHistoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(MigrationHistory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MigrationHistoryImpl extends MigrationHistory {
  _MigrationHistoryImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String documentType,
    DateTime? appliedAt,
    required String operationsJson,
    required String report,
  }) : super._(
         id: id,
         projectId: projectId,
         name: name,
         documentType: documentType,
         appliedAt: appliedAt,
         operationsJson: operationsJson,
         report: report,
       );

  /// Returns a shallow copy of this [MigrationHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MigrationHistory copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? documentType,
    DateTime? appliedAt,
    String? operationsJson,
    String? report,
  }) {
    return MigrationHistory(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      documentType: documentType ?? this.documentType,
      appliedAt: appliedAt ?? this.appliedAt,
      operationsJson: operationsJson ?? this.operationsJson,
      report: report ?? this.report,
    );
  }
}

class MigrationHistoryUpdateTable
    extends _i1.UpdateTable<MigrationHistoryTable> {
  MigrationHistoryUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> documentType(String value) => _i1.ColumnValue(
    table.documentType,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> appliedAt(DateTime value) =>
      _i1.ColumnValue(
        table.appliedAt,
        value,
      );

  _i1.ColumnValue<String, String> operationsJson(String value) =>
      _i1.ColumnValue(
        table.operationsJson,
        value,
      );

  _i1.ColumnValue<String, String> report(String value) => _i1.ColumnValue(
    table.report,
    value,
  );
}

class MigrationHistoryTable extends _i1.Table<_i1.UuidValue> {
  MigrationHistoryTable({super.tableRelation})
    : super(tableName: 'migration_history') {
    updateTable = MigrationHistoryUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    documentType = _i1.ColumnString(
      'documentType',
      this,
    );
    appliedAt = _i1.ColumnDateTime(
      'appliedAt',
      this,
      hasDefault: true,
    );
    operationsJson = _i1.ColumnString(
      'operationsJson',
      this,
    );
    report = _i1.ColumnString(
      'report',
      this,
    );
  }

  late final MigrationHistoryUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnDateTime appliedAt;

  late final _i1.ColumnString operationsJson;

  late final _i1.ColumnString report;

  @override
  List<_i1.Column> get columns => [
    id,
    projectId,
    name,
    documentType,
    appliedAt,
    operationsJson,
    report,
  ];
}

class MigrationHistoryInclude extends _i1.IncludeObject {
  MigrationHistoryInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => MigrationHistory.t;
}

class MigrationHistoryIncludeList extends _i1.IncludeList {
  MigrationHistoryIncludeList._({
    _i1.WhereExpressionBuilder<MigrationHistoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MigrationHistory.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => MigrationHistory.t;
}

class MigrationHistoryRepository {
  const MigrationHistoryRepository._();

  /// Returns a list of [MigrationHistory]s matching the given query parameters.
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
  Future<List<MigrationHistory>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MigrationHistoryTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MigrationHistory>(
      where: where?.call(MigrationHistory.t),
      orderBy: orderBy?.call(MigrationHistory.t),
      orderByList: orderByList?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MigrationHistory] matching the given query parameters.
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
  Future<MigrationHistory?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MigrationHistoryTable>? where,
    int? offset,
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MigrationHistory>(
      where: where?.call(MigrationHistory.t),
      orderBy: orderBy?.call(MigrationHistory.t),
      orderByList: orderByList?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MigrationHistory] by its [id] or null if no such row exists.
  Future<MigrationHistory?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MigrationHistory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MigrationHistory]s in the list and returns the inserted rows.
  ///
  /// The returned [MigrationHistory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<MigrationHistory>> insert(
    _i1.DatabaseSession session,
    List<MigrationHistory> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<MigrationHistory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [MigrationHistory] and returns the inserted row.
  ///
  /// The returned [MigrationHistory] will have its `id` field set.
  Future<MigrationHistory> insertRow(
    _i1.DatabaseSession session,
    MigrationHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<MigrationHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [MigrationHistory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<MigrationHistory>> update(
    _i1.DatabaseSession session,
    List<MigrationHistory> rows, {
    _i1.ColumnSelections<MigrationHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<MigrationHistory>(
      rows,
      columns: columns?.call(MigrationHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MigrationHistory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MigrationHistory> updateRow(
    _i1.DatabaseSession session,
    MigrationHistory row, {
    _i1.ColumnSelections<MigrationHistoryTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<MigrationHistory>(
      row,
      columns: columns?.call(MigrationHistory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MigrationHistory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MigrationHistory?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<MigrationHistoryUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<MigrationHistory>(
      id,
      columnValues: columnValues(MigrationHistory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MigrationHistory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<MigrationHistory>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<MigrationHistoryUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<MigrationHistoryTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<MigrationHistory>(
      columnValues: columnValues(MigrationHistory.t.updateTable),
      where: where(MigrationHistory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MigrationHistory.t),
      orderByList: orderByList?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [MigrationHistory]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<MigrationHistory>> delete(
    _i1.DatabaseSession session,
    List<MigrationHistory> rows, {
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<MigrationHistory>(
      rows,
      orderBy: orderBy?.call(MigrationHistory.t),
      orderByList: orderByList?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [MigrationHistory].
  Future<MigrationHistory> deleteRow(
    _i1.DatabaseSession session,
    MigrationHistory row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MigrationHistory>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<MigrationHistory>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MigrationHistoryTable> where,
    _i1.OrderByBuilder<MigrationHistoryTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<MigrationHistoryTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<MigrationHistory>(
      where: where(MigrationHistory.t),
      orderBy: orderBy?.call(MigrationHistory.t),
      orderByList: orderByList?.call(MigrationHistory.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<MigrationHistoryTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<MigrationHistory>(
      where: where?.call(MigrationHistory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MigrationHistory] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<MigrationHistoryTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MigrationHistory>(
      where: where(MigrationHistory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
