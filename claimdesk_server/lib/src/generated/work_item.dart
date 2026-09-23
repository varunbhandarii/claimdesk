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
import 'work_payload.dart' as _ib3jfnwt;
import 'work_state.dart' as _i6iais05;

abstract class WorkItem
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WorkItem._({
    this.id,
    this.venueId,
    required this.kind,
    required this.payload,
    this.identifier,
    required this.runAt,
    _i6iais05.WorkState? state,
    this.leaseUntil,
    int? attempts,
    int? maxAttempts,
    this.lastError,
    this.completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : state = state ?? _i6iais05.WorkState.pending,
       attempts = attempts ?? 0,
       maxAttempts = maxAttempts ?? 5,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WorkItem({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    required String kind,
    required _ib3jfnwt.WorkPayload payload,
    String? identifier,
    required DateTime runAt,
    _i6iais05.WorkState? state,
    DateTime? leaseUntil,
    int? attempts,
    int? maxAttempts,
    String? lastError,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WorkItemImpl;

  factory WorkItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkItem(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: jsonSerialization['venueId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['venueId']),
      kind: jsonSerialization['kind'] as String,
      payload: _ii1g677k.Protocol().deserialize<_ib3jfnwt.WorkPayload>(
        jsonSerialization['payload'],
      ),
      identifier: jsonSerialization['identifier'] as String?,
      runAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['runAt']),
      state: jsonSerialization['state'] == null
          ? null
          : _i6iais05.WorkState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['leaseUntil']),
      attempts: jsonSerialization['attempts'] as int?,
      maxAttempts: jsonSerialization['maxAttempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = WorkItemTable();

  static const db = WorkItemRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue? venueId;

  String kind;

  _ib3jfnwt.WorkPayload payload;

  String? identifier;

  DateTime runAt;

  _i6iais05.WorkState state;

  DateTime? leaseUntil;

  int attempts;

  int maxAttempts;

  String? lastError;

  DateTime? completedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WorkItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WorkItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    String? kind,
    _ib3jfnwt.WorkPayload? payload,
    String? identifier,
    DateTime? runAt,
    _i6iais05.WorkState? state,
    DateTime? leaseUntil,
    int? attempts,
    int? maxAttempts,
    String? lastError,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkItem',
      if (id != null) 'id': id?.toJson(),
      if (venueId != null) 'venueId': venueId?.toJson(),
      'kind': kind,
      'payload': payload.toJson(),
      if (identifier != null) 'identifier': identifier,
      'runAt': runAt.toJson(),
      'state': state.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'attempts': attempts,
      'maxAttempts': maxAttempts,
      if (lastError != null) 'lastError': lastError,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkItem',
      if (id != null) 'id': id?.toJson(),
      if (venueId != null) 'venueId': venueId?.toJson(),
      'kind': kind,
      'payload': payload.toJsonForProtocol(),
      if (identifier != null) 'identifier': identifier,
      'runAt': runAt.toJson(),
      'state': state.toJson(),
      if (leaseUntil != null) 'leaseUntil': leaseUntil?.toJson(),
      'attempts': attempts,
      'maxAttempts': maxAttempts,
      if (lastError != null) 'lastError': lastError,
      if (completedAt != null) 'completedAt': completedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static WorkItemInclude include() {
    return WorkItemInclude._();
  }

  static WorkItemIncludeList includeList({
    _is.WhereExpressionBuilder<WorkItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    WorkItemInclude? include,
  }) {
    return WorkItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkItemImpl extends WorkItem {
  _WorkItemImpl({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    required String kind,
    required _ib3jfnwt.WorkPayload payload,
    String? identifier,
    required DateTime runAt,
    _i6iais05.WorkState? state,
    DateTime? leaseUntil,
    int? attempts,
    int? maxAttempts,
    String? lastError,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         venueId: venueId,
         kind: kind,
         payload: payload,
         identifier: identifier,
         runAt: runAt,
         state: state,
         leaseUntil: leaseUntil,
         attempts: attempts,
         maxAttempts: maxAttempts,
         lastError: lastError,
         completedAt: completedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WorkItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WorkItem copyWith({
    Object? id = _Undefined,
    Object? venueId = _Undefined,
    String? kind,
    _ib3jfnwt.WorkPayload? payload,
    Object? identifier = _Undefined,
    DateTime? runAt,
    _i6iais05.WorkState? state,
    Object? leaseUntil = _Undefined,
    int? attempts,
    int? maxAttempts,
    Object? lastError = _Undefined,
    Object? completedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkItem(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId is _is.UuidValue? ? venueId : this.venueId,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload.copyWith(),
      identifier: identifier is String? ? identifier : this.identifier,
      runAt: runAt ?? this.runAt,
      state: state ?? this.state,
      leaseUntil: leaseUntil is DateTime? ? leaseUntil : this.leaseUntil,
      attempts: attempts ?? this.attempts,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      lastError: lastError is String? ? lastError : this.lastError,
      completedAt: completedAt is DateTime? ? completedAt : this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WorkItemUpdateTable extends _is.UpdateTable<WorkItemTable> {
  WorkItemUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<_ib3jfnwt.WorkPayload, _ib3jfnwt.WorkPayload> payload(
    _ib3jfnwt.WorkPayload value,
  ) => _is.ColumnValue(
    table.payload,
    value,
  );

  _is.ColumnValue<String, String> identifier(String? value) => _is.ColumnValue(
    table.identifier,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> runAt(DateTime value) => _is.ColumnValue(
    table.runAt,
    value,
  );

  _is.ColumnValue<_i6iais05.WorkState, _i6iais05.WorkState> state(
    _i6iais05.WorkState value,
  ) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> leaseUntil(DateTime? value) =>
      _is.ColumnValue(
        table.leaseUntil,
        value,
      );

  _is.ColumnValue<int, int> attempts(int value) => _is.ColumnValue(
    table.attempts,
    value,
  );

  _is.ColumnValue<int, int> maxAttempts(int value) => _is.ColumnValue(
    table.maxAttempts,
    value,
  );

  _is.ColumnValue<String, String> lastError(String? value) => _is.ColumnValue(
    table.lastError,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> completedAt(DateTime? value) =>
      _is.ColumnValue(
        table.completedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class WorkItemTable extends _is.Table<_is.UuidValue?> {
  WorkItemTable({super.tableRelation}) : super(tableName: 'work_item') {
    updateTable = WorkItemUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    payload = _is.ColumnStructured<_ib3jfnwt.WorkPayload>(
      'payload',
      this,
    );
    identifier = _is.ColumnString(
      'identifier',
      this,
    );
    runAt = _is.ColumnDateTime(
      'runAt',
      this,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    leaseUntil = _is.ColumnDateTime(
      'leaseUntil',
      this,
    );
    attempts = _is.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    maxAttempts = _is.ColumnInt(
      'maxAttempts',
      this,
      hasDefault: true,
    );
    lastError = _is.ColumnString(
      'lastError',
      this,
    );
    completedAt = _is.ColumnDateTime(
      'completedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final WorkItemUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnString kind;

  late final _is.ColumnStructured<_ib3jfnwt.WorkPayload> payload;

  late final _is.ColumnString identifier;

  late final _is.ColumnDateTime runAt;

  late final _is.ColumnEnum<_i6iais05.WorkState> state;

  late final _is.ColumnDateTime leaseUntil;

  late final _is.ColumnInt attempts;

  late final _is.ColumnInt maxAttempts;

  late final _is.ColumnString lastError;

  late final _is.ColumnDateTime completedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    kind,
    payload,
    identifier,
    runAt,
    state,
    leaseUntil,
    attempts,
    maxAttempts,
    lastError,
    completedAt,
    createdAt,
    updatedAt,
  ];
}

class WorkItemInclude extends _is.IncludeObject {
  WorkItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WorkItem.t;
}

class WorkItemIncludeList extends _is.IncludeList {
  WorkItemIncludeList._({
    _is.WhereExpressionBuilder<WorkItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WorkItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WorkItem.t;
}

class WorkItemRepository {
  const WorkItemRepository._();

  /// Returns a list of [WorkItem]s matching the given query parameters.
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
  Future<List<WorkItem>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WorkItem>(
      where: where?.call(WorkItem.t),
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [WorkItem] matching the given query parameters.
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
  Future<WorkItem?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkItemTable>? where,
    int? offset,
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WorkItem>(
      where: where?.call(WorkItem.t),
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WorkItem] by its [id] or null if no such row exists.
  Future<WorkItem?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WorkItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WorkItem]s in the list and returns the inserted rows.
  ///
  /// The returned [WorkItem]s will have their `id` fields set.
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
  Future<List<WorkItem>> insert(
    _is.DatabaseSession session,
    List<WorkItem> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WorkItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WorkItem] and returns the inserted row.
  ///
  /// The returned [WorkItem] will have its `id` field set.
  Future<WorkItem> insertRow(
    _is.DatabaseSession session,
    WorkItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WorkItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WorkItem]s in the list and returns the resulting rows.
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
  /// The returned [WorkItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkItem>> upsert(
    _is.DatabaseSession session,
    List<WorkItem> rows, {
    required _is.ColumnSelections<WorkItemTable> conflictColumns,
    _is.ColumnSelections<WorkItemTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkItemTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WorkItem>(
      rows,
      conflictColumns: conflictColumns(WorkItem.t),
      updateColumns: updateColumns?.call(WorkItem.t),
      updateWhere: updateWhere?.call(WorkItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WorkItem] and returns the resulting row.
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
  /// The returned [WorkItem] will have its `id` field set.
  Future<WorkItem?> upsertRow(
    _is.DatabaseSession session,
    WorkItem row, {
    required _is.ColumnSelections<WorkItemTable> conflictColumns,
    _is.ColumnSelections<WorkItemTable>? updateColumns,
    _is.WhereExpressionBuilder<WorkItemTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WorkItem>(
      row,
      conflictColumns: conflictColumns(WorkItem.t),
      updateColumns: updateColumns?.call(WorkItem.t),
      updateWhere: updateWhere?.call(WorkItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [WorkItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkItem>> update(
    _is.DatabaseSession session,
    List<WorkItem> rows, {
    _is.ColumnSelections<WorkItemTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WorkItem>(
      rows,
      columns: columns?.call(WorkItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WorkItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WorkItem> updateRow(
    _is.DatabaseSession session,
    WorkItem row, {
    _is.ColumnSelections<WorkItemTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WorkItem>(
      row,
      columns: columns?.call(WorkItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WorkItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WorkItem?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WorkItemUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WorkItem>(
      id,
      columnValues: columnValues(WorkItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WorkItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WorkItem>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WorkItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WorkItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WorkItem>(
      columnValues: columnValues(WorkItem.t.updateTable),
      where: where(WorkItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WorkItem]s in the list and returns the deleted rows.
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
  Future<List<WorkItem>> delete(
    _is.DatabaseSession session,
    List<WorkItem> rows, {
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WorkItem>(
      rows,
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WorkItem].
  Future<WorkItem> deleteRow(
    _is.DatabaseSession session,
    WorkItem row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WorkItem>(
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
  Future<List<WorkItem>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkItemTable> where,
    _is.OrderByBuilder<WorkItemTable>? orderBy,
    _is.OrderByListBuilder<WorkItemTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WorkItem>(
      where: where(WorkItem.t),
      orderBy: orderBy?.call(WorkItem.t),
      orderByList: orderByList?.call(WorkItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WorkItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WorkItem>(
      where: where?.call(WorkItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WorkItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WorkItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WorkItem>(
      where: where(WorkItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
