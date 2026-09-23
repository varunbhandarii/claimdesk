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
import 'package:claimdesk_server/src/generated/protocol.dart' as _ii1g677k;
import 'package:serverpod/serverpod.dart' as _is;
import 'audit_payload.dart' as _imod1ub6;

abstract class AuditEvent
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  AuditEvent._({
    this.id,
    required this.venueId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.actorAuthUserId,
    this.payload,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  factory AuditEvent({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required String entityType,
    required _is.UuidValue entityId,
    required String action,
    _is.UuidValue? actorAuthUserId,
    _imod1ub6.AuditPayload? payload,
    DateTime? at,
  }) = _AuditEventImpl;

  factory AuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      entityType: jsonSerialization['entityType'] as String,
      entityId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      action: jsonSerialization['action'] as String,
      actorAuthUserId: jsonSerialization['actorAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['actorAuthUserId'],
            ),
      payload: jsonSerialization['payload'] == null
          ? null
          : _ii1g677k.Protocol().deserialize<_imod1ub6.AuditPayload>(
              jsonSerialization['payload'],
            ),
      at: jsonSerialization['at'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  static final t = AuditEventTable();

  static const db = AuditEventRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  String entityType;

  _is.UuidValue entityId;

  String action;

  _is.UuidValue? actorAuthUserId;

  _imod1ub6.AuditPayload? payload;

  DateTime at;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AuditEvent copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    String? entityType,
    _is.UuidValue? entityId,
    String? action,
    _is.UuidValue? actorAuthUserId,
    _imod1ub6.AuditPayload? payload,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'entityType': entityType,
      'entityId': entityId.toJson(),
      'action': action,
      if (actorAuthUserId != null) 'actorAuthUserId': actorAuthUserId?.toJson(),
      if (payload != null) 'payload': payload?.toJson(),
      'at': at.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEvent',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'entityType': entityType,
      'entityId': entityId.toJson(),
      'action': action,
      if (actorAuthUserId != null) 'actorAuthUserId': actorAuthUserId?.toJson(),
      if (payload != null) 'payload': payload?.toJsonForProtocol(),
      'at': at.toJson(),
    };
  }

  static AuditEventInclude include() {
    return AuditEventInclude._();
  }

  static AuditEventIncludeList includeList({
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    AuditEventInclude? include,
  }) {
    return AuditEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEventImpl extends AuditEvent {
  _AuditEventImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required String entityType,
    required _is.UuidValue entityId,
    required String action,
    _is.UuidValue? actorAuthUserId,
    _imod1ub6.AuditPayload? payload,
    DateTime? at,
  }) : super._(
         id: id,
         venueId: venueId,
         entityType: entityType,
         entityId: entityId,
         action: action,
         actorAuthUserId: actorAuthUserId,
         payload: payload,
         at: at,
       );

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AuditEvent copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    String? entityType,
    _is.UuidValue? entityId,
    String? action,
    Object? actorAuthUserId = _Undefined,
    Object? payload = _Undefined,
    DateTime? at,
  }) {
    return AuditEvent(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      actorAuthUserId: actorAuthUserId is _is.UuidValue?
          ? actorAuthUserId
          : this.actorAuthUserId,
      payload: payload is _imod1ub6.AuditPayload?
          ? payload
          : this.payload?.copyWith(),
      at: at ?? this.at,
    );
  }
}

class AuditEventUpdateTable extends _is.UpdateTable<AuditEventTable> {
  AuditEventUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<String, String> entityType(String value) => _is.ColumnValue(
    table.entityType,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> entityId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.entityId,
        value,
      );

  _is.ColumnValue<String, String> action(String value) => _is.ColumnValue(
    table.action,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> actorAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.actorAuthUserId,
    value,
  );

  _is.ColumnValue<_imod1ub6.AuditPayload, _imod1ub6.AuditPayload> payload(
    _imod1ub6.AuditPayload? value,
  ) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );
}

class AuditEventTable extends _is.Table<_is.UuidValue?> {
  AuditEventTable({super.tableRelation}) : super(tableName: 'audit_event') {
    updateTable = AuditEventUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    entityType = _is.ColumnString(
      'entityType',
      this,
    );
    entityId = _is.ColumnUuid(
      'entityId',
      this,
    );
    action = _is.ColumnString(
      'action',
      this,
    );
    actorAuthUserId = _is.ColumnUuid(
      'actorAuthUserId',
      this,
    );
    payload = _is.ColumnStructured<_imod1ub6.AuditPayload>(
      'payload',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
      hasDefault: true,
    );
  }

  late final AuditEventUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnString entityType;

  late final _is.ColumnUuid entityId;

  late final _is.ColumnString action;

  late final _is.ColumnUuid actorAuthUserId;

  late final _is.ColumnStructured<_imod1ub6.AuditPayload> payload;

  late final _is.ColumnDateTime at;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    entityType,
    entityId,
    action,
    actorAuthUserId,
    payload,
    at,
  ];
}

class AuditEventInclude extends _is.IncludeObject {
  AuditEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => AuditEvent.t;
}

class AuditEventIncludeList extends _is.IncludeList {
  AuditEventIncludeList._({
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(AuditEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => AuditEvent.t;
}

class AuditEventRepository {
  const AuditEventRepository._();

  /// Returns a list of [AuditEvent]s matching the given query parameters.
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
  Future<List<AuditEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<AuditEvent>(
      where: where?.call(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [AuditEvent] matching the given query parameters.
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
  Future<AuditEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<AuditEvent>(
      where: where?.call(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [AuditEvent] by its [id] or null if no such row exists.
  Future<AuditEvent?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<AuditEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [AuditEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [AuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> insert(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<AuditEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [AuditEvent] and returns the inserted row.
  ///
  /// The returned [AuditEvent] will have its `id` field set.
  Future<AuditEvent> insertRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<AuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [AuditEvent]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [AuditEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> upsert(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    required _is.ColumnSelections<AuditEventTable> conflictColumns,
    _is.ColumnSelections<AuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<AuditEvent>(
      rows,
      conflictColumns: conflictColumns(AuditEvent.t),
      updateColumns: updateColumns?.call(AuditEvent.t),
      updateWhere: updateWhere?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [AuditEvent] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [AuditEvent] will have its `id` field set.
  Future<AuditEvent?> upsertRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    required _is.ColumnSelections<AuditEventTable> conflictColumns,
    _is.ColumnSelections<AuditEventTable>? updateColumns,
    _is.WhereExpressionBuilder<AuditEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<AuditEvent>(
      row,
      conflictColumns: conflictColumns(AuditEvent.t),
      updateColumns: updateColumns?.call(AuditEvent.t),
      updateWhere: updateWhere?.call(AuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> update(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.ColumnSelections<AuditEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<AuditEvent>(
      rows,
      columns: columns?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [AuditEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<AuditEvent> updateRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.ColumnSelections<AuditEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<AuditEvent>(
      row,
      columns: columns?.call(AuditEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [AuditEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<AuditEvent?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AuditEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<AuditEvent>(
      id,
      columnValues: columnValues(AuditEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [AuditEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AuditEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<AuditEvent>(
      columnValues: columnValues(AuditEvent.t.updateTable),
      where: where(AuditEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [AuditEvent]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> delete(
    _is.DatabaseSession session,
    List<AuditEvent> rows, {
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<AuditEvent>(
      rows,
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [AuditEvent].
  Future<AuditEvent> deleteRow(
    _is.DatabaseSession session,
    AuditEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<AuditEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<AuditEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    _is.OrderByBuilder<AuditEventTable>? orderBy,
    _is.OrderByListBuilder<AuditEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<AuditEvent>(
      where: where(AuditEvent.t),
      orderBy: orderBy?.call(AuditEvent.t),
      orderByList: orderByList?.call(AuditEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AuditEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<AuditEvent>(
      where: where?.call(AuditEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [AuditEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AuditEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<AuditEvent>(
      where: where(AuditEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
