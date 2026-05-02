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
import 'package:dart_desk_server/src/generated/protocol.dart' as _i2;

abstract class PublishedDocument
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  PublishedDocument._({
    _i1.UuidValue? id,
    required this.documentId,
    required this.projectId,
    required this.documentType,
    required this.title,
    required this.slug,
    bool? isDefault,
    this.data,
    required this.publishedAt,
    required this.publishedVersionId,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isDefault = isDefault ?? false,
       updatedAt = updatedAt ?? DateTime.now();

  factory PublishedDocument({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    required DateTime publishedAt,
    required _i1.UuidValue publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _PublishedDocumentImpl;

  factory PublishedDocument.fromJson(Map<String, dynamic> jsonSerialization) {
    return PublishedDocument(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      documentId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['documentId'],
      ),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      documentType: jsonSerialization['documentType'] as String,
      title: jsonSerialization['title'] as String,
      slug: jsonSerialization['slug'] as String,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      data: jsonSerialization['data'] == null
          ? null
          : _i2.Protocol().deserialize<Map<String, dynamic>>(
              jsonSerialization['data'],
            ),
      publishedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['publishedAt'],
      ),
      publishedVersionId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['publishedVersionId'],
      ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = PublishedDocumentTable();

  static const db = PublishedDocumentRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue documentId;

  _i1.UuidValue projectId;

  String documentType;

  String title;

  String slug;

  bool isDefault;

  Map<String, dynamic>? data;

  DateTime publishedAt;

  _i1.UuidValue publishedVersionId;

  DateTime? updatedAt;

  DateTime? deletedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [PublishedDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PublishedDocument copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    DateTime? publishedAt,
    _i1.UuidValue? publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PublishedDocument',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null)
        'data': data?.toJson(
          valueToJson: (v) => _i2.Protocol().encodeWithType(v),
        ),
      'publishedAt': publishedAt.toJson(),
      'publishedVersionId': publishedVersionId.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PublishedDocument',
      'id': id.toJson(),
      'documentId': documentId.toJson(),
      'projectId': projectId.toJson(),
      'documentType': documentType,
      'title': title,
      'slug': slug,
      'isDefault': isDefault,
      if (data != null)
        'data': data?.toJson(
          valueToJson: (v) => _i2.Protocol().encodeWithTypeForProtocol(v),
        ),
      'publishedAt': publishedAt.toJson(),
      'publishedVersionId': publishedVersionId.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  static PublishedDocumentInclude include() {
    return PublishedDocumentInclude._();
  }

  static PublishedDocumentIncludeList includeList({
    _i1.WhereExpressionBuilder<PublishedDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    PublishedDocumentInclude? include,
  }) {
    return PublishedDocumentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(PublishedDocument.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PublishedDocumentImpl extends PublishedDocument {
  _PublishedDocumentImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue documentId,
    required _i1.UuidValue projectId,
    required String documentType,
    required String title,
    required String slug,
    bool? isDefault,
    Map<String, dynamic>? data,
    required DateTime publishedAt,
    required _i1.UuidValue publishedVersionId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         documentId: documentId,
         projectId: projectId,
         documentType: documentType,
         title: title,
         slug: slug,
         isDefault: isDefault,
         data: data,
         publishedAt: publishedAt,
         publishedVersionId: publishedVersionId,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [PublishedDocument]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PublishedDocument copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? documentId,
    _i1.UuidValue? projectId,
    String? documentType,
    String? title,
    String? slug,
    bool? isDefault,
    Object? data = _Undefined,
    DateTime? publishedAt,
    _i1.UuidValue? publishedVersionId,
    Object? updatedAt = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return PublishedDocument(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      projectId: projectId ?? this.projectId,
      documentType: documentType ?? this.documentType,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      isDefault: isDefault ?? this.isDefault,
      data: data is Map<String, dynamic>?
          ? data
          : this.data?.map(
              (
                key0,
                value0,
              ) => MapEntry(
                key0,
                value0,
              ),
            ),
      publishedAt: publishedAt ?? this.publishedAt,
      publishedVersionId: publishedVersionId ?? this.publishedVersionId,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class PublishedDocumentUpdateTable
    extends _i1.UpdateTable<PublishedDocumentTable> {
  PublishedDocumentUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> documentId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.documentId,
    value,
  );

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

  _i1.ColumnValue<Map<String, dynamic>, Map<String, dynamic>> data(
    Map<String, dynamic>? value,
  ) => _i1.ColumnValue(
    table.data,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> publishedAt(DateTime value) =>
      _i1.ColumnValue(
        table.publishedAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> publishedVersionId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.publishedVersionId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.updatedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deletedAt,
        value,
      );
}

class PublishedDocumentTable extends _i1.Table<_i1.UuidValue> {
  PublishedDocumentTable({super.tableRelation})
    : super(tableName: 'published_documents') {
    updateTable = PublishedDocumentUpdateTable(this);
    documentId = _i1.ColumnUuid(
      'documentId',
      this,
    );
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
    data = _i1.ColumnStructured<Map<String, dynamic>>(
      'data',
      this,
    );
    publishedAt = _i1.ColumnDateTime(
      'publishedAt',
      this,
    );
    publishedVersionId = _i1.ColumnUuid(
      'publishedVersionId',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final PublishedDocumentUpdateTable updateTable;

  late final _i1.ColumnUuid documentId;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString title;

  late final _i1.ColumnString slug;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnStructured<Map<String, dynamic>> data;

  late final _i1.ColumnDateTime publishedAt;

  late final _i1.ColumnUuid publishedVersionId;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    documentId,
    projectId,
    documentType,
    title,
    slug,
    isDefault,
    data,
    publishedAt,
    publishedVersionId,
    updatedAt,
    deletedAt,
  ];
}

class PublishedDocumentInclude extends _i1.IncludeObject {
  PublishedDocumentInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => PublishedDocument.t;
}

class PublishedDocumentIncludeList extends _i1.IncludeList {
  PublishedDocumentIncludeList._({
    _i1.WhereExpressionBuilder<PublishedDocumentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PublishedDocument.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => PublishedDocument.t;
}

class PublishedDocumentRepository {
  const PublishedDocumentRepository._();

  /// Returns a list of [PublishedDocument]s matching the given query parameters.
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
  Future<List<PublishedDocument>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PublishedDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PublishedDocument>(
      where: where?.call(PublishedDocument.t),
      orderBy: orderBy?.call(PublishedDocument.t),
      orderByList: orderByList?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [PublishedDocument] matching the given query parameters.
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
  Future<PublishedDocument?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PublishedDocumentTable>? where,
    int? offset,
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PublishedDocument>(
      where: where?.call(PublishedDocument.t),
      orderBy: orderBy?.call(PublishedDocument.t),
      orderByList: orderByList?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PublishedDocument] by its [id] or null if no such row exists.
  Future<PublishedDocument?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PublishedDocument>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PublishedDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [PublishedDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<PublishedDocument>> insert(
    _i1.DatabaseSession session,
    List<PublishedDocument> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<PublishedDocument>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [PublishedDocument] and returns the inserted row.
  ///
  /// The returned [PublishedDocument] will have its `id` field set.
  Future<PublishedDocument> insertRow(
    _i1.DatabaseSession session,
    PublishedDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PublishedDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PublishedDocument]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PublishedDocument>> update(
    _i1.DatabaseSession session,
    List<PublishedDocument> rows, {
    _i1.ColumnSelections<PublishedDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PublishedDocument>(
      rows,
      columns: columns?.call(PublishedDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PublishedDocument]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PublishedDocument> updateRow(
    _i1.DatabaseSession session,
    PublishedDocument row, {
    _i1.ColumnSelections<PublishedDocumentTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PublishedDocument>(
      row,
      columns: columns?.call(PublishedDocument.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PublishedDocument] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PublishedDocument?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PublishedDocumentUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PublishedDocument>(
      id,
      columnValues: columnValues(PublishedDocument.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PublishedDocument]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PublishedDocument>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<PublishedDocumentUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<PublishedDocumentTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PublishedDocument>(
      columnValues: columnValues(PublishedDocument.t.updateTable),
      where: where(PublishedDocument.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PublishedDocument.t),
      orderByList: orderByList?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PublishedDocument]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PublishedDocument>> delete(
    _i1.DatabaseSession session,
    List<PublishedDocument> rows, {
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PublishedDocument>(
      rows,
      orderBy: orderBy?.call(PublishedDocument.t),
      orderByList: orderByList?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [PublishedDocument].
  Future<PublishedDocument> deleteRow(
    _i1.DatabaseSession session,
    PublishedDocument row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PublishedDocument>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<PublishedDocument>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PublishedDocumentTable> where,
    _i1.OrderByBuilder<PublishedDocumentTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<PublishedDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PublishedDocument>(
      where: where(PublishedDocument.t),
      orderBy: orderBy?.call(PublishedDocument.t),
      orderByList: orderByList?.call(PublishedDocument.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<PublishedDocumentTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PublishedDocument>(
      where: where?.call(PublishedDocument.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PublishedDocument] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<PublishedDocumentTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PublishedDocument>(
      where: where(PublishedDocument.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
