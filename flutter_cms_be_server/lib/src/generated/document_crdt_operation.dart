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
import 'crdt_operation_type.dart' as _i2;

abstract class DocumentCrdtOperation
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DocumentCrdtOperation._({
    this.id,
    required this.documentId,
    required this.hlc,
    required this.nodeId,
    required this.operationType,
    required this.fieldPath,
    this.fieldValue,
    DateTime? createdAt,
    this.createdByUserId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DocumentCrdtOperation({
    int? id,
    required int documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    int? createdByUserId,
  }) = _DocumentCrdtOperationImpl;

  factory DocumentCrdtOperation.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return DocumentCrdtOperation(
      id: jsonSerialization['id'] as int?,
      documentId: jsonSerialization['documentId'] as int,
      hlc: jsonSerialization['hlc'] as String,
      nodeId: jsonSerialization['nodeId'] as String,
      operationType: _i2.CrdtOperationType.fromJson(
          (jsonSerialization['operationType'] as String)),
      fieldPath: jsonSerialization['fieldPath'] as String,
      fieldValue: jsonSerialization['fieldValue'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
    );
  }

  static final t = DocumentCrdtOperationTable();

  static const db = DocumentCrdtOperationRepository._();

  @override
  int? id;

  int documentId;

  String hlc;

  String nodeId;

  _i2.CrdtOperationType operationType;

  String fieldPath;

  String? fieldValue;

  DateTime? createdAt;

  int? createdByUserId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DocumentCrdtOperation]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DocumentCrdtOperation copyWith({
    int? id,
    int? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    int? createdByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'documentId': documentId,
      'hlc': hlc,
      'nodeId': nodeId,
      'operationType': operationType.toJson(),
      'fieldPath': fieldPath,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'documentId': documentId,
      'hlc': hlc,
      'nodeId': nodeId,
      'operationType': operationType.toJson(),
      'fieldPath': fieldPath,
      if (fieldValue != null) 'fieldValue': fieldValue,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
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
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    DocumentCrdtOperationInclude? include,
  }) {
    return DocumentCrdtOperationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderDescending: orderDescending,
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
    int? id,
    required int documentId,
    required String hlc,
    required String nodeId,
    required _i2.CrdtOperationType operationType,
    required String fieldPath,
    String? fieldValue,
    DateTime? createdAt,
    int? createdByUserId,
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
    Object? id = _Undefined,
    int? documentId,
    String? hlc,
    String? nodeId,
    _i2.CrdtOperationType? operationType,
    String? fieldPath,
    Object? fieldValue = _Undefined,
    Object? createdAt = _Undefined,
    Object? createdByUserId = _Undefined,
  }) {
    return DocumentCrdtOperation(
      id: id is int? ? id : this.id,
      documentId: documentId ?? this.documentId,
      hlc: hlc ?? this.hlc,
      nodeId: nodeId ?? this.nodeId,
      operationType: operationType ?? this.operationType,
      fieldPath: fieldPath ?? this.fieldPath,
      fieldValue: fieldValue is String? ? fieldValue : this.fieldValue,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      createdByUserId:
          createdByUserId is int? ? createdByUserId : this.createdByUserId,
    );
  }
}

class DocumentCrdtOperationTable extends _i1.Table<int?> {
  DocumentCrdtOperationTable({super.tableRelation})
      : super(tableName: 'document_crdt_operations') {
    documentId = _i1.ColumnInt(
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
    createdByUserId = _i1.ColumnInt(
      'createdByUserId',
      this,
    );
  }

  late final _i1.ColumnInt documentId;

  late final _i1.ColumnString hlc;

  late final _i1.ColumnString nodeId;

  late final _i1.ColumnEnum<_i2.CrdtOperationType> operationType;

  late final _i1.ColumnString fieldPath;

  late final _i1.ColumnString fieldValue;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnInt createdByUserId;

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
  _i1.Table<int?> get table => DocumentCrdtOperation.t;
}

class DocumentCrdtOperationIncludeList extends _i1.IncludeList {
  DocumentCrdtOperationIncludeList._({
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DocumentCrdtOperation.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DocumentCrdtOperation.t;
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DocumentCrdtOperation>(
      where: where?.call(DocumentCrdtOperation.t),
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DocumentCrdtOperationTable>? where,
    int? offset,
    _i1.OrderByBuilder<DocumentCrdtOperationTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentCrdtOperationTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DocumentCrdtOperation>(
      where: where?.call(DocumentCrdtOperation.t),
      orderBy: orderBy?.call(DocumentCrdtOperation.t),
      orderByList: orderByList?.call(DocumentCrdtOperation.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DocumentCrdtOperation] by its [id] or null if no such row exists.
  Future<DocumentCrdtOperation?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DocumentCrdtOperation>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DocumentCrdtOperation]s in the list and returns the inserted rows.
  ///
  /// The returned [DocumentCrdtOperation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DocumentCrdtOperation>> insert(
    _i1.Session session,
    List<DocumentCrdtOperation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DocumentCrdtOperation>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DocumentCrdtOperation] and returns the inserted row.
  ///
  /// The returned [DocumentCrdtOperation] will have its `id` field set.
  Future<DocumentCrdtOperation> insertRow(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session,
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

  /// Deletes all [DocumentCrdtOperation]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DocumentCrdtOperation>> delete(
    _i1.Session session,
    List<DocumentCrdtOperation> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DocumentCrdtOperation>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DocumentCrdtOperation].
  Future<DocumentCrdtOperation> deleteRow(
    _i1.Session session,
    DocumentCrdtOperation row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DocumentCrdtOperation>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DocumentCrdtOperation>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DocumentCrdtOperationTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DocumentCrdtOperation>(
      where: where(DocumentCrdtOperation.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
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
}
