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
import 'match_explanation.dart' as _i7ltg7v2;
import 'match_state.dart' as _idznkk1k;

abstract class ItemMatch
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  ItemMatch._({
    this.id,
    required this.venueId,
    required this.reportId,
    required this.itemId,
    _idznkk1k.MatchState? state,
    required this.score,
    required this.label,
    required this.rank,
    required this.explanation,
    required this.algorithmVersion,
    this.decidedByAuthUserId,
    this.decidedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : state = state ?? _idznkk1k.MatchState.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ItemMatch({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue reportId,
    required _is.UuidValue itemId,
    _idznkk1k.MatchState? state,
    required double score,
    required String label,
    required int rank,
    required _i7ltg7v2.MatchExplanation explanation,
    required String algorithmVersion,
    _is.UuidValue? decidedByAuthUserId,
    DateTime? decidedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ItemMatchImpl;

  factory ItemMatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemMatch(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      reportId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['reportId'],
      ),
      itemId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      state: jsonSerialization['state'] == null
          ? null
          : _idznkk1k.MatchState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      score: (jsonSerialization['score'] as num).toDouble(),
      label: jsonSerialization['label'] as String,
      rank: jsonSerialization['rank'] as int,
      explanation: _ii1g677k.Protocol().deserialize<_i7ltg7v2.MatchExplanation>(
        jsonSerialization['explanation'],
      ),
      algorithmVersion: jsonSerialization['algorithmVersion'] as String,
      decidedByAuthUserId: jsonSerialization['decidedByAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['decidedByAuthUserId'],
            ),
      decidedAt: jsonSerialization['decidedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['decidedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = ItemMatchTable();

  static const db = ItemMatchRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue venueId;

  _is.UuidValue reportId;

  _is.UuidValue itemId;

  _idznkk1k.MatchState state;

  double score;

  String label;

  int rank;

  _i7ltg7v2.MatchExplanation explanation;

  String algorithmVersion;

  _is.UuidValue? decidedByAuthUserId;

  DateTime? decidedAt;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [ItemMatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ItemMatch copyWith({
    _is.UuidValue? id,
    _is.UuidValue? venueId,
    _is.UuidValue? reportId,
    _is.UuidValue? itemId,
    _idznkk1k.MatchState? state,
    double? score,
    String? label,
    int? rank,
    _i7ltg7v2.MatchExplanation? explanation,
    String? algorithmVersion,
    _is.UuidValue? decidedByAuthUserId,
    DateTime? decidedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemMatch',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'reportId': reportId.toJson(),
      'itemId': itemId.toJson(),
      'state': state.toJson(),
      'score': score,
      'label': label,
      'rank': rank,
      'explanation': explanation.toJson(),
      'algorithmVersion': algorithmVersion,
      if (decidedByAuthUserId != null)
        'decidedByAuthUserId': decidedByAuthUserId?.toJson(),
      if (decidedAt != null) 'decidedAt': decidedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ItemMatch',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'reportId': reportId.toJson(),
      'itemId': itemId.toJson(),
      'state': state.toJson(),
      'score': score,
      'label': label,
      'rank': rank,
      'explanation': explanation.toJsonForProtocol(),
      'algorithmVersion': algorithmVersion,
      if (decidedByAuthUserId != null)
        'decidedByAuthUserId': decidedByAuthUserId?.toJson(),
      if (decidedAt != null) 'decidedAt': decidedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static ItemMatchInclude include() {
    return ItemMatchInclude._();
  }

  static ItemMatchIncludeList includeList({
    _is.WhereExpressionBuilder<ItemMatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    ItemMatchInclude? include,
  }) {
    return ItemMatchIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemMatchImpl extends ItemMatch {
  _ItemMatchImpl({
    _is.UuidValue? id,
    required _is.UuidValue venueId,
    required _is.UuidValue reportId,
    required _is.UuidValue itemId,
    _idznkk1k.MatchState? state,
    required double score,
    required String label,
    required int rank,
    required _i7ltg7v2.MatchExplanation explanation,
    required String algorithmVersion,
    _is.UuidValue? decidedByAuthUserId,
    DateTime? decidedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         venueId: venueId,
         reportId: reportId,
         itemId: itemId,
         state: state,
         score: score,
         label: label,
         rank: rank,
         explanation: explanation,
         algorithmVersion: algorithmVersion,
         decidedByAuthUserId: decidedByAuthUserId,
         decidedAt: decidedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [ItemMatch]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ItemMatch copyWith({
    Object? id = _Undefined,
    _is.UuidValue? venueId,
    _is.UuidValue? reportId,
    _is.UuidValue? itemId,
    _idznkk1k.MatchState? state,
    double? score,
    String? label,
    int? rank,
    _i7ltg7v2.MatchExplanation? explanation,
    String? algorithmVersion,
    Object? decidedByAuthUserId = _Undefined,
    Object? decidedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ItemMatch(
      id: id is _is.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      reportId: reportId ?? this.reportId,
      itemId: itemId ?? this.itemId,
      state: state ?? this.state,
      score: score ?? this.score,
      label: label ?? this.label,
      rank: rank ?? this.rank,
      explanation: explanation ?? this.explanation.copyWith(),
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      decidedByAuthUserId: decidedByAuthUserId is _is.UuidValue?
          ? decidedByAuthUserId
          : this.decidedByAuthUserId,
      decidedAt: decidedAt is DateTime? ? decidedAt : this.decidedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ItemMatchUpdateTable extends _is.UpdateTable<ItemMatchTable> {
  ItemMatchUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> venueId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.venueId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> reportId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.reportId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> itemId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.itemId,
        value,
      );

  _is.ColumnValue<_idznkk1k.MatchState, _idznkk1k.MatchState> state(
    _idznkk1k.MatchState value,
  ) => _is.ColumnValue(
    table.state,
    value,
  );

  _is.ColumnValue<double, double> score(double value) => _is.ColumnValue(
    table.score,
    value,
  );

  _is.ColumnValue<String, String> label(String value) => _is.ColumnValue(
    table.label,
    value,
  );

  _is.ColumnValue<int, int> rank(int value) => _is.ColumnValue(
    table.rank,
    value,
  );

  _is.ColumnValue<_i7ltg7v2.MatchExplanation, _i7ltg7v2.MatchExplanation>
  explanation(_i7ltg7v2.MatchExplanation value) => _is.ColumnValue(
    table.explanation,
    value,
  );

  _is.ColumnValue<String, String> algorithmVersion(String value) =>
      _is.ColumnValue(
        table.algorithmVersion,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> decidedByAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.decidedByAuthUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> decidedAt(DateTime? value) =>
      _is.ColumnValue(
        table.decidedAt,
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

class ItemMatchTable extends _is.Table<_is.UuidValue?> {
  ItemMatchTable({super.tableRelation}) : super(tableName: 'item_match') {
    updateTable = ItemMatchUpdateTable(this);
    venueId = _is.ColumnUuid(
      'venueId',
      this,
    );
    reportId = _is.ColumnUuid(
      'reportId',
      this,
    );
    itemId = _is.ColumnUuid(
      'itemId',
      this,
    );
    state = _is.ColumnEnum(
      'state',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    score = _is.ColumnDouble(
      'score',
      this,
    );
    label = _is.ColumnString(
      'label',
      this,
    );
    rank = _is.ColumnInt(
      'rank',
      this,
    );
    explanation = _is.ColumnStructured<_i7ltg7v2.MatchExplanation>(
      'explanation',
      this,
    );
    algorithmVersion = _is.ColumnString(
      'algorithmVersion',
      this,
    );
    decidedByAuthUserId = _is.ColumnUuid(
      'decidedByAuthUserId',
      this,
    );
    decidedAt = _is.ColumnDateTime(
      'decidedAt',
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

  late final ItemMatchUpdateTable updateTable;

  late final _is.ColumnUuid venueId;

  late final _is.ColumnUuid reportId;

  late final _is.ColumnUuid itemId;

  late final _is.ColumnEnum<_idznkk1k.MatchState> state;

  late final _is.ColumnDouble score;

  late final _is.ColumnString label;

  late final _is.ColumnInt rank;

  late final _is.ColumnStructured<_i7ltg7v2.MatchExplanation> explanation;

  late final _is.ColumnString algorithmVersion;

  late final _is.ColumnUuid decidedByAuthUserId;

  late final _is.ColumnDateTime decidedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    venueId,
    reportId,
    itemId,
    state,
    score,
    label,
    rank,
    explanation,
    algorithmVersion,
    decidedByAuthUserId,
    decidedAt,
    createdAt,
    updatedAt,
  ];
}

class ItemMatchInclude extends _is.IncludeObject {
  ItemMatchInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => ItemMatch.t;
}

class ItemMatchIncludeList extends _is.IncludeList {
  ItemMatchIncludeList._({
    _is.WhereExpressionBuilder<ItemMatchTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ItemMatch.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => ItemMatch.t;
}

class ItemMatchRepository {
  const ItemMatchRepository._();

  /// Returns a list of [ItemMatch]s matching the given query parameters.
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
  Future<List<ItemMatch>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ItemMatchTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ItemMatch>(
      where: where?.call(ItemMatch.t),
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ItemMatch] matching the given query parameters.
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
  Future<ItemMatch?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ItemMatchTable>? where,
    int? offset,
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ItemMatch>(
      where: where?.call(ItemMatch.t),
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ItemMatch] by its [id] or null if no such row exists.
  Future<ItemMatch?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ItemMatch>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ItemMatch]s in the list and returns the inserted rows.
  ///
  /// The returned [ItemMatch]s will have their `id` fields set.
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
  Future<List<ItemMatch>> insert(
    _is.DatabaseSession session,
    List<ItemMatch> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ItemMatch>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ItemMatch] and returns the inserted row.
  ///
  /// The returned [ItemMatch] will have its `id` field set.
  Future<ItemMatch> insertRow(
    _is.DatabaseSession session,
    ItemMatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ItemMatch>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ItemMatch]s in the list and returns the resulting rows.
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
  /// The returned [ItemMatch]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ItemMatch>> upsert(
    _is.DatabaseSession session,
    List<ItemMatch> rows, {
    required _is.ColumnSelections<ItemMatchTable> conflictColumns,
    _is.ColumnSelections<ItemMatchTable>? updateColumns,
    _is.WhereExpressionBuilder<ItemMatchTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ItemMatch>(
      rows,
      conflictColumns: conflictColumns(ItemMatch.t),
      updateColumns: updateColumns?.call(ItemMatch.t),
      updateWhere: updateWhere?.call(ItemMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ItemMatch] and returns the resulting row.
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
  /// The returned [ItemMatch] will have its `id` field set.
  Future<ItemMatch?> upsertRow(
    _is.DatabaseSession session,
    ItemMatch row, {
    required _is.ColumnSelections<ItemMatchTable> conflictColumns,
    _is.ColumnSelections<ItemMatchTable>? updateColumns,
    _is.WhereExpressionBuilder<ItemMatchTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ItemMatch>(
      row,
      conflictColumns: conflictColumns(ItemMatch.t),
      updateColumns: updateColumns?.call(ItemMatch.t),
      updateWhere: updateWhere?.call(ItemMatch.t),
      transaction: transaction,
    );
  }

  /// Updates all [ItemMatch]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ItemMatch>> update(
    _is.DatabaseSession session,
    List<ItemMatch> rows, {
    _is.ColumnSelections<ItemMatchTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ItemMatch>(
      rows,
      columns: columns?.call(ItemMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ItemMatch]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ItemMatch> updateRow(
    _is.DatabaseSession session,
    ItemMatch row, {
    _is.ColumnSelections<ItemMatchTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ItemMatch>(
      row,
      columns: columns?.call(ItemMatch.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ItemMatch] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ItemMatch?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ItemMatchUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ItemMatch>(
      id,
      columnValues: columnValues(ItemMatch.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ItemMatch]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ItemMatch>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ItemMatchUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ItemMatchTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ItemMatch>(
      columnValues: columnValues(ItemMatch.t.updateTable),
      where: where(ItemMatch.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ItemMatch]s in the list and returns the deleted rows.
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
  Future<List<ItemMatch>> delete(
    _is.DatabaseSession session,
    List<ItemMatch> rows, {
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ItemMatch>(
      rows,
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ItemMatch].
  Future<ItemMatch> deleteRow(
    _is.DatabaseSession session,
    ItemMatch row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ItemMatch>(
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
  Future<List<ItemMatch>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ItemMatchTable> where,
    _is.OrderByBuilder<ItemMatchTable>? orderBy,
    _is.OrderByListBuilder<ItemMatchTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ItemMatch>(
      where: where(ItemMatch.t),
      orderBy: orderBy?.call(ItemMatch.t),
      orderByList: orderByList?.call(ItemMatch.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ItemMatchTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ItemMatch>(
      where: where?.call(ItemMatch.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ItemMatch] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ItemMatchTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ItemMatch>(
      where: where(ItemMatch.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
