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

abstract class CmsDocumentData
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsDocumentData._({
    this.id,
    required this.documentType,
    required this.data,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsDocumentData({
    int? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) = _CmsDocumentDataImpl;

  factory CmsDocumentData.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsDocumentData(
      id: jsonSerialization['id'] as int?,
      documentType: jsonSerialization['documentType'] as String,
      data: jsonSerialization['data'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
      updatedByUserId: jsonSerialization['updatedByUserId'] as int?,
    );
  }

  static final t = CmsDocumentDataTable();

  static const db = CmsDocumentDataRepository._();

  @override
  int? id;

  String documentType;

  String data;

  DateTime? createdAt;

  DateTime? updatedAt;

  int? createdByUserId;

  int? updatedByUserId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsDocumentData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsDocumentData copyWith({
    int? id,
    String? documentType,
    String? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsDocumentData',
      if (id != null) 'id': id,
      'documentType': documentType,
      'data': data,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsDocumentData',
      if (id != null) 'id': id,
      'documentType': documentType,
      'data': data,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  static CmsDocumentDataInclude include() {
    return CmsDocumentDataInclude._();
  }

  static CmsDocumentDataIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsDocumentDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentDataTable>? orderByList,
    CmsDocumentDataInclude? include,
  }) {
    return CmsDocumentDataIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDocumentData.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsDocumentData.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsDocumentDataImpl extends CmsDocumentData {
  _CmsDocumentDataImpl({
    int? id,
    required String documentType,
    required String data,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  }) : super._(
         id: id,
         documentType: documentType,
         data: data,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserId: createdByUserId,
         updatedByUserId: updatedByUserId,
       );

  /// Returns a shallow copy of this [CmsDocumentData]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsDocumentData copyWith({
    Object? id = _Undefined,
    String? documentType,
    String? data,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdByUserId = _Undefined,
    Object? updatedByUserId = _Undefined,
  }) {
    return CmsDocumentData(
      id: id is int? ? id : this.id,
      documentType: documentType ?? this.documentType,
      data: data ?? this.data,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId is int?
          ? createdByUserId
          : this.createdByUserId,
      updatedByUserId: updatedByUserId is int?
          ? updatedByUserId
          : this.updatedByUserId,
    );
  }
}

class CmsDocumentDataUpdateTable extends _i1.UpdateTable<CmsDocumentDataTable> {
  CmsDocumentDataUpdateTable(super.table);

  _i1.ColumnValue<String, String> documentType(String value) => _i1.ColumnValue(
    table.documentType,
    value,
  );

  _i1.ColumnValue<String, String> data(String value) => _i1.ColumnValue(
    table.data,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<int, int> createdByUserId(int? value) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );

  _i1.ColumnValue<int, int> updatedByUserId(int? value) => _i1.ColumnValue(
    table.updatedByUserId,
    value,
  );
}

class CmsDocumentDataTable extends _i1.Table<int?> {
  CmsDocumentDataTable({super.tableRelation})
    : super(tableName: 'cms_documents_data') {
    updateTable = CmsDocumentDataUpdateTable(this);
    documentType = _i1.ColumnString(
      'documentType',
      this,
    );
    data = _i1.ColumnString(
      'data',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    createdByUserId = _i1.ColumnInt(
      'createdByUserId',
      this,
    );
    updatedByUserId = _i1.ColumnInt(
      'updatedByUserId',
      this,
    );
  }

  late final CmsDocumentDataUpdateTable updateTable;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString data;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserId;

  late final _i1.ColumnInt updatedByUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    documentType,
    data,
    createdAt,
    updatedAt,
    createdByUserId,
    updatedByUserId,
  ];
}

class CmsDocumentDataInclude extends _i1.IncludeObject {
  CmsDocumentDataInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsDocumentData.t;
}

class CmsDocumentDataIncludeList extends _i1.IncludeList {
  CmsDocumentDataIncludeList._({
    _i1.WhereExpressionBuilder<CmsDocumentDataTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsDocumentData.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsDocumentData.t;
}

class CmsDocumentDataRepository {
  const CmsDocumentDataRepository._();

  /// Returns a list of [CmsDocumentData]s matching the given query parameters.
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
  Future<List<CmsDocumentData>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentDataTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentDataTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsDocumentData>(
      where: where?.call(CmsDocumentData.t),
      orderBy: orderBy?.call(CmsDocumentData.t),
      orderByList: orderByList?.call(CmsDocumentData.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsDocumentData] matching the given query parameters.
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
  Future<CmsDocumentData?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentDataTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentDataTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentDataTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsDocumentData>(
      where: where?.call(CmsDocumentData.t),
      orderBy: orderBy?.call(CmsDocumentData.t),
      orderByList: orderByList?.call(CmsDocumentData.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsDocumentData] by its [id] or null if no such row exists.
  Future<CmsDocumentData?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsDocumentData>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsDocumentData]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsDocumentData]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsDocumentData>> insert(
    _i1.DatabaseSession session,
    List<CmsDocumentData> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsDocumentData>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsDocumentData] and returns the inserted row.
  ///
  /// The returned [CmsDocumentData] will have its `id` field set.
  Future<CmsDocumentData> insertRow(
    _i1.DatabaseSession session,
    CmsDocumentData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsDocumentData>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsDocumentData]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsDocumentData>> update(
    _i1.DatabaseSession session,
    List<CmsDocumentData> rows, {
    _i1.ColumnSelections<CmsDocumentDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsDocumentData>(
      rows,
      columns: columns?.call(CmsDocumentData.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDocumentData]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsDocumentData> updateRow(
    _i1.DatabaseSession session,
    CmsDocumentData row, {
    _i1.ColumnSelections<CmsDocumentDataTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsDocumentData>(
      row,
      columns: columns?.call(CmsDocumentData.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDocumentData] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsDocumentData?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CmsDocumentDataUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsDocumentData>(
      id,
      columnValues: columnValues(CmsDocumentData.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsDocumentData]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsDocumentData>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsDocumentDataUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<CmsDocumentDataTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentDataTable>? orderBy,
    _i1.OrderByListBuilder<CmsDocumentDataTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsDocumentData>(
      columnValues: columnValues(CmsDocumentData.t.updateTable),
      where: where(CmsDocumentData.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDocumentData.t),
      orderByList: orderByList?.call(CmsDocumentData.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsDocumentData]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsDocumentData>> delete(
    _i1.DatabaseSession session,
    List<CmsDocumentData> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsDocumentData>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsDocumentData].
  Future<CmsDocumentData> deleteRow(
    _i1.DatabaseSession session,
    CmsDocumentData row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsDocumentData>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsDocumentData>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDocumentDataTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsDocumentData>(
      where: where(CmsDocumentData.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentDataTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsDocumentData>(
      where: where?.call(CmsDocumentData.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsDocumentData] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDocumentDataTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsDocumentData>(
      where: where(CmsDocumentData.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
