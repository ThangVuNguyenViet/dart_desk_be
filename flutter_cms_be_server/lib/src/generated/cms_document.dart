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

abstract class CmsDocument
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsDocument._({
    this.id,
    required this.clientId,
    required this.documentType,
    required this.title,
    this.slug,
    bool? isDefault,
    this.data,
    this.crdtNodeId,
    this.crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdByUserId,
    this.updatedByUserId,
  }) : isDefault = isDefault ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsDocument({
    int? id,
    required int clientId,
    required String documentType,
    required String title,
    String? slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int createdByUserId,
    int? updatedByUserId,
  }) = _CmsDocumentImpl;

  factory CmsDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsDocument(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String?,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      data: jsonSerialization['data'] as String?,
      crdtNodeId: jsonSerialization['crdtNodeId'] as String?,
      crdtHlc: jsonSerialization['crdtHlc'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      createdByUserId: jsonSerialization['createdByUserId'] as int,
      updatedByUserId: jsonSerialization['updatedByUserId'] as int?,
    );
  }

  static final t = CmsDocumentTable();

  static const db = CmsDocumentRepository._();

  @override
  int? id;

  int clientId;

  String documentType;

  String title;

  String? slug;

  bool isDefault;

  String? data;

  String? crdtNodeId;

  String? crdtHlc;

  DateTime? createdAt;

  DateTime? updatedAt;

  int createdByUserId;

  int? updatedByUserId;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsDocument copyWith({
    int? id,
    int? clientId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsDocument',
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (data != null) 'data': data,
      if (crdtNodeId != null) 'crdtNodeId': crdtNodeId,
      if (crdtHlc != null) 'crdtHlc': crdtHlc,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsDocument',
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (data != null) 'data': data,
      if (crdtNodeId != null) 'crdtNodeId': crdtNodeId,
      if (crdtHlc != null) 'crdtHlc': crdtHlc,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  static CmsDocumentInclude include() {
    return CmsDocumentInclude._();
  }

  static CmsDocumentIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    CmsDocumentInclude? include,
  }) {
    return CmsDocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDocument.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsDocument.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsDocumentImpl extends CmsDocument {
  _CmsDocumentImpl({
    int? id,
    required int clientId,
    required String documentType,
    required String title,
    String? slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    required int createdByUserId,
    int? updatedByUserId,
  }) : super._(
         id: id,
         clientId: clientId,
         documentType: documentType,
         title: title,
         slug: slug,
         isDefault: isDefault,
         data: data,
         crdtNodeId: crdtNodeId,
         crdtHlc: crdtHlc,
         createdAt: createdAt,
         updatedAt: updatedAt,
         createdByUserId: createdByUserId,
         updatedByUserId: updatedByUserId,
       );

  /// Returns a shallow copy of this [CmsDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsDocument copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? documentType,
    String? title,
    Object? slug = _Undefined,
    bool? isDefault,
    Object? data = _Undefined,
    Object? crdtNodeId = _Undefined,
    Object? crdtHlc = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    int? createdByUserId,
    Object? updatedByUserId = _Undefined,
  }) {
    return CmsDocument(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug is String? ? slug : this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data is String? ? data : this.data,
      crdtNodeId: crdtNodeId is String? ? crdtNodeId : this.crdtNodeId,
      crdtHlc: crdtHlc is String? ? crdtHlc : this.crdtHlc,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId: updatedByUserId is int?
          ? updatedByUserId
          : this.updatedByUserId,
    );
  }
}

class CmsDocumentUpdateTable extends _i1.UpdateTable<CmsDocumentTable> {
  CmsDocumentUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<String, String> documentType(String value) => _i1.ColumnValue(
    table.documentType,
    value,
  );

  _i1.ColumnValue<String, String> title(String value) => _i1.ColumnValue(
    table.title,
    value,
  );

  _i1.ColumnValue<String, String> slug(String? value) => _i1.ColumnValue(
    table.slug,
    value,
  );

  _i1.ColumnValue<bool, bool> isDefault(bool value) => _i1.ColumnValue(
    table.isDefault,
    value,
  );

  _i1.ColumnValue<String, String> data(String? value) => _i1.ColumnValue(
    table.data,
    value,
  );

  _i1.ColumnValue<String, String> crdtNodeId(String? value) => _i1.ColumnValue(
    table.crdtNodeId,
    value,
  );

  _i1.ColumnValue<String, String> crdtHlc(String? value) => _i1.ColumnValue(
    table.crdtHlc,
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

  _i1.ColumnValue<int, int> createdByUserId(int value) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );

  _i1.ColumnValue<int, int> updatedByUserId(int? value) => _i1.ColumnValue(
    table.updatedByUserId,
    value,
  );
}

class CmsDocumentTable extends _i1.Table<int?> {
  CmsDocumentTable({super.tableRelation}) : super(tableName: 'cms_documents') {
    updateTable = CmsDocumentUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
    documentType = _i1.ColumnString(
      'documentType',
      this,
    );
    title = _i1.ColumnString(
      'title',
      this,
    );
    slug = _i1.ColumnString(
      'slug',
      this,
    );
    isDefault = _i1.ColumnBool(
      'isDefault',
      this,
      hasDefault: true,
    );
    data = _i1.ColumnString(
      'data',
      this,
    );
    crdtNodeId = _i1.ColumnString(
      'crdtNodeId',
      this,
    );
    crdtHlc = _i1.ColumnString(
      'crdtHlc',
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

  late final CmsDocumentUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString title;

  late final _i1.ColumnString slug;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnString data;

  late final _i1.ColumnString crdtNodeId;

  late final _i1.ColumnString crdtHlc;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnInt createdByUserId;

  late final _i1.ColumnInt updatedByUserId;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    documentType,
    title,
    slug,
    isDefault,
    data,
    crdtNodeId,
    crdtHlc,
    createdAt,
    updatedAt,
    createdByUserId,
    updatedByUserId,
  ];
}

class CmsDocumentInclude extends _i1.IncludeObject {
  CmsDocumentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsDocument.t;
}

class CmsDocumentIncludeList extends _i1.IncludeList {
  CmsDocumentIncludeList._({
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsDocument.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsDocument.t;
}

class CmsDocumentRepository {
  const CmsDocumentRepository._();

  /// Returns a list of [CmsDocument]s matching the given query parameters.
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
  Future<List<CmsDocument>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsDocument>(
      where: where?.call(CmsDocument.t),
      orderBy: orderBy?.call(CmsDocument.t),
      orderByList: orderByList?.call(CmsDocument.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsDocument] matching the given query parameters.
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
  Future<CmsDocument?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsDocument>(
      where: where?.call(CmsDocument.t),
      orderBy: orderBy?.call(CmsDocument.t),
      orderByList: orderByList?.call(CmsDocument.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsDocument] by its [id] or null if no such row exists.
  Future<CmsDocument?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsDocument>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsDocument>> insert(
    _i1.DatabaseSession session,
    List<CmsDocument> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsDocument>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsDocument] and returns the inserted row.
  ///
  /// The returned [CmsDocument] will have its `id` field set.
  Future<CmsDocument> insertRow(
    _i1.DatabaseSession session,
    CmsDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsDocument]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsDocument>> update(
    _i1.DatabaseSession session,
    List<CmsDocument> rows, {
    _i1.ColumnSelections<CmsDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsDocument>(
      rows,
      columns: columns?.call(CmsDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDocument]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsDocument> updateRow(
    _i1.DatabaseSession session,
    CmsDocument row, {
    _i1.ColumnSelections<CmsDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsDocument>(
      row,
      columns: columns?.call(CmsDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsDocument] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsDocument?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CmsDocumentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsDocument>(
      id,
      columnValues: columnValues(CmsDocument.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsDocument]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsDocument>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsDocumentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CmsDocumentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsDocument>(
      columnValues: columnValues(CmsDocument.t.updateTable),
      where: where(CmsDocument.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsDocument.t),
      orderByList: orderByList?.call(CmsDocument.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsDocument]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsDocument>> delete(
    _i1.DatabaseSession session,
    List<CmsDocument> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsDocument>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsDocument].
  Future<CmsDocument> deleteRow(
    _i1.DatabaseSession session,
    CmsDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsDocument>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDocumentTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsDocument>(
      where: where(CmsDocument.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsDocument>(
      where: where?.call(CmsDocument.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsDocument] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsDocumentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsDocument>(
      where: where(CmsDocument.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
