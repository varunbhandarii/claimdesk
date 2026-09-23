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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class CustodyEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    required String fromLocation,
    required String toLocation,
    String? reference,
    required _isc.UuidValue byAuthUserId,
    DateTime? at,
  }) = _CustodyEventImpl;

  factory CustodyEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustodyEvent(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      fromLocation: jsonSerialization['fromLocation'] as String,
      toLocation: jsonSerialization['toLocation'] as String,
      reference: jsonSerialization['reference'] as String?,
      byAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['byAuthUserId'],
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

  _isc.UuidValue itemId;

  String fromLocation;

  String toLocation;

  String? reference;

  _isc.UuidValue byAuthUserId;

  DateTime at;

  /// Returns a shallow copy of this [CustodyEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustodyEvent copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    String? fromLocation,
    String? toLocation,
    String? reference,
    _isc.UuidValue? byAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustodyEventImpl extends CustodyEvent {
  _CustodyEventImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    required String fromLocation,
    required String toLocation,
    String? reference,
    required _isc.UuidValue byAuthUserId,
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
  @_isc.useResult
  @override
  CustodyEvent copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    String? fromLocation,
    String? toLocation,
    Object? reference = _Undefined,
    _isc.UuidValue? byAuthUserId,
    DateTime? at,
  }) {
    return CustodyEvent(
      id: id is _isc.UuidValue? ? id : this.id,
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
