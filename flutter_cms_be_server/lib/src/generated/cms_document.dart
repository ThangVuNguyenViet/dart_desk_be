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

abstract class CmsDocument
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsDocument._({
    this.id,
    required this.clientId,
    required this.documentType,
    required this.title,
    this.slug,
    bool? isDefault,
    this.activeVersionData,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.createdByUserId,
    this.updatedByUserId,
  })  : isDefault = isDefault ?? false,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CmsDocument({
    int? id,
    required int clientId,
    required String documentType,
    required String title,
    String? slug,
    bool? isDefault,
    String? activeVersionData,
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
      isDefault: jsonSerialization['isDefault'] as bool,
      activeVersionData: jsonSerialization['activeVersionData'] as String?,
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

  String? activeVersionData;

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
    String? activeVersionData,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdByUserId,
    int? updatedByUserId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (activeVersionData != null) 'activeVersionData': activeVersionData,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      'createdByUserId': createdByUserId,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'documentType': documentType,
      'title': title,
      if (slug != null) 'slug': slug,
      'isDefault': isDefault,
      if (activeVersionData != null) 'activeVersionData': activeVersionData,
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
    String? activeVersionData,
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
          activeVersionData: activeVersionData,
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
    Object? activeVersionData = _Undefined,
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
      activeVersionData: activeVersionData is String?
          ? activeVersionData
          : this.activeVersionData,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      updatedByUserId:
          updatedByUserId is int? ? updatedByUserId : this.updatedByUserId,
    );
  }
}

class CmsDocumentTable extends _i1.Table<int?> {
  CmsDocumentTable({super.tableRelation}) : super(tableName: 'cms_documents') {
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
    activeVersionData = _i1.ColumnString(
      'activeVersionData',
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

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString documentType;

  late final _i1.ColumnString title;

  late final _i1.ColumnString slug;

  late final _i1.ColumnBool isDefault;

  late final _i1.ColumnString activeVersionData;

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
        activeVersionData,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CmsDocument>(
      where: where?.call(CmsDocument.t),
      orderBy: orderBy?.call(CmsDocument.t),
      orderByList: orderByList?.call(CmsDocument.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsDocumentTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsDocumentTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsDocumentTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CmsDocument>(
      where: where?.call(CmsDocument.t),
      orderBy: orderBy?.call(CmsDocument.t),
      orderByList: orderByList?.call(CmsDocument.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CmsDocument] by its [id] or null if no such row exists.
  Future<CmsDocument?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CmsDocument>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CmsDocument]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsDocument]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CmsDocument>> insert(
    _i1.Session session,
    List<CmsDocument> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CmsDocument>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CmsDocument] and returns the inserted row.
  ///
  /// The returned [CmsDocument] will have its `id` field set.
  Future<CmsDocument> insertRow(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session,
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

  /// Deletes all [CmsDocument]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsDocument>> delete(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session, {
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
    _i1.Session session, {
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
}
