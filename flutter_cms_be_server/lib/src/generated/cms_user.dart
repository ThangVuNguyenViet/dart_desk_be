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

abstract class CmsUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsUser._({
    this.id,
    required this.clientId,
    required this.email,
    this.name,
    String? role,
    bool? isActive,
    this.serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : role = role ?? 'viewer',
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory CmsUser({
    int? id,
    required int clientId,
    required String email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CmsUserImpl;

  factory CmsUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsUser(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      role: jsonSerialization['role'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      serverpodUserId: jsonSerialization['serverpodUserId'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = CmsUserTable();

  static const db = CmsUserRepository._();

  @override
  int? id;

  int clientId;

  String email;

  String? name;

  String role;

  bool isActive;

  String? serverpodUserId;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsUser copyWith({
    int? id,
    int? clientId,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CmsUser',
      if (id != null) 'id': id,
      'clientId': clientId,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      'isActive': isActive,
      if (serverpodUserId != null) 'serverpodUserId': serverpodUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CmsUser',
      if (id != null) 'id': id,
      'clientId': clientId,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      'isActive': isActive,
      if (serverpodUserId != null) 'serverpodUserId': serverpodUserId,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static CmsUserInclude include() {
    return CmsUserInclude._();
  }

  static CmsUserIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    CmsUserInclude? include,
  }) {
    return CmsUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsUserImpl extends CmsUser {
  _CmsUserImpl({
    int? id,
    required int clientId,
    required String email,
    String? name,
    String? role,
    bool? isActive,
    String? serverpodUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         email: email,
         name: name,
         role: role,
         isActive: isActive,
         serverpodUserId: serverpodUserId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsUser copyWith({
    Object? id = _Undefined,
    int? clientId,
    String? email,
    Object? name = _Undefined,
    String? role,
    bool? isActive,
    Object? serverpodUserId = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CmsUser(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      serverpodUserId: serverpodUserId is String?
          ? serverpodUserId
          : this.serverpodUserId,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class CmsUserUpdateTable extends _i1.UpdateTable<CmsUserTable> {
  CmsUserUpdateTable(super.table);

  _i1.ColumnValue<int, int> clientId(int value) => _i1.ColumnValue(
    table.clientId,
    value,
  );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<String, String> name(String? value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<String, String> role(String value) => _i1.ColumnValue(
    table.role,
    value,
  );

  _i1.ColumnValue<bool, bool> isActive(bool value) => _i1.ColumnValue(
    table.isActive,
    value,
  );

  _i1.ColumnValue<String, String> serverpodUserId(String? value) =>
      _i1.ColumnValue(
        table.serverpodUserId,
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
}

class CmsUserTable extends _i1.Table<int?> {
  CmsUserTable({super.tableRelation}) : super(tableName: 'cms_users') {
    updateTable = CmsUserUpdateTable(this);
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    role = _i1.ColumnString(
      'role',
      this,
      hasDefault: true,
    );
    isActive = _i1.ColumnBool(
      'isActive',
      this,
      hasDefault: true,
    );
    serverpodUserId = _i1.ColumnString(
      'serverpodUserId',
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
  }

  late final CmsUserUpdateTable updateTable;

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnString email;

  late final _i1.ColumnString name;

  late final _i1.ColumnString role;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnString serverpodUserId;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    email,
    name,
    role,
    isActive,
    serverpodUserId,
    createdAt,
    updatedAt,
  ];
}

class CmsUserInclude extends _i1.IncludeObject {
  CmsUserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsUser.t;
}

class CmsUserIncludeList extends _i1.IncludeList {
  CmsUserIncludeList._({
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsUser.t;
}

class CmsUserRepository {
  const CmsUserRepository._();

  /// Returns a list of [CmsUser]s matching the given query parameters.
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
  Future<List<CmsUser>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CmsUser>(
      where: where?.call(CmsUser.t),
      orderBy: orderBy?.call(CmsUser.t),
      orderByList: orderByList?.call(CmsUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CmsUser] matching the given query parameters.
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
  Future<CmsUser?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CmsUser>(
      where: where?.call(CmsUser.t),
      orderBy: orderBy?.call(CmsUser.t),
      orderByList: orderByList?.call(CmsUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CmsUser] by its [id] or null if no such row exists.
  Future<CmsUser?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CmsUser>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CmsUser]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<CmsUser>> insert(
    _i1.DatabaseSession session,
    List<CmsUser> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<CmsUser>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [CmsUser] and returns the inserted row.
  ///
  /// The returned [CmsUser] will have its `id` field set.
  Future<CmsUser> insertRow(
    _i1.DatabaseSession session,
    CmsUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsUser>> update(
    _i1.DatabaseSession session,
    List<CmsUser> rows, {
    _i1.ColumnSelections<CmsUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsUser>(
      rows,
      columns: columns?.call(CmsUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsUser> updateRow(
    _i1.DatabaseSession session,
    CmsUser row, {
    _i1.ColumnSelections<CmsUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsUser>(
      row,
      columns: columns?.call(CmsUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsUser] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CmsUser?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<CmsUserUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<CmsUser>(
      id,
      columnValues: columnValues(CmsUser.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CmsUser]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<CmsUser>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<CmsUserUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<CmsUserTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<CmsUser>(
      columnValues: columnValues(CmsUser.t.updateTable),
      where: where(CmsUser.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsUser.t),
      orderByList: orderByList?.call(CmsUser.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [CmsUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsUser>> delete(
    _i1.DatabaseSession session,
    List<CmsUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsUser].
  Future<CmsUser> deleteRow(
    _i1.DatabaseSession session,
    CmsUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsUser>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsUser>(
      where: where(CmsUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsUser>(
      where: where?.call(CmsUser.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CmsUser] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<CmsUserTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CmsUser>(
      where: where(CmsUser.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
