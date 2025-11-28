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

abstract class CmsUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsUser._({
    this.id,
    required this.email,
    this.name,
    String? role,
    DateTime? createdAt,
  })  : role = role ?? 'viewer',
        createdAt = createdAt ?? DateTime.now();

  factory CmsUser({
    int? id,
    required String email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) = _CmsUserImpl;

  factory CmsUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsUser(
      id: jsonSerialization['id'] as int?,
      email: jsonSerialization['email'] as String,
      name: jsonSerialization['name'] as String?,
      role: jsonSerialization['role'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = CmsUserTable();

  static const db = CmsUserRepository._();

  @override
  int? id;

  String email;

  String? name;

  String role;

  DateTime? createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsUser copyWith({
    int? id,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'email': email,
      if (name != null) 'name': name,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
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
    required String email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) : super._(
          id: id,
          email: email,
          name: name,
          role: role,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [CmsUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsUser copyWith({
    Object? id = _Undefined,
    String? email,
    Object? name = _Undefined,
    String? role,
    Object? createdAt = _Undefined,
  }) {
    return CmsUser(
      id: id is int? ? id : this.id,
      email: email ?? this.email,
      name: name is String? ? name : this.name,
      role: role ?? this.role,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}

class CmsUserTable extends _i1.Table<int?> {
  CmsUserTable({super.tableRelation}) : super(tableName: 'cms_users') {
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
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final _i1.ColumnString email;

  late final _i1.ColumnString name;

  late final _i1.ColumnString role;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        email,
        name,
        role,
        createdAt,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CmsUser>(
      where: where?.call(CmsUser.t),
      orderBy: orderBy?.call(CmsUser.t),
      orderByList: orderByList?.call(CmsUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
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
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsUserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CmsUser>(
      where: where?.call(CmsUser.t),
      orderBy: orderBy?.call(CmsUser.t),
      orderByList: orderByList?.call(CmsUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CmsUser] by its [id] or null if no such row exists.
  Future<CmsUser?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CmsUser>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CmsUser]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CmsUser>> insert(
    _i1.Session session,
    List<CmsUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CmsUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CmsUser] and returns the inserted row.
  ///
  /// The returned [CmsUser] will have its `id` field set.
  Future<CmsUser> insertRow(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session,
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

  /// Deletes all [CmsUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsUser>> delete(
    _i1.Session session,
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
    _i1.Session session,
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
    _i1.Session session, {
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
    _i1.Session session, {
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
}
