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
import 'crdt_operation_type.dart' as _i2;

abstract class DocumentCrdtOperation
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  DocumentCrdtOperation._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.hlc,
    required this.nodeId,
    required this.operationType,
    required this.fieldPath,
    this.fieldValue,
    DateTime? createdAt,
    this.createdByUserId,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtOperation({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) = _DocumentCrdtOperationImpl;

  factory DocumentCrdtOperation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DocumentCrdtOperation(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      hlc: jsonSerialization['hlc'] as String,
      nodeId: jsonSerialization['nodeId'] as String,
      operationType: _i2.CrdtOperationType.fromJson(
        (jsonSerialization['operationType'] as String),
      ),
      fieldPath: jsonSerialization['fieldPath'] as String,
      fieldValue: jsonSerialization['fieldValue'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
    );
  }

  static final t = DocumentCrdtOperationTable();

  static const db = DocumentCrdtOperationRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  String hlc;

  String nodeId;

  _i2.CrdtOperationType operationType;

  String fieldPath;

  String? fieldValue;

  DateTime? createdAt;

  _i1.UuidValue? createdByUserId;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [DocumentCrdtOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtOperation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DocumentCrdtOperation',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'hlc': hlc,
      'nodeId': nodeId,
      'operationType': operationType.toJson(),
      'fieldPath': fieldPath,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DocumentCrdtOperation',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'hlc': hlc,
      'nodeId': nodeId,
      'operationType': operationType.toJson(),
      'fieldPath': fieldPath,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
    };
  }

  static DocumentCrdtOperationInclude include() {
    return DocumentCrdtOperationInclude._();
  }

  static DocumentCrdtOperationIncludeList includeList({
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    DocumentCrdtOperationInclude? include,
  }) {
    return DocumentCrdtOperationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentCrdtOperationImpl extends DocumentCrdtOperation {
  _DocumentCrdtOperationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    _i1.UuidValue? createdByUserId,
  }) : super._(
         id: id,
         documentId: documentId,
         hlc: hlc,
         nodeId: nodeId,
         operationType: operationType,
         fieldPath: fieldPath,
         fieldValue: fieldValue,
         createdAt: createdAt,
         createdByUserId: createdByUserId,
       );

  /// Returns a shallow copy of this [DocumentCrdtOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DocumentCrdtOperation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    Object? fieldValue = _Undefined,
    Object? createdAt = _Undefined,
    Object? createdByUserId = _Undefined,
  }) {
    return DocumentCrdtOperation(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      hlc: hlc ?? this.hlc,
      nodeId: nodeId ?? this.nodeId,
      operationType: operationType ?? this.operationType,
      fieldPath: fieldPath ?? this.fieldPath,
      fieldValue: fieldValue is String? ? fieldValue : this.fieldValue,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
    );
  }
}

class DocumentCrdtOperationUpdateTable
    extends _i1.UpdateTable<DocumentCrdtOperationTable> {
  DocumentCrdtOperationUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> documentId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.documentId,
    value,
  );

  _i1.ColumnValue<String, String> hlc(String value) => _i1.ColumnValue(
    table.hlc,
    value,
  );

  _i1.ColumnValue<String, String> nodeId(String value) => _i1.ColumnValue(
    table.nodeId,
    value,
  );

  _i1.ColumnValue<_i2.CrdtOperationType, _i2.CrdtOperationType> operationType(
    _i2.CrdtOperationType value,
  ) => _i1.ColumnValue(
    table.operationType,
    value,
  );

  _i1.ColumnValue<String, String> fieldPath(String value) => _i1.ColumnValue(
    table.fieldPath,
    value,
  );

  _i1.ColumnValue<String, String> fieldValue(String? value) => _i1.ColumnValue(
    table.fieldValue,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> createdByUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );
}

class DocumentCrdtOperationTable extends _i1.Table<_i1.UuidValue> {
  DocumentCrdtOperationTable({super.tableRelation})
    : super(tableName: 'document_crdt_operations') {
    updateTable = DocumentCrdtOperationUpdateTable(this);
    documentId = _i1.ColumnUuid(
      'documentId',
      this,
    );
    hlc = _i1.ColumnString(
      'hlc',
      this,
    );
    nodeId = _i1.ColumnString(
      'nodeId',
      this,
    );
    operationType = _i1.ColumnEnum(
      'operationType',
      this,
      _i1.EnumSerialization.byName,
    );
    fieldPath = _i1.ColumnString(
      'fieldPath',
      this,
    );
    fieldValue = _i1.ColumnString(
      'fieldValue',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    createdByUserId = _i1.ColumnUuid(
      'createdByUserId',
      this,
    );
  }

  late final DocumentCrdtOperationUpdateTable updateTable;

  late final _i1.ColumnUuid documentId;

  late final _i1.ColumnString hlc;

  late final _i1.ColumnString nodeId;

  late final _i1.ColumnEnum<_i2.CrdtOperationType> operationType;

  late final _i1.ColumnString fieldPath;

  late final _i1.ColumnString fieldValue;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnUuid createdByUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    documentId,
    hlc,
    nodeId,
    operationType,
    fieldPath,
    fieldValue,
    createdAt,
    createdByUserId,
  ];
}

class DocumentCrdtOperationInclude extends _i1.IncludeObject {
  DocumentCrdtOperationInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => DocumentCrdtOperation.t;
}

class DocumentCrdtOperationIncludeList extends _i1.IncludeList {
  DocumentCrdtOperationIncludeList._({
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DocumentCrdtOperation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => DocumentCrdtOperation.t;
}

class DocumentCrdtOperationRepository {
  const DocumentCrdtOperationRepository._();

  /// Returns a list of [DocumentCrdtOperation]s matching the given query parameters.
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
  Future<List<DocumentCrdtOperation>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DocumentCrdtOperation>(
      where: where?.call(DocumentCrdtOperation.t),
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [DocumentCrdtOperation] matching the given query parameters.
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
  Future<DocumentCrdtOperation?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DocumentCrdtOperation>(
      where: where?.call(DocumentCrdtOperation.t),
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DocumentCrdtOperation] by its [id] or null if no such row exists.
  Future<DocumentCrdtOperation?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DocumentCrdtOperation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DocumentCrdtOperation]s in the list and returns the inserted rows.
  ///
  /// The returned [DocumentCrdtOperation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<DocumentCrdtOperation>> insert(
    _i1.DatabaseSession session,
    List<DocumentCrdtOperation> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<DocumentCrdtOperation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [DocumentCrdtOperation] and returns the inserted row.
  ///
  /// The returned [DocumentCrdtOperation] will have its `id` field set.
  Future<DocumentCrdtOperation> insertRow(
    _i1.DatabaseSession session,
    DocumentCrdtOperation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DocumentCrdtOperation>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DocumentCrdtOperation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DocumentCrdtOperation>> update(
    _i1.DatabaseSession session,
    List<DocumentCrdtOperation> rows, {
    _i1.ColumnSelections<DocumentCrdtOperationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DocumentCrdtOperation>(
      rows,
      columns: columns?.call(DocumentCrdtOperation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentCrdtOperation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DocumentCrdtOperation> updateRow(
    _i1.DatabaseSession session,
    DocumentCrdtOperation row, {
    _i1.ColumnSelections<DocumentCrdtOperationTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DocumentCrdtOperation>(
      row,
      columns: columns?.call(DocumentCrdtOperation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DocumentCrdtOperation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DocumentCrdtOperation?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<DocumentCrdtOperationUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DocumentCrdtOperation>(
      id,
      columnValues: columnValues(DocumentCrdtOperation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DocumentCrdtOperation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DocumentCrdtOperation>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DocumentCrdtOperationUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<DocumentCrdtOperationTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DocumentCrdtOperation>(
      columnValues: columnValues(DocumentCrdtOperation.t.updateTable),
      where: where(DocumentCrdtOperation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DocumentCrdtOperation]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DocumentCrdtOperation>> delete(
    _i1.DatabaseSession session,
    List<DocumentCrdtOperation> rows, {
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DocumentCrdtOperation>(
      rows,
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [DocumentCrdtOperation].
  Future<DocumentCrdtOperation> deleteRow(
    _i1.DatabaseSession session,
    DocumentCrdtOperation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DocumentCrdtOperation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<DocumentCrdtOperation>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentCrdtOperationTable> where,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DocumentCrdtOperation>(
      where: where(DocumentCrdtOperation.t),
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DocumentCrdtOperation>(
      where: where?.call(DocumentCrdtOperation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DocumentCrdtOperation] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentCrdtOperationTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DocumentCrdtOperation>(
      where: where(DocumentCrdtOperation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
