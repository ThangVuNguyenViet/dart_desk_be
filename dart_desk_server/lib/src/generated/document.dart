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

abstract class Document
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  Document._({
    _i1.UuidValue? id,
    required this.projectId,
    required this.documentType,
    required this.title,
    required this.slug,
    bool? isDefault,
    this.data,
    this.crdtNodeId,
    this.crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdByUserId,
    this.updatedByUserId,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isDefault = isDefault ?? false,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Document({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  }) = _DocumentImpl;

  factory Document.fromJson(Map<String, dynamic> jsonSerialization) {
    return Document(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String,
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
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
      updatedByUserId: jsonSerialization['updatedByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['updatedByUserId'],
            ),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = DocumentTable();

  static const db = DocumentRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String documentType;

  String title;

  String slug;

  bool isDefault;

  String? data;

  String? crdtNodeId;

  String? crdtHlc;

  DateTime? createdAt;

  DateTime? updatedAt;

  _i1.UuidValue? createdByUserId;

  _i1.UuidValue? updatedByUserId;

  DateTime? deletedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Document copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Document',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null) 'data': data,
      if (crdtNodeId != null) 'crdtNodeId': crdtNodeId,
      if (crdtHlc != null) 'crdtHlc': crdtHlc,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Document',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null) 'data': data,
      if (crdtNodeId != null) 'crdtNodeId': crdtNodeId,
      if (crdtHlc != null) 'crdtHlc': crdtHlc,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  static DocumentInclude include() {
    return DocumentInclude._();
  }

  static DocumentIncludeList includeList({
    _i1.WhereExpressionBuilder<DocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    DocumentInclude? include,
  }) {
    return DocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(Document.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DocumentImpl extends Document {
  _DocumentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    String? data,
    String? crdtNodeId,
    String? crdtHlc,
    DateTime? createdAt,
    DateTime? updatedAt,
    _i1.UuidValue? createdByUserId,
    _i1.UuidValue? updatedByUserId,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         projectId: projectId,
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
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [Document]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Document copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Object? data = _Undefined,
    Object? crdtNodeId = _Undefined,
    Object? crdtHlc = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? createdByUserId = _Undefined,
    Object? updatedByUserId = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return Document(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data is String? ? data : this.data,
      crdtNodeId: crdtNodeId is String? ? crdtNodeId : this.crdtNodeId,
      crdtHlc: crdtHlc is String? ? crdtHlc : this.crdtHlc,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
      updatedByUserId: updatedByUserId is _i1.UuidValue?
          ? updatedByUserId
          : this.updatedByUserId,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class DocumentUpdateTable extends _i1.UpdateTable<DocumentTable> {
  DocumentUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> projectId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.projectId,
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

  _i1.ColumnValue<String, String> slug(String value) => _i1.ColumnValue(
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

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> createdByUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> updatedByUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.updatedByUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deletedAt,
        value,
      );
}

class DocumentTable extends _i1.Table<_i1.UuidValue> {
  DocumentTable({super.tableRelation}) : super(tableName: 'documents') {
    updateTable = DocumentUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
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
    createdByUserId = _i1.ColumnUuid(
      'createdByUserId',
      this,
    );
    updatedByUserId = _i1.ColumnUuid(
      'updatedByUserId',
      this,
    );
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final DocumentUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString title;

  late final _i1.ColumnString slug;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnString data;

  late final _i1.ColumnString crdtNodeId;

  late final _i1.ColumnString crdtHlc;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnUuid createdByUserId;

  late final _i1.ColumnUuid updatedByUserId;

  late final _i1.ColumnDateTime deletedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    projectId,
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
    deletedAt,
  ];
}

class DocumentInclude extends _i1.IncludeObject {
  DocumentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => Document.t;
}

class DocumentIncludeList extends _i1.IncludeList {
  DocumentIncludeList._({
    _i1.WhereExpressionBuilder<DocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Document.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => Document.t;
}

class DocumentRepository {
  const DocumentRepository._();

  /// Returns a list of [Document]s matching the given query parameters.
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
  Future<List<Document>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Document>(
      where: where?.call(Document.t),
      orderBy: orderBy?.call(Document.t),
      orderByList: orderByList?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Document] matching the given query parameters.
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
  Future<Document?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentTable>? where,
    int? offset,
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Document>(
      where: where?.call(Document.t),
      orderBy: orderBy?.call(Document.t),
      orderByList: orderByList?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Document] by its [id] or null if no such row exists.
  Future<Document?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Document>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Document]s in the list and returns the inserted rows.
  ///
  /// The returned [Document]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Document>> insert(
    _i1.DatabaseSession session,
    List<Document> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Document>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Document] and returns the inserted row.
  ///
  /// The returned [Document] will have its `id` field set.
  Future<Document> insertRow(
    _i1.DatabaseSession session,
    Document row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Document>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Document]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Document>> update(
    _i1.DatabaseSession session,
    List<Document> rows, {
    _i1.ColumnSelections<DocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Document>(
      rows,
      columns: columns?.call(Document.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Document]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Document> updateRow(
    _i1.DatabaseSession session,
    Document row, {
    _i1.ColumnSelections<DocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Document>(
      row,
      columns: columns?.call(Document.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Document] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Document?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<DocumentUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Document>(
      id,
      columnValues: columnValues(Document.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Document]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Document>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<DocumentUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DocumentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Document>(
      columnValues: columnValues(Document.t.updateTable),
      where: where(Document.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Document.t),
      orderByList: orderByList?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Document]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Document>> delete(
    _i1.DatabaseSession session,
    List<Document> rows, {
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Document>(
      rows,
      orderBy: orderBy?.call(Document.t),
      orderByList: orderByList?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [Document].
  Future<Document> deleteRow(
    _i1.DatabaseSession session,
    Document row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Document>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<Document>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentTable> where,
    _i1.OrderByBuilder<DocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<DocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Document>(
      where: where(Document.t),
      orderBy: orderBy?.call(Document.t),
      orderByList: orderByList?.call(Document.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<DocumentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Document>(
      where: where?.call(Document.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Document] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<DocumentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Document>(
      where: where(Document.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
