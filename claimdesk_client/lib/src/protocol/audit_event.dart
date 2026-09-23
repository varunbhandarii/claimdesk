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
import 'audit_payload.dart' as _imod1ub6;

abstract class AuditEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required String entityType,
    required _isc.UuidValue entityId,
    required String action,
    _isc.UuidValue? actorAuthUserId,
    _imod1ub6.AuditPayload? payload,
    DateTime? at,
  }) = _AuditEventImpl;

  factory AuditEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      entityType: jsonSerialization['entityType'] as String,
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      action: jsonSerialization['action'] as String,
      actorAuthUserId: jsonSerialization['actorAuthUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['actorAuthUserId'],
            ),
      payload: jsonSerialization['payload'] == null
          ? null
          : _i3upg8fq.Protocol().deserialize<_imod1ub6.AuditPayload>(
              jsonSerialization['payload'],
            ),
      at: jsonSerialization['at'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue venueId;

  String entityType;

  _isc.UuidValue entityId;

  String action;

  _isc.UuidValue? actorAuthUserId;

  _imod1ub6.AuditPayload? payload;

  DateTime at;

  /// Returns a shallow copy of this [AuditEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuditEvent copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    String? entityType,
    _isc.UuidValue? entityId,
    String? action,
    _isc.UuidValue? actorAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEventImpl extends AuditEvent {
  _AuditEventImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required String entityType,
    required _isc.UuidValue entityId,
    required String action,
    _isc.UuidValue? actorAuthUserId,
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
  @_isc.useResult
  @override
  AuditEvent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    String? entityType,
    _isc.UuidValue? entityId,
    String? action,
    Object? actorAuthUserId = _Undefined,
    Object? payload = _Undefined,
    DateTime? at,
  }) {
    return AuditEvent(
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      actorAuthUserId: actorAuthUserId is _isc.UuidValue?
          ? actorAuthUserId
          : this.actorAuthUserId,
      payload: payload is _imod1ub6.AuditPayload?
          ? payload
          : this.payload?.copyWith(),
      at: at ?? this.at,
    );
  }
}
