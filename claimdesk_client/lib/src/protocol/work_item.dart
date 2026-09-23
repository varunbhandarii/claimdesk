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
import 'package:claimdesk_client/src/protocol/protocol.dart' as _i3upg8fq;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'work_payload.dart' as _ib3jfnwt;
import 'work_state.dart' as _i6iais05;

abstract class WorkItem
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
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
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: jsonSerialization['venueId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['venueId']),
      kind: jsonSerialization['kind'] as String,
      payload: _i3upg8fq.Protocol().deserialize<_ib3jfnwt.WorkPayload>(
        jsonSerialization['payload'],
      ),
      identifier: jsonSerialization['identifier'] as String?,
      runAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['runAt']),
      state: jsonSerialization['state'] == null
          ? null
          : _i6iais05.WorkState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      leaseUntil: jsonSerialization['leaseUntil'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['leaseUntil'],
            ),
      attempts: jsonSerialization['attempts'] as int?,
      maxAttempts: jsonSerialization['maxAttempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      completedAt: jsonSerialization['completedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['completedAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue? venueId;

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

  /// Returns a shallow copy of this [WorkItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkItemImpl extends WorkItem {
  _WorkItemImpl({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
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
  @_isc.useResult
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
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId is _isc.UuidValue? ? venueId : this.venueId,
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
