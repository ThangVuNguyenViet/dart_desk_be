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

abstract class ApiKey
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  ApiKey._({
    _i1.UuidValue? id,
    required this.projectId,
    required this.name,
    required this.tokenHash,
    required this.tokenPrefix,
    required this.tokenSuffix,
    required this.role,
    this.createdByUserId,
    this.lastUsedAt,
    this.expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory ApiKey({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) = _ApiKeyImpl;

  factory ApiKey.fromJson(Map<String, dynamic> jsonSerialization) {
    return ApiKey(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      projectId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['projectId'],
      ),
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      tokenSuffix: jsonSerialization['tokenSuffix'] as String,
      role: jsonSerialization['role'] as String,
      createdByUserId: jsonSerialization['createdByUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdByUserId'],
            ),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      expiresAt: jsonSerialization['expiresAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['expiresAt']),
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = ApiKeyTable();

  static const db = ApiKeyRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue projectId;

  String name;

  String tokenHash;

  String tokenPrefix;

  String tokenSuffix;

  String role;

  _i1.UuidValue? createdByUserId;

  DateTime? lastUsedAt;

  DateTime? expiresAt;

  bool isActive;

  DateTime? createdAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [ApiKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ApiKey copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ApiKey',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ApiKey',
      'id': id.toJson(),
      'projectId': projectId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId?.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static ApiKeyInclude include() {
    return ApiKeyInclude._();
  }

  static ApiKeyIncludeList includeList({
    _i1.WhereExpressionBuilder<ApiKeyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    ApiKeyInclude? include,
  }) {
    return ApiKeyIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(ApiKey.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ApiKeyImpl extends ApiKey {
  _ApiKeyImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue projectId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    _i1.UuidValue? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : super._(
         id: id,
         projectId: projectId,
         name: name,
         tokenHash: tokenHash,
         tokenPrefix: tokenPrefix,
         tokenSuffix: tokenSuffix,
         role: role,
         createdByUserId: createdByUserId,
         lastUsedAt: lastUsedAt,
         expiresAt: expiresAt,
         isActive: isActive,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [ApiKey]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ApiKey copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? projectId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    Object? createdByUserId = _Undefined,
    Object? lastUsedAt = _Undefined,
    Object? expiresAt = _Undefined,
    bool? isActive,
    Object? createdAt = _Undefined,
  }) {
    return ApiKey(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      tokenSuffix: tokenSuffix ?? this.tokenSuffix,
      role: role ?? this.role,
      createdByUserId: createdByUserId is _i1.UuidValue?
          ? createdByUserId
          : this.createdByUserId,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class ApiKeyUpdateTable extends _i1.UpdateTable<ApiKeyTable> {
  ApiKeyUpdateTable(super.table);

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

  _i1.ColumnValue<String, String> tokenHash(String value) => _i1.ColumnValue(
    table.tokenHash,
    value,
  );

  _i1.ColumnValue<String, String> tokenPrefix(String value) => _i1.ColumnValue(
    table.tokenPrefix,
    value,
  );

  _i1.ColumnValue<String, String> tokenSuffix(String value) => _i1.ColumnValue(
    table.tokenSuffix,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> createdByUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.createdByUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> lastUsedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.lastUsedAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime? value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime? value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class ApiKeyTable extends _i1.Table<_i1.UuidValue> {
  ApiKeyTable({super.tableRelation}) : super(tableName: 'api_keys') {
    updateTable = ApiKeyUpdateTable(this);
    projectId = _i1.ColumnUuid(
      'projectId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    tokenHash = _i1.ColumnString(
      'tokenHash',
      this,
    );
    tokenPrefix = _i1.ColumnString(
      'tokenPrefix',
      this,
    );
    tokenSuffix = _i1.ColumnString(
      'tokenSuffix',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
    );
    createdByUserId = _i1.ColumnUuid(
      'createdByUserId',
      this,
    );
    lastUsedAt = _i1.ColumnDateTime(
      'lastUsedAt',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final ApiKeyUpdateTable updateTable;

  late final _i1.ColumnUuid projectId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString tokenHash;

  late final _i1.ColumnString tokenPrefix;

  late final _i1.ColumnString tokenSuffix;

  late final _i1.ColumnString role;

  late final _i1.ColumnUuid createdByUserId;

  late final _i1.ColumnDateTime lastUsedAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    projectId,
    name,
    tokenHash,
    tokenPrefix,
    tokenSuffix,
    role,
    createdByUserId,
    lastUsedAt,
    expiresAt,
    isActive,
    createdAt,
  ];
}

class ApiKeyInclude extends _i1.IncludeObject {
  ApiKeyInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => ApiKey.t;
}

class ApiKeyIncludeList extends _i1.IncludeList {
  ApiKeyIncludeList._({
    _i1.WhereExpressionBuilder<ApiKeyTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ApiKey.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => ApiKey.t;
}

class ApiKeyRepository {
  const ApiKeyRepository._();

  /// Returns a list of [ApiKey]s matching the given query parameters.
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
  Future<List<ApiKey>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ApiKeyTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ApiKey>(
      where: where?.call(ApiKey.t),
      orderBy: orderBy?.call(ApiKey.t),
      orderByList: orderByList?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ApiKey] matching the given query parameters.
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
  Future<ApiKey?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ApiKeyTable>? where,
    int? offset,
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ApiKey>(
      where: where?.call(ApiKey.t),
      orderBy: orderBy?.call(ApiKey.t),
      orderByList: orderByList?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ApiKey] by its [id] or null if no such row exists.
  Future<ApiKey?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ApiKey>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ApiKey]s in the list and returns the inserted rows.
  ///
  /// The returned [ApiKey]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<ApiKey>> insert(
    _i1.DatabaseSession session,
    List<ApiKey> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ApiKey>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ApiKey] and returns the inserted row.
  ///
  /// The returned [ApiKey] will have its `id` field set.
  Future<ApiKey> insertRow(
    _i1.DatabaseSession session,
    ApiKey row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ApiKey>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ApiKey]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ApiKey>> update(
    _i1.DatabaseSession session,
    List<ApiKey> rows, {
    _i1.ColumnSelections<ApiKeyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ApiKey>(
      rows,
      columns: columns?.call(ApiKey.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ApiKey]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ApiKey> updateRow(
    _i1.DatabaseSession session,
    ApiKey row, {
    _i1.ColumnSelections<ApiKeyTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<ApiKey>(
      row,
      columns: columns?.call(ApiKey.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ApiKey] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ApiKey?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<ApiKeyUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ApiKey>(
      id,
      columnValues: columnValues(ApiKey.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ApiKey]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ApiKey>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ApiKeyUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ApiKeyTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ApiKey>(
      columnValues: columnValues(ApiKey.t.updateTable),
      where: where(ApiKey.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ApiKey.t),
      orderByList: orderByList?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ApiKey]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ApiKey>> delete(
    _i1.DatabaseSession session,
    List<ApiKey> rows, {
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ApiKey>(
      rows,
      orderBy: orderBy?.call(ApiKey.t),
      orderByList: orderByList?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [ApiKey].
  Future<ApiKey> deleteRow(
    _i1.DatabaseSession session,
    ApiKey row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ApiKey>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<ApiKey>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ApiKeyTable> where,
    _i1.OrderByBuilder<ApiKeyTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<ApiKeyTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ApiKey>(
      where: where(ApiKey.t),
      orderBy: orderBy?.call(ApiKey.t),
      orderByList: orderByList?.call(ApiKey.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ApiKeyTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ApiKey>(
      where: where?.call(ApiKey.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ApiKey] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ApiKeyTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ApiKey>(
      where: where(ApiKey.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
