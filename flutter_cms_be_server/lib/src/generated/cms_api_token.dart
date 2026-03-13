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

abstract class CmsApiToken
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsApiToken._({
    this.id,
    required this.clientId,
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
  }) : isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory CmsApiToken({
    int? id,
    required int clientId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) = _CmsApiTokenImpl;

  factory CmsApiToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsApiToken(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      tokenSuffix: jsonSerialization['tokenSuffix'] as String,
      role: jsonSerialization['role'] as String,
      createdByUserId: jsonSerialization['createdByUserId'] as int?,
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

  static final t = CmsApiTokenTable();

  static const db = CmsApiTokenRepository._();

  @override
  int? id;

  int clientId;

  String name;

  String tokenHash;

  String tokenPrefix;

  String tokenSuffix;

  String role;

  int? createdByUserId;

  DateTime? lastUsedAt;

  DateTime? expiresAt;

  bool isActive;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsApiToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsApiToken copyWith({
    int? id,
    int? clientId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    String? tokenSuffix,
    String? role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsApiToken',
      if (id != null) 'id': id,
      'clientId': clientId,
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsApiToken',
      if (id != null) 'id': id,
      'clientId': clientId,
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'tokenSuffix': tokenSuffix,
      'role': role,
      if (createdByUserId != null) 'createdByUserId': createdByUserId,
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (expiresAt != null) 'expiresAt': expiresAt?.toJson(),
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  static CmsApiTokenInclude include() {
    return CmsApiTokenInclude._();
  }

  static CmsApiTokenIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsApiTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsApiTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsApiTokenTable>? orderByList,
    CmsApiTokenInclude? include,
  }) {
    return CmsApiTokenIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsApiToken.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsApiToken.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsApiTokenImpl extends CmsApiToken {
  _CmsApiTokenImpl({
    int? id,
    required int clientId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required String tokenSuffix,
    required String role,
    int? createdByUserId,
    DateTime? lastUsedAt,
    DateTime? expiresAt,
    bool? isActive,
    DateTime? createdAt,
  }) : super._(
         id: id,
         clientId: clientId,
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

  /// Returns a shallow copy of this [CmsApiToken]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsApiToken copyWith({
    Object? id = _Undefined,
    int? clientId,
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
    return CmsApiToken(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      tokenSuffix: tokenSuffix ?? this.tokenSuffix,
      role: role ?? this.role,
      createdByUserId: createdByUserId is int?
          ? createdByUserId
          : this.createdByUserId,
      lastUsedAt: lastUsedAt is DateTime? ? lastUsedAt : this.lastUsedAt,
      expiresAt: expiresAt is DateTime? ? expiresAt : this.expiresAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class CmsApiTokenUpdateTable extends _i1.UpdateTable<CmsApiTokenTable> {
  CmsApiTokenUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
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

  _i1.ColumnValue<int, int> createdByUserId(int? value) => _i1.ColumnValue(
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

class CmsApiTokenTable extends _i1.Table<int?> {
  CmsApiTokenTable({super.tableRelation}) : super(tableName: 'cms_api_tokens') {
    updateTable = CmsApiTokenUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
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
    createdByUserId = _i1.ColumnInt(
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

  late final CmsApiTokenUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString name;

  late final _i1.ColumnString tokenHash;

  late final _i1.ColumnString tokenPrefix;

  late final _i1.ColumnString tokenSuffix;

  late final _i1.ColumnString role;

  late final _i1.ColumnInt createdByUserId;

  late final _i1.ColumnDateTime lastUsedAt;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
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

class CmsApiTokenInclude extends _i1.IncludeObject {
  CmsApiTokenInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsApiToken.t;
}

class CmsApiTokenIncludeList extends _i1.IncludeList {
  CmsApiTokenIncludeList._({
    _i1.WhereExpressionBuilder<CmsApiTokenTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsApiToken.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsApiToken.t;
}

class CmsApiTokenRepository {
  const CmsApiTokenRepository._();

  /// Returns a list of [CmsApiToken]s matching the given query parameters.
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
  Future<List<CmsApiToken>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsApiTokenTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsApiTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsApiTokenTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsApiToken>(
      where: where?.call(CmsApiToken.t),
      orderBy: orderBy?.call(CmsApiToken.t),
      orderByList: orderByList?.call(CmsApiToken.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsApiToken] matching the given query parameters.
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
  Future<CmsApiToken?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsApiTokenTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsApiTokenTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsApiTokenTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsApiToken>(
      where: where?.call(CmsApiToken.t),
      orderBy: orderBy?.call(CmsApiToken.t),
      orderByList: orderByList?.call(CmsApiToken.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsApiToken] by its [id] or null if no such row exists.
  Future<CmsApiToken?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsApiToken>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsApiToken]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsApiToken]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsApiToken>> insert(
    _i1.DatabaseSession session,
    List<CmsApiToken> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsApiToken>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsApiToken] and returns the inserted row.
  ///
  /// The returned [CmsApiToken] will have its `id` field set.
  Future<CmsApiToken> insertRow(
    _i1.DatabaseSession session,
    CmsApiToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsApiToken>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsApiToken]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsApiToken>> update(
    _i1.DatabaseSession session,
    List<CmsApiToken> rows, {
    _i1.ColumnSelections<CmsApiTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsApiToken>(
      rows,
      columns: columns?.call(CmsApiToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsApiToken]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsApiToken> updateRow(
    _i1.DatabaseSession session,
    CmsApiToken row, {
    _i1.ColumnSelections<CmsApiTokenTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsApiToken>(
      row,
      columns: columns?.call(CmsApiToken.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsApiToken] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsApiToken?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CmsApiTokenUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsApiToken>(
      id,
      columnValues: columnValues(CmsApiToken.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsApiToken]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsApiToken>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsApiTokenUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CmsApiTokenTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsApiTokenTable>? orderBy,
    _i1.OrderByListBuilder<CmsApiTokenTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsApiToken>(
      columnValues: columnValues(CmsApiToken.t.updateTable),
      where: where(CmsApiToken.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsApiToken.t),
      orderByList: orderByList?.call(CmsApiToken.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsApiToken]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsApiToken>> delete(
    _i1.DatabaseSession session,
    List<CmsApiToken> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsApiToken>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsApiToken].
  Future<CmsApiToken> deleteRow(
    _i1.DatabaseSession session,
    CmsApiToken row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsApiToken>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsApiToken>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsApiTokenTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsApiToken>(
      where: where(CmsApiToken.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsApiTokenTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsApiToken>(
      where: where?.call(CmsApiToken.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsApiToken] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsApiTokenTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsApiToken>(
      where: where(CmsApiToken.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
