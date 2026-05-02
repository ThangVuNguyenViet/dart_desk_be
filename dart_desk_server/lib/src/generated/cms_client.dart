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

abstract class CmsClient
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  CmsClient._({
    _i1.UuidValue? id,
    required this.name,
    required this.slug,
    this.description,
    bool? isActive,
    this.settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsClient({
    _i1.UuidValue? id,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) = _CmsClientImpl;

  factory CmsClient.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsClient(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      description: jsonSerialization['description'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      settings: jsonSerialization['settings'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
    );
  }

  static final t = CmsClientTable();

  static const db = CmsClientRepository._();

  @override
  _i1.UuidValue id;

  String name;

  String slug;

  String? description;

  bool isActive;

  String? settings;

  DateTime? createdAt;

  DateTime? updatedAt;

  DateTime? deletedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [CmsClient]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsClient copyWith({
    _i1.UuidValue? id,
    String? name,
    String? slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsClient',
      'id': id.toJson(),
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (settings != null) 'settings': settings,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsClient',
      'id': id.toJson(),
      'name': name,
      'slug': slug,
      if (description != null) 'description': description,
      'isActive': isActive,
      if (settings != null) 'settings': settings,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
    };
  }

  static CmsClientInclude include() {
    return CmsClientInclude._();
  }

  static CmsClientIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsClientTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    CmsClientInclude? include,
  }) {
    return CmsClientIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(CmsClient.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsClientImpl extends CmsClient {
  _CmsClientImpl({
    _i1.UuidValue? id,
    required String name,
    required String slug,
    String? description,
    bool? isActive,
    String? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         description: description,
         isActive: isActive,
         settings: settings,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
       );

  /// Returns a shallow copy of this [CmsClient]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsClient copyWith({
    _i1.UuidValue? id,
    String? name,
    String? slug,
    Object? description = _Undefined,
    bool? isActive,
    Object? settings = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
    Object? deletedAt = _Undefined,
  }) {
    return CmsClient(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description is String? ? description : this.description,
      isActive: isActive ?? this.isActive,
      settings: settings is String? ? settings : this.settings,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
    );
  }
}

class CmsClientUpdateTable extends _i1.UpdateTable<CmsClientTable> {
  CmsClientUpdateTable(super.table);

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> slug(String value) => _i1.ColumnValue(
    table.slug,
    value,
  );

  _i1.ColumnValue<String, String> description(String? value) => _i1.ColumnValue(
    table.description,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<String, String> settings(String? value) => _i1.ColumnValue(
    table.settings,
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

  _i1.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.deletedAt,
        value,
      );
}

class CmsClientTable extends _i1.Table<_i1.UuidValue> {
  CmsClientTable({super.tableRelation}) : super(tableName: 'clients') {
    updateTable = CmsClientUpdateTable(this);
    name = _i1.ColumnString(
      'name',
      this,
    );
    slug = _i1.ColumnString(
      'slug',
      this,
    );
    description = _i1.ColumnString(
      'description',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
    settings = _i1.ColumnString(
      'settings',
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
    deletedAt = _i1.ColumnDateTime(
      'deletedAt',
      this,
    );
  }

  late final CmsClientUpdateTable updateTable;

  late final _i1.ColumnString name;

  late final _i1.ColumnString slug;

  late final _i1.ColumnString description;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnString settings;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  late final _i1.ColumnDateTime deletedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    name,
    slug,
    description,
    isActive,
    settings,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}

class CmsClientInclude extends _i1.IncludeObject {
  CmsClientInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => CmsClient.t;
}

class CmsClientIncludeList extends _i1.IncludeList {
  CmsClientIncludeList._({
    _i1.WhereExpressionBuilder<CmsClientTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsClient.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => CmsClient.t;
}

class CmsClientRepository {
  const CmsClientRepository._();

  /// Returns a list of [CmsClient]s matching the given query parameters.
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
  Future<List<CmsClient>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsClientTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsClient>(
      where: where?.call(CmsClient.t),
      orderBy: orderBy?.call(CmsClient.t),
      orderByList: orderByList?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsClient] matching the given query parameters.
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
  Future<CmsClient?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsClientTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsClient>(
      where: where?.call(CmsClient.t),
      orderBy: orderBy?.call(CmsClient.t),
      orderByList: orderByList?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsClient] by its [id] or null if no such row exists.
  Future<CmsClient?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsClient>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsClient]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsClient]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsClient>> insert(
    _i1.DatabaseSession session,
    List<CmsClient> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsClient>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsClient] and returns the inserted row.
  ///
  /// The returned [CmsClient] will have its `id` field set.
  Future<CmsClient> insertRow(
    _i1.DatabaseSession session,
    CmsClient row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsClient>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsClient]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsClient>> update(
    _i1.DatabaseSession session,
    List<CmsClient> rows, {
    _i1.ColumnSelections<CmsClientTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsClient>(
      rows,
      columns: columns?.call(CmsClient.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsClient]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsClient> updateRow(
    _i1.DatabaseSession session,
    CmsClient row, {
    _i1.ColumnSelections<CmsClientTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsClient>(
      row,
      columns: columns?.call(CmsClient.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsClient] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsClient?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<CmsClientUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsClient>(
      id,
      columnValues: columnValues(CmsClient.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsClient]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsClient>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsClientUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CmsClientTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsClient>(
      columnValues: columnValues(CmsClient.t.updateTable),
      where: where(CmsClient.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsClient.t),
      orderByList: orderByList?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsClient]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsClient>> delete(
    _i1.DatabaseSession session,
    List<CmsClient> rows, {
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsClient>(
      rows,
      orderBy: orderBy?.call(CmsClient.t),
      orderByList: orderByList?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsClient].
  Future<CmsClient> deleteRow(
    _i1.DatabaseSession session,
    CmsClient row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsClient>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<CmsClient>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsClientTable> where,
    _i1.OrderByBuilder<CmsClientTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsClient>(
      where: where(CmsClient.t),
      orderBy: orderBy?.call(CmsClient.t),
      orderByList: orderByList?.call(CmsClient.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsClientTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsClient>(
      where: where?.call(CmsClient.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsClient] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsClientTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsClient>(
      where: where(CmsClient.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
