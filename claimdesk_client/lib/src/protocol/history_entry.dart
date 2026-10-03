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

abstract class HistoryEntry
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  HistoryEntry._({
    required this.at,
    required this.kind,
    required this.action,
    required this.summary,
    this.fromState,
    this.toState,
    required this.actor,
    this.counterpart,
    required this.data,
  });

  factory HistoryEntry({
    required DateTime at,
    required String kind,
    required String action,
    required String summary,
    String? fromState,
    String? toState,
    required String actor,
    String? counterpart,
    required Map<String, String> data,
  }) = _HistoryEntryImpl;

  factory HistoryEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return HistoryEntry(
      at: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      kind: jsonSerialization['kind'] as String,
      action: jsonSerialization['action'] as String,
      summary: jsonSerialization['summary'] as String,
      fromState: jsonSerialization['fromState'] as String?,
      toState: jsonSerialization['toState'] as String?,
      actor: jsonSerialization['actor'] as String,
      counterpart: jsonSerialization['counterpart'] as String?,
      data: _i3upg8fq.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['data'],
      ),
    );
  }

  DateTime at;

  String kind;

  String action;

  String summary;

  String? fromState;

  String? toState;

  String actor;

  String? counterpart;

  Map<String, String> data;

  /// Returns a shallow copy of this [HistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  HistoryEntry copyWith({
    DateTime? at,
    String? kind,
    String? action,
    String? summary,
    String? fromState,
    String? toState,
    String? actor,
    String? counterpart,
    Map<String, String>? data,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HistoryEntry',
      'at': at.toJson(),
      'kind': kind,
      'action': action,
      'summary': summary,
      if (fromState != null) 'fromState': fromState,
      if (toState != null) 'toState': toState,
      'actor': actor,
      if (counterpart != null) 'counterpart': counterpart,
      'data': data.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HistoryEntry',
      'at': at.toJson(),
      'kind': kind,
      'action': action,
      'summary': summary,
      if (fromState != null) 'fromState': fromState,
      if (toState != null) 'toState': toState,
      'actor': actor,
      if (counterpart != null) 'counterpart': counterpart,
      'data': data.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HistoryEntryImpl extends HistoryEntry {
  _HistoryEntryImpl({
    required DateTime at,
    required String kind,
    required String action,
    required String summary,
    String? fromState,
    String? toState,
    required String actor,
    String? counterpart,
    required Map<String, String> data,
  }) : super._(
         at: at,
         kind: kind,
         action: action,
         summary: summary,
         fromState: fromState,
         toState: toState,
         actor: actor,
         counterpart: counterpart,
         data: data,
       );

  /// Returns a shallow copy of this [HistoryEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  HistoryEntry copyWith({
    DateTime? at,
    String? kind,
    String? action,
    String? summary,
    Object? fromState = _Undefined,
    Object? toState = _Undefined,
    String? actor,
    Object? counterpart = _Undefined,
    Map<String, String>? data,
  }) {
    return HistoryEntry(
      at: at ?? this.at,
      kind: kind ?? this.kind,
      action: action ?? this.action,
      summary: summary ?? this.summary,
      fromState: fromState is String? ? fromState : this.fromState,
      toState: toState is String? ? toState : this.toState,
      actor: actor ?? this.actor,
      counterpart: counterpart is String? ? counterpart : this.counterpart,
      data:
          data ??
          this.data.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
    );
  }
}
