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
import 'retention_policy.dart' as _ic8ul1lq;

abstract class Venue
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  Venue._({
    this.id,
    required this.name,
    required this.slug,
    String? timezone,
    this.deskHours,
    this.pickupInstructions,
    this.retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) : timezone = timezone ?? 'America/New_York',
       policeHandoffThresholdCents = policeHandoffThresholdCents ?? 2000,
       policeHandoffDays = policeHandoffDays ?? 10,
       createdAt = createdAt ?? DateTime.now();

  factory Venue({
    _is.UuidValue? id,
    required String name,
    required String slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) = _VenueImpl;

  factory Venue.fromJson(Map<String, dynamic> jsonSerialization) {
    return Venue(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      slug: jsonSerialization['slug'] as String,
      timezone: jsonSerialization['timezone'] as String?,
      deskHours: jsonSerialization['deskHours'] as String?,
      pickupInstructions: jsonSerialization['pickupInstructions'] as String?,
      retentionPolicy: jsonSerialization['retentionPolicy'] == null
          ? null
          : _ii1g677k.Protocol().deserialize<_ic8ul1lq.RetentionPolicy>(
              jsonSerialization['retentionPolicy'],
            ),
      policeHandoffThresholdCents:
          jsonSerialization['policeHandoffThresholdCents'] as int?,
      policeHandoffDays: jsonSerialization['policeHandoffDays'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = VenueTable();

  static const db = VenueRepository._();

  @override
  _is.UuidValue? id;

  String name;

  String slug;

  String timezone;

  String? deskHours;

  String? pickupInstructions;

  _ic8ul1lq.RetentionPolicy? retentionPolicy;

  int policeHandoffThresholdCents;

  int policeHandoffDays;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [Venue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Venue copyWith({
    _is.UuidValue? id,
    String? name,
    String? slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Venue',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'slug': slug,
      'timezone': timezone,
      if (deskHours != null) 'deskHours': deskHours,
      if (pickupInstructions != null) 'pickupInstructions': pickupInstructions,
      if (retentionPolicy != null) 'retentionPolicy': retentionPolicy?.toJson(),
      'policeHandoffThresholdCents': policeHandoffThresholdCents,
      'policeHandoffDays': policeHandoffDays,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Venue',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'slug': slug,
      'timezone': timezone,
      if (deskHours != null) 'deskHours': deskHours,
      if (pickupInstructions != null) 'pickupInstructions': pickupInstructions,
      if (retentionPolicy != null)
        'retentionPolicy': retentionPolicy?.toJsonForProtocol(),
      'policeHandoffThresholdCents': policeHandoffThresholdCents,
      'policeHandoffDays': policeHandoffDays,
      'createdAt': createdAt.toJson(),
    };
  }

  static VenueInclude include() {
    return VenueInclude._();
  }

  static VenueIncludeList includeList({
    _is.WhereExpressionBuilder<VenueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    VenueInclude? include,
  }) {
    return VenueIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VenueImpl extends Venue {
  _VenueImpl({
    _is.UuidValue? id,
    required String name,
    required String slug,
    String? timezone,
    String? deskHours,
    String? pickupInstructions,
    _ic8ul1lq.RetentionPolicy? retentionPolicy,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         slug: slug,
         timezone: timezone,
         deskHours: deskHours,
         pickupInstructions: pickupInstructions,
         retentionPolicy: retentionPolicy,
         policeHandoffThresholdCents: policeHandoffThresholdCents,
         policeHandoffDays: policeHandoffDays,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Venue]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Venue copyWith({
    Object? id = _Undefined,
    String? name,
    String? slug,
    String? timezone,
    Object? deskHours = _Undefined,
    Object? pickupInstructions = _Undefined,
    Object? retentionPolicy = _Undefined,
    int? policeHandoffThresholdCents,
    int? policeHandoffDays,
    DateTime? createdAt,
  }) {
    return Venue(
      id: id is _is.UuidValue? ? id : this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      timezone: timezone ?? this.timezone,
      deskHours: deskHours is String? ? deskHours : this.deskHours,
      pickupInstructions: pickupInstructions is String?
          ? pickupInstructions
          : this.pickupInstructions,
      retentionPolicy: retentionPolicy is _ic8ul1lq.RetentionPolicy?
          ? retentionPolicy
          : this.retentionPolicy?.copyWith(),
      policeHandoffThresholdCents:
          policeHandoffThresholdCents ?? this.policeHandoffThresholdCents,
      policeHandoffDays: policeHandoffDays ?? this.policeHandoffDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class VenueUpdateTable extends _is.UpdateTable<VenueTable> {
  VenueUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> slug(String value) => _is.ColumnValue(
    table.slug,
    value,
  );

  _is.ColumnValue<String, String> timezone(String value) => _is.ColumnValue(
    table.timezone,
    value,
  );

  _is.ColumnValue<String, String> deskHours(String? value) => _is.ColumnValue(
    table.deskHours,
    value,
  );

  _is.ColumnValue<String, String> pickupInstructions(String? value) =>
      _is.ColumnValue(
        table.pickupInstructions,
        value,
      );

  _is.ColumnValue<_ic8ul1lq.RetentionPolicy, _ic8ul1lq.RetentionPolicy>
  retentionPolicy(_ic8ul1lq.RetentionPolicy? value) => _is.ColumnValue(
    table.retentionPolicy,
    value,
  );

  _is.ColumnValue<int, int> policeHandoffThresholdCents(int value) =>
      _is.ColumnValue(
        table.policeHandoffThresholdCents,
        value,
      );

  _is.ColumnValue<int, int> policeHandoffDays(int value) => _is.ColumnValue(
    table.policeHandoffDays,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class VenueTable extends _is.Table<_is.UuidValue?> {
  VenueTable({super.tableRelation}) : super(tableName: 'venue') {
    updateTable = VenueUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    slug = _is.ColumnString(
      'slug',
      this,
    );
    timezone = _is.ColumnString(
      'timezone',
      this,
      hasDefault: true,
    );
    deskHours = _is.ColumnString(
      'deskHours',
      this,
    );
    pickupInstructions = _is.ColumnString(
      'pickupInstructions',
      this,
    );
    retentionPolicy = _is.ColumnStructured<_ic8ul1lq.RetentionPolicy>(
      'retentionPolicy',
      this,
    );
    policeHandoffThresholdCents = _is.ColumnInt(
      'policeHandoffThresholdCents',
      this,
      hasDefault: true,
    );
    policeHandoffDays = _is.ColumnInt(
      'policeHandoffDays',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final VenueUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnString slug;

  late final _is.ColumnString timezone;

  late final _is.ColumnString deskHours;

  late final _is.ColumnString pickupInstructions;

  late final _is.ColumnStructured<_ic8ul1lq.RetentionPolicy> retentionPolicy;

  late final _is.ColumnInt policeHandoffThresholdCents;

  late final _is.ColumnInt policeHandoffDays;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    name,
    slug,
    timezone,
    deskHours,
    pickupInstructions,
    retentionPolicy,
    policeHandoffThresholdCents,
    policeHandoffDays,
    createdAt,
  ];
}

class VenueInclude extends _is.IncludeObject {
  VenueInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => Venue.t;
}

class VenueIncludeList extends _is.IncludeList {
  VenueIncludeList._({
    _is.WhereExpressionBuilder<VenueTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Venue.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => Venue.t;
}

class VenueRepository {
  const VenueRepository._();

  /// Returns a list of [Venue]s matching the given query parameters.
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
  Future<List<Venue>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VenueTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Venue>(
      where: where?.call(Venue.t),
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Venue] matching the given query parameters.
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
  Future<Venue?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VenueTable>? where,
    int? offset,
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Venue>(
      where: where?.call(Venue.t),
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Venue] by its [id] or null if no such row exists.
  Future<Venue?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Venue>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Venue]s in the list and returns the inserted rows.
  ///
  /// The returned [Venue]s will have their `id` fields set.
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
  Future<List<Venue>> insert(
    _is.DatabaseSession session,
    List<Venue> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Venue>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Venue] and returns the inserted row.
  ///
  /// The returned [Venue] will have its `id` field set.
  Future<Venue> insertRow(
    _is.DatabaseSession session,
    Venue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Venue>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Venue]s in the list and returns the resulting rows.
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
  /// The returned [Venue]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Venue>> upsert(
    _is.DatabaseSession session,
    List<Venue> rows, {
    required _is.ColumnSelections<VenueTable> conflictColumns,
    _is.ColumnSelections<VenueTable>? updateColumns,
    _is.WhereExpressionBuilder<VenueTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Venue>(
      rows,
      conflictColumns: conflictColumns(Venue.t),
      updateColumns: updateColumns?.call(Venue.t),
      updateWhere: updateWhere?.call(Venue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Venue] and returns the resulting row.
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
  /// The returned [Venue] will have its `id` field set.
  Future<Venue?> upsertRow(
    _is.DatabaseSession session,
    Venue row, {
    required _is.ColumnSelections<VenueTable> conflictColumns,
    _is.ColumnSelections<VenueTable>? updateColumns,
    _is.WhereExpressionBuilder<VenueTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Venue>(
      row,
      conflictColumns: conflictColumns(Venue.t),
      updateColumns: updateColumns?.call(Venue.t),
      updateWhere: updateWhere?.call(Venue.t),
      transaction: transaction,
    );
  }

  /// Updates all [Venue]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Venue>> update(
    _is.DatabaseSession session,
    List<Venue> rows, {
    _is.ColumnSelections<VenueTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Venue>(
      rows,
      columns: columns?.call(Venue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Venue]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Venue> updateRow(
    _is.DatabaseSession session,
    Venue row, {
    _is.ColumnSelections<VenueTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Venue>(
      row,
      columns: columns?.call(Venue.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Venue] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Venue?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<VenueUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Venue>(
      id,
      columnValues: columnValues(Venue.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Venue]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Venue>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<VenueUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<VenueTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Venue>(
      columnValues: columnValues(Venue.t.updateTable),
      where: where(Venue.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Venue]s in the list and returns the deleted rows.
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
  Future<List<Venue>> delete(
    _is.DatabaseSession session,
    List<Venue> rows, {
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Venue>(
      rows,
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Venue].
  Future<Venue> deleteRow(
    _is.DatabaseSession session,
    Venue row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Venue>(
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
  Future<List<Venue>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VenueTable> where,
    _is.OrderByBuilder<VenueTable>? orderBy,
    _is.OrderByListBuilder<VenueTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Venue>(
      where: where(Venue.t),
      orderBy: orderBy?.call(Venue.t),
      orderByList: orderByList?.call(Venue.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<VenueTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Venue>(
      where: where?.call(Venue.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Venue] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<VenueTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Venue>(
      where: where(Venue.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
