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

abstract class CmsClientUser
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  CmsClientUser._({
    this.id,
    required this.clientId,
    required this.cmsUserId,
    required this.role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : isActive = isActive ?? true,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CmsClientUser({
    int? id,
    required int clientId,
    required int cmsUserId,
    required String role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CmsClientUserImpl;

  factory CmsClientUser.fromJson(Map<String, dynamic> jsonSerialization) {
    return CmsClientUser(
      id: jsonSerialization['id'] as int?,
      clientId: jsonSerialization['clientId'] as int,
      cmsUserId: jsonSerialization['cmsUserId'] as int,
      role: jsonSerialization['role'] as String,
      isActive: jsonSerialization['isActive'] as bool,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = CmsClientUserTable();

  static const db = CmsClientUserRepository._();

  @override
  int? id;

  int clientId;

  int cmsUserId;

  String role;

  bool isActive;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [CmsClientUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  CmsClientUser copyWith({
    int? id,
    int? clientId,
    int? cmsUserId,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'cmsUserId': cmsUserId,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'clientId': clientId,
      'cmsUserId': cmsUserId,
      'role': role,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static CmsClientUserInclude include() {
    return CmsClientUserInclude._();
  }

  static CmsClientUserIncludeList includeList({
    _i1.WhereExpressionBuilder<CmsClientUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsClientUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientUserTable>? orderByList,
    CmsClientUserInclude? include,
  }) {
    return CmsClientUserIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CmsClientUser.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(CmsClientUser.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CmsClientUserImpl extends CmsClientUser {
  _CmsClientUserImpl({
    int? id,
    required int clientId,
    required int cmsUserId,
    required String role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
          id: id,
          clientId: clientId,
          cmsUserId: cmsUserId,
          role: role,
          isActive: isActive,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [CmsClientUser]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  CmsClientUser copyWith({
    Object? id = _Undefined,
    int? clientId,
    int? cmsUserId,
    String? role,
    bool? isActive,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return CmsClientUser(
      id: id is int? ? id : this.id,
      clientId: clientId ?? this.clientId,
      cmsUserId: cmsUserId ?? this.cmsUserId,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class CmsClientUserTable extends _i1.Table<int?> {
  CmsClientUserTable({super.tableRelation})
      : super(tableName: 'cms_client_users') {
    clientId = _i1.ColumnInt(
      'clientId',
      this,
    );
    cmsUserId = _i1.ColumnInt(
      'cmsUserId',
      this,
    );
    role = _i1.ColumnString(
      'role',
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
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final _i1.ColumnInt clientId;

  late final _i1.ColumnInt cmsUserId;

  late final _i1.ColumnString role;

  late final _i1.ColumnBool isActive;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        clientId,
        cmsUserId,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}

class CmsClientUserInclude extends _i1.IncludeObject {
  CmsClientUserInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => CmsClientUser.t;
}

class CmsClientUserIncludeList extends _i1.IncludeList {
  CmsClientUserIncludeList._({
    _i1.WhereExpressionBuilder<CmsClientUserTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CmsClientUser.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => CmsClientUser.t;
}

class CmsClientUserRepository {
  const CmsClientUserRepository._();

  /// Returns a list of [CmsClientUser]s matching the given query parameters.
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
  Future<List<CmsClientUser>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsClientUserTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<CmsClientUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientUserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<CmsClientUser>(
      where: where?.call(CmsClientUser.t),
      orderBy: orderBy?.call(CmsClientUser.t),
      orderByList: orderByList?.call(CmsClientUser.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [CmsClientUser] matching the given query parameters.
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
  Future<CmsClientUser?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsClientUserTable>? where,
    int? offset,
    _i1.OrderByBuilder<CmsClientUserTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<CmsClientUserTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<CmsClientUser>(
      where: where?.call(CmsClientUser.t),
      orderBy: orderBy?.call(CmsClientUser.t),
      orderByList: orderByList?.call(CmsClientUser.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [CmsClientUser] by its [id] or null if no such row exists.
  Future<CmsClientUser?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<CmsClientUser>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [CmsClientUser]s in the list and returns the inserted rows.
  ///
  /// The returned [CmsClientUser]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<CmsClientUser>> insert(
    _i1.Session session,
    List<CmsClientUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<CmsClientUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [CmsClientUser] and returns the inserted row.
  ///
  /// The returned [CmsClientUser] will have its `id` field set.
  Future<CmsClientUser> insertRow(
    _i1.Session session,
    CmsClientUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<CmsClientUser>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [CmsClientUser]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<CmsClientUser>> update(
    _i1.Session session,
    List<CmsClientUser> rows, {
    _i1.ColumnSelections<CmsClientUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<CmsClientUser>(
      rows,
      columns: columns?.call(CmsClientUser.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CmsClientUser]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CmsClientUser> updateRow(
    _i1.Session session,
    CmsClientUser row, {
    _i1.ColumnSelections<CmsClientUserTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<CmsClientUser>(
      row,
      columns: columns?.call(CmsClientUser.t),
      transaction: transaction,
    );
  }

  /// Deletes all [CmsClientUser]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<CmsClientUser>> delete(
    _i1.Session session,
    List<CmsClientUser> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<CmsClientUser>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [CmsClientUser].
  Future<CmsClientUser> deleteRow(
    _i1.Session session,
    CmsClientUser row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CmsClientUser>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<CmsClientUser>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<CmsClientUserTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<CmsClientUser>(
      where: where(CmsClientUser.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<CmsClientUserTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<CmsClientUser>(
      where: where?.call(CmsClientUser.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
