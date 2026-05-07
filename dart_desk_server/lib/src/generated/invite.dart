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
import 'client_role.dart' as _i2;

abstract class Invite
    implements _i1.TableRow<_i1.UuidValue>, _i1.ProtocolSerialization {
  Invite._({
    _i1.UuidValue? id,
    required this.clientId,
    required this.email,
    required this.role,
    required this.token,
    required this.invitedByUserId,
    required this.expiresAt,
    this.acceptedAt,
    this.acceptedUserId,
    this.revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _i1.Uuid().v4obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Invite({
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String email,
    required _i2.ClientRole role,
    required String token,
    required _i1.UuidValue invitedByUserId,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _InviteImpl;

  factory Invite.fromJson(Map<String, dynamic> jsonSerialization) {
    return Invite(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      clientId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['clientId'],
      ),
      email: jsonSerialization['email'] as String,
      role: _i2.ClientRole.fromJson((jsonSerialization['role'] as String)),
      token: jsonSerialization['token'] as String,
      invitedByUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['invitedByUserId'],
      ),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      acceptedAt: jsonSerialization['acceptedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['acceptedAt']),
      acceptedUserId: jsonSerialization['acceptedUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['acceptedUserId'],
            ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = InviteTable();

  static const db = InviteRepository._();

  @override
  _i1.UuidValue id;

  _i1.UuidValue clientId;

  String email;

  _i2.ClientRole role;

  String token;

  _i1.UuidValue invitedByUserId;

  DateTime expiresAt;

  DateTime? acceptedAt;

  _i1.UuidValue? acceptedUserId;

  DateTime? revokedAt;

  DateTime? createdAt;

  DateTime? updatedAt;

  @override
  _i1.Table<_i1.UuidValue> get table => t;

  /// Returns a shallow copy of this [Invite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Invite copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? email,
    _i2.ClientRole? role,
    String? token,
    _i1.UuidValue? invitedByUserId,
    DateTime? expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Invite',
      'id': id.toJson(),
      'clientId': clientId.toJson(),
      'email': email,
      'role': role.toJson(),
      'token': token,
      'invitedByUserId': invitedByUserId.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (acceptedUserId != null) 'acceptedUserId': acceptedUserId?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Invite',
      'id': id.toJson(),
      'clientId': clientId.toJson(),
      'email': email,
      'role': role.toJson(),
      'token': token,
      'invitedByUserId': invitedByUserId.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (acceptedAt != null) 'acceptedAt': acceptedAt?.toJson(),
      if (acceptedUserId != null) 'acceptedUserId': acceptedUserId?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
      if (updatedAt != null) 'updatedAt': updatedAt?.toJson(),
    };
  }

  static InviteInclude include() {
    return InviteInclude._();
  }

  static InviteIncludeList includeList({
    _i1.WhereExpressionBuilder<InviteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InviteTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    InviteInclude? include,
  }) {
    return InviteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use_from_same_package
          orderDescending,
      orderByList: orderByList?.call(Invite.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _InviteImpl extends Invite {
  _InviteImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue clientId,
    required String email,
    required _i2.ClientRole role,
    required String token,
    required _i1.UuidValue invitedByUserId,
    required DateTime expiresAt,
    DateTime? acceptedAt,
    _i1.UuidValue? acceptedUserId,
    DateTime? revokedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         clientId: clientId,
         email: email,
         role: role,
         token: token,
         invitedByUserId: invitedByUserId,
         expiresAt: expiresAt,
         acceptedAt: acceptedAt,
         acceptedUserId: acceptedUserId,
         revokedAt: revokedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Invite]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Invite copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? clientId,
    String? email,
    _i2.ClientRole? role,
    String? token,
    _i1.UuidValue? invitedByUserId,
    DateTime? expiresAt,
    Object? acceptedAt = _Undefined,
    Object? acceptedUserId = _Undefined,
    Object? revokedAt = _Undefined,
    Object? createdAt = _Undefined,
    Object? updatedAt = _Undefined,
  }) {
    return Invite(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      invitedByUserId: invitedByUserId ?? this.invitedByUserId,
      expiresAt: expiresAt ?? this.expiresAt,
      acceptedAt: acceptedAt is DateTime? ? acceptedAt : this.acceptedAt,
      acceptedUserId: acceptedUserId is _i1.UuidValue?
          ? acceptedUserId
          : this.acceptedUserId,
      revokedAt: revokedAt is DateTime? ? revokedAt : this.revokedAt,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
      updatedAt: updatedAt is DateTime? ? updatedAt : this.updatedAt,
    );
  }
}

class InviteUpdateTable extends _i1.UpdateTable<InviteTable> {
  InviteUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> clientId(_i1.UuidValue value) =>
      _i1.ColumnValue(
        table.clientId,
        value,
      );

  _i1.ColumnValue<String, String> email(String value) => _i1.ColumnValue(
    table.email,
    value,
  );

  _i1.ColumnValue<_i2.ClientRole, _i2.ClientRole> role(_i2.ClientRole value) =>
      _i1.ColumnValue(
        table.role,
        value,
      );

  _i1.ColumnValue<String, String> token(String value) => _i1.ColumnValue(
    table.token,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> invitedByUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.invitedByUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _i1.ColumnValue(
        table.expiresAt,
        value,
      );

  _i1.ColumnValue<DateTime, DateTime> acceptedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.acceptedAt,
        value,
      );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> acceptedUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.acceptedUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _i1.ColumnValue(
        table.revokedAt,
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

class InviteTable extends _i1.Table<_i1.UuidValue> {
  InviteTable({super.tableRelation}) : super(tableName: 'invites') {
    updateTable = InviteUpdateTable(this);
    clientId = _i1.ColumnUuid(
      'clientId',
      this,
    );
    email = _i1.ColumnString(
      'email',
      this,
    );
    role = _i1.ColumnEnum(
      'role',
      this,
      _i1.EnumSerialization.byName,
    );
    token = _i1.ColumnString(
      'token',
      this,
    );
    invitedByUserId = _i1.ColumnUuid(
      'invitedByUserId',
      this,
    );
    expiresAt = _i1.ColumnDateTime(
      'expiresAt',
      this,
    );
    acceptedAt = _i1.ColumnDateTime(
      'acceptedAt',
      this,
    );
    acceptedUserId = _i1.ColumnUuid(
      'acceptedUserId',
      this,
    );
    revokedAt = _i1.ColumnDateTime(
      'revokedAt',
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

  late final InviteUpdateTable updateTable;

  late final _i1.ColumnUuid clientId;

  late final _i1.ColumnString email;

  late final _i1.ColumnEnum<_i2.ClientRole> role;

  late final _i1.ColumnString token;

  late final _i1.ColumnUuid invitedByUserId;

  late final _i1.ColumnDateTime expiresAt;

  late final _i1.ColumnDateTime acceptedAt;

  late final _i1.ColumnUuid acceptedUserId;

  late final _i1.ColumnDateTime revokedAt;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    clientId,
    email,
    role,
    token,
    invitedByUserId,
    expiresAt,
    acceptedAt,
    acceptedUserId,
    revokedAt,
    createdAt,
    updatedAt,
  ];
}

class InviteInclude extends _i1.IncludeObject {
  InviteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue> get table => Invite.t;
}

class InviteIncludeList extends _i1.IncludeList {
  InviteIncludeList._({
    _i1.WhereExpressionBuilder<InviteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Invite.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue> get table => Invite.t;
}

class InviteRepository {
  const InviteRepository._();

  /// Returns a list of [Invite]s matching the given query parameters.
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
  Future<List<Invite>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InviteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InviteTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Invite>(
      where: where?.call(Invite.t),
      orderBy: orderBy?.call(Invite.t),
      orderByList: orderByList?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Invite] matching the given query parameters.
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
  Future<Invite?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InviteTable>? where,
    int? offset,
    _i1.OrderByBuilder<InviteTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Invite>(
      where: where?.call(Invite.t),
      orderBy: orderBy?.call(Invite.t),
      orderByList: orderByList?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Invite] by its [id] or null if no such row exists.
  Future<Invite?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Invite>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Invite]s in the list and returns the inserted rows.
  ///
  /// The returned [Invite]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<Invite>> insert(
    _i1.DatabaseSession session,
    List<Invite> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<Invite>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [Invite] and returns the inserted row.
  ///
  /// The returned [Invite] will have its `id` field set.
  Future<Invite> insertRow(
    _i1.DatabaseSession session,
    Invite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Invite>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Invite]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Invite>> update(
    _i1.DatabaseSession session,
    List<Invite> rows, {
    _i1.ColumnSelections<InviteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Invite>(
      rows,
      columns: columns?.call(Invite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Invite]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Invite> updateRow(
    _i1.DatabaseSession session,
    Invite row, {
    _i1.ColumnSelections<InviteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Invite>(
      row,
      columns: columns?.call(Invite.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Invite] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Invite?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<InviteUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Invite>(
      id,
      columnValues: columnValues(Invite.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Invite]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Invite>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<InviteUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<InviteTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<InviteTable>? orderBy,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Invite>(
      columnValues: columnValues(Invite.t.updateTable),
      where: where(Invite.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Invite.t),
      orderByList: orderByList?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Invite]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Invite>> delete(
    _i1.DatabaseSession session,
    List<Invite> rows, {
    _i1.OrderByBuilder<InviteTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Invite>(
      rows,
      orderBy: orderBy?.call(Invite.t),
      orderByList: orderByList?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes a single [Invite].
  Future<Invite> deleteRow(
    _i1.DatabaseSession session,
    Invite row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Invite>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  Future<List<Invite>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InviteTable> where,
    _i1.OrderByBuilder<InviteTable>? orderBy,
    @Deprecated('Use desc() on the orderBy column instead.')
    bool orderDescending = false,
    _i1.OrderByListBuilder<InviteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Invite>(
      where: where(Invite.t),
      orderBy: orderBy?.call(Invite.t),
      orderByList: orderByList?.call(Invite.t),
      orderDescending: // ignore: deprecated_member_use
          orderDescending,
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<InviteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Invite>(
      where: where?.call(Invite.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Invite] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<InviteTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Invite>(
      where: where(Invite.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
