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
import 'package:serverpod/serverpod.dart' as _is;

abstract class CustodyEvent
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  CustodyEvent._({
    this.id,
    required this.venueId,
    required this.itemId,
    required this.fromLocation,
    required this.toLocation,
    this.reference,
    required this.byAuthUserId,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  factory CustodyEvent({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    required String fromLocation,
    required String toLocation,
    String? reference,
    required _is.UuidValue byAuthUserId,
    DateTime? at,
  }) = _CustodyEventImpl;

  factory CustodyEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustodyEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      fromLocation: jsonSerialization['fromLocation'] as String,
      toLocation: jsonSerialization['toLocation'] as String,
      reference: jsonSerialization['reference'] as String?,
      byAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['byAuthUserId'],
      ),
      at: jsonSerialization['at'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  static final t = CustodyEventTable();

  static const db = CustodyEventRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue itemId;

  String fromLocation;

  String toLocation;

  String? reference;

  _is.UuidValue byAuthUserId;

  DateTime at;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [CustodyEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustodyEvent copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    String? fromLocation,
    String? toLocation,
    String? reference,
    _is.UuidValue? byAuthUserId,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustodyEvent',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      if (reference != null) 'reference': reference,
      'byAuthUserId': byAuthUserId.toJson(),
      'at': at.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustodyEvent',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      if (reference != null) 'reference': reference,
      'byAuthUserId': byAuthUserId.toJson(),
      'at': at.toJson(),
    };
  }

  static CustodyEventInclude include() {
    return CustodyEventInclude._();
  }

  static CustodyEventIncludeList includeList({
    _is.WhereExpressionBuilder<CustodyEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    CustodyEventInclude? include,
  }) {
    return CustodyEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustodyEventImpl extends CustodyEvent {
  _CustodyEventImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue itemId,
    required String fromLocation,
    required String toLocation,
    String? reference,
    required _is.UuidValue byAuthUserId,
    DateTime? at,
  }) : super._(
         id: id,
         venueId: venueId,
         itemId: itemId,
         fromLocation: fromLocation,
         toLocation: toLocation,
         reference: reference,
         byAuthUserId: byAuthUserId,
         at: at,
       );

  /// Returns a shallow copy of this [CustodyEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustodyEvent copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    String? fromLocation,
    String? toLocation,
    Object? reference = _Undefined,
    _is.UuidValue? byAuthUserId,
    DateTime? at,
  }) {
    return CustodyEvent(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      itemId: itemId ?? this.itemId,
      fromLocation: fromLocation ?? this.fromLocation,
      toLocation: toLocation ?? this.toLocation,
      reference: reference is String? ? reference : this.reference,
      byAuthUserId: byAuthUserId ?? this.byAuthUserId,
      at: at ?? this.at,
    );
  }
}

class CustodyEventUpdateTable extends _is.UpdateTable<CustodyEventTable> {
  CustodyEventUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> itemId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.itemId,
        value,
      );

  _is.ColumnValue<String, String> fromLocation(String value) => _is.ColumnValue(
    table.fromLocation,
    value,
  );

  _is.ColumnValue<String, String> toLocation(String value) => _is.ColumnValue(
    table.toLocation,
    value,
  );

  _is.ColumnValue<String, String> reference(String? value) => _is.ColumnValue(
    table.reference,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> byAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.byAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> at(DateTime value) => _is.ColumnValue(
    table.at,
    value,
  );
}

class CustodyEventTable extends _is.Table<_is.UuidValue?> {
  CustodyEventTable({super.tableRelation}) : super(tableName: 'custody_event') {
    updateTable = CustodyEventUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    itemId = _is.ColumnUuid(
      'itemId',
      this,
    );
    fromLocation = _is.ColumnString(
      'fromLocation',
      this,
    );
    toLocation = _is.ColumnString(
      'toLocation',
      this,
    );
    reference = _is.ColumnString(
      'reference',
      this,
    );
    byAuthUserId = _is.ColumnUuid(
      'byAuthUserId',
      this,
    );
    at = _is.ColumnDateTime(
      'at',
      this,
      hasDefault: true,
    );
  }

  late final CustodyEventUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid itemId;

  late final _is.ColumnString fromLocation;

  late final _is.ColumnString toLocation;

  late final _is.ColumnString reference;

  late final _is.ColumnUuid byAuthUserId;

  late final _is.ColumnDateTime at;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    itemId,
    fromLocation,
    toLocation,
    reference,
    byAuthUserId,
    at,
  ];
}

class CustodyEventInclude extends _is.IncludeObject {
  CustodyEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => CustodyEvent.t;
}

class CustodyEventIncludeList extends _is.IncludeList {
  CustodyEventIncludeList._({
    _is.WhereExpressionBuilder<CustodyEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustodyEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => CustodyEvent.t;
}

class CustodyEventRepository {
  const CustodyEventRepository._();

  /// Returns a list of [CustodyEvent]s matching the given query parameters.
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
  Future<List<CustodyEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustodyEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustodyEvent>(
      where: where?.call(CustodyEvent.t),
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CustodyEvent] matching the given query parameters.
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
  Future<CustodyEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustodyEventTable>? where,
    int? offset,
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustodyEvent>(
      where: where?.call(CustodyEvent.t),
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustodyEvent] by its [id] or null if no such row exists.
  Future<CustodyEvent?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustodyEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustodyEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [CustodyEvent]s will have their `id` fields set.
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
  Future<List<CustodyEvent>> insert(
    _is.DatabaseSession session,
    List<CustodyEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustodyEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustodyEvent] and returns the inserted row.
  ///
  /// The returned [CustodyEvent] will have its `id` field set.
  Future<CustodyEvent> insertRow(
    _is.DatabaseSession session,
    CustodyEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustodyEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustodyEvent]s in the list and returns the resulting rows.
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
  /// The returned [CustodyEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustodyEvent>> upsert(
    _is.DatabaseSession session,
    List<CustodyEvent> rows, {
    required _is.ColumnSelections<CustodyEventTable> conflictColumns,
    _is.ColumnSelections<CustodyEventTable>? updateColumns,
    _is.WhereExpressionBuilder<CustodyEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustodyEvent>(
      rows,
      conflictColumns: conflictColumns(CustodyEvent.t),
      updateColumns: updateColumns?.call(CustodyEvent.t),
      updateWhere: updateWhere?.call(CustodyEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustodyEvent] and returns the resulting row.
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
  /// The returned [CustodyEvent] will have its `id` field set.
  Future<CustodyEvent?> upsertRow(
    _is.DatabaseSession session,
    CustodyEvent row, {
    required _is.ColumnSelections<CustodyEventTable> conflictColumns,
    _is.ColumnSelections<CustodyEventTable>? updateColumns,
    _is.WhereExpressionBuilder<CustodyEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustodyEvent>(
      row,
      conflictColumns: conflictColumns(CustodyEvent.t),
      updateColumns: updateColumns?.call(CustodyEvent.t),
      updateWhere: updateWhere?.call(CustodyEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustodyEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustodyEvent>> update(
    _is.DatabaseSession session,
    List<CustodyEvent> rows, {
    _is.ColumnSelections<CustodyEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustodyEvent>(
      rows,
      columns: columns?.call(CustodyEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustodyEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustodyEvent> updateRow(
    _is.DatabaseSession session,
    CustodyEvent row, {
    _is.ColumnSelections<CustodyEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustodyEvent>(
      row,
      columns: columns?.call(CustodyEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustodyEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustodyEvent?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CustodyEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustodyEvent>(
      id,
      columnValues: columnValues(CustodyEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustodyEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustodyEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustodyEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CustodyEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustodyEvent>(
      columnValues: columnValues(CustodyEvent.t.updateTable),
      where: where(CustodyEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustodyEvent]s in the list and returns the deleted rows.
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
  Future<List<CustodyEvent>> delete(
    _is.DatabaseSession session,
    List<CustodyEvent> rows, {
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustodyEvent>(
      rows,
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustodyEvent].
  Future<CustodyEvent> deleteRow(
    _is.DatabaseSession session,
    CustodyEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustodyEvent>(
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
  Future<List<CustodyEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustodyEventTable> where,
    _is.OrderByBuilder<CustodyEventTable>? orderBy,
    _is.OrderByListBuilder<CustodyEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustodyEvent>(
      where: where(CustodyEvent.t),
      orderBy: orderBy?.call(CustodyEvent.t),
      orderByList: orderByList?.call(CustodyEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustodyEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustodyEvent>(
      where: where?.call(CustodyEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustodyEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustodyEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustodyEvent>(
      where: where(CustodyEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
