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

abstract class DeskEvent
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DeskEvent._({
    required this.kind,
    required this.venueId,
    this.itemId,
    this.reportId,
    this.matchId,
    required this.at,
  });

  factory DeskEvent({
    required String kind,
    required _is.UuidValue venueId,
    _is.UuidValue? itemId,
    _is.UuidValue? reportId,
    _is.UuidValue? matchId,
    required DateTime at,
  }) = _DeskEventImpl;

  factory DeskEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeskEvent(
      kind: jsonSerialization['kind'] as String,
      venueId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: jsonSerialization['itemId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      reportId: jsonSerialization['reportId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['reportId']),
      matchId: jsonSerialization['matchId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['matchId']),
      at: _is.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
    );
  }

  String kind;

  _is.UuidValue venueId;

  _is.UuidValue? itemId;

  _is.UuidValue? reportId;

  _is.UuidValue? matchId;

  DateTime at;

  /// Returns a shallow copy of this [DeskEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeskEvent copyWith({
    String? kind,
    _is.UuidValue? venueId,
    _is.UuidValue? itemId,
    _is.UuidValue? reportId,
    _is.UuidValue? matchId,
    DateTime? at,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeskEvent',
      'kind': kind,
      'venueId': venueId.toJson(),
      if (itemId != null) 'itemId': itemId?.toJson(),
      if (reportId != null) 'reportId': reportId?.toJson(),
      if (matchId != null) 'matchId': matchId?.toJson(),
      'at': at.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeskEvent',
      'kind': kind,
      'venueId': venueId.toJson(),
      if (itemId != null) 'itemId': itemId?.toJson(),
      if (reportId != null) 'reportId': reportId?.toJson(),
      if (matchId != null) 'matchId': matchId?.toJson(),
      'at': at.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeskEventImpl extends DeskEvent {
  _DeskEventImpl({
    required String kind,
    required _is.UuidValue venueId,
    _is.UuidValue? itemId,
    _is.UuidValue? reportId,
    _is.UuidValue? matchId,
    required DateTime at,
  }) : super._(
         kind: kind,
         venueId: venueId,
         itemId: itemId,
         reportId: reportId,
         matchId: matchId,
         at: at,
       );

  /// Returns a shallow copy of this [DeskEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeskEvent copyWith({
    String? kind,
    _is.UuidValue? venueId,
    Object? itemId = _Undefined,
    Object? reportId = _Undefined,
    Object? matchId = _Undefined,
    DateTime? at,
  }) {
    return DeskEvent(
      kind: kind ?? this.kind,
      venueId: venueId ?? this.venueId,
      itemId: itemId is _is.UuidValue? ? itemId : this.itemId,
      reportId: reportId is _is.UuidValue? ? reportId : this.reportId,
      matchId: matchId is _is.UuidValue? ? matchId : this.matchId,
      at: at ?? this.at,
    );
  }
}
