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

abstract class Zone
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Zone._({
    this.id,
    required this.venueId,
    required this.name,
    int? sortOrder,
    required this.adjacentZoneIds,
  }) : sortOrder = sortOrder ?? 0;

  factory Zone({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required String name,
    int? sortOrder,
    required List<_isc.UuidValue> adjacentZoneIds,
  }) = _ZoneImpl;

  factory Zone.fromJson(Map<String, dynamic> jsonSerialization) {
    return Zone(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      adjacentZoneIds: _i3upg8fq.Protocol().deserialize<List<_isc.UuidValue>>(
        jsonSerialization['adjacentZoneIds'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue venueId;

  String name;

  int sortOrder;

  List<_isc.UuidValue> adjacentZoneIds;

  /// Returns a shallow copy of this [Zone]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Zone copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    String? name,
    int? sortOrder,
    List<_isc.UuidValue>? adjacentZoneIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Zone',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'adjacentZoneIds': adjacentZoneIds.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Zone',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'adjacentZoneIds': adjacentZoneIds.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ZoneImpl extends Zone {
  _ZoneImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required String name,
    int? sortOrder,
    required List<_isc.UuidValue> adjacentZoneIds,
  }) : super._(
         id: id,
         venueId: venueId,
         name: name,
         sortOrder: sortOrder,
         adjacentZoneIds: adjacentZoneIds,
       );

  /// Returns a shallow copy of this [Zone]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Zone copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    String? name,
    int? sortOrder,
    List<_isc.UuidValue>? adjacentZoneIds,
  }) {
    return Zone(
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      adjacentZoneIds:
          adjacentZoneIds ?? this.adjacentZoneIds.map((e0) => e0).toList(),
    );
  }
}
