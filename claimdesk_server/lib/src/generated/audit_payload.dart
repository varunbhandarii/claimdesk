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

abstract class AuditPayload
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AuditPayload._({
    required this.summary,
    this.fromState,
    this.toState,
    required this.data,
  });

  factory AuditPayload({
    required String summary,
    String? fromState,
    String? toState,
    required Map<String, String> data,
  }) = _AuditPayloadImpl;

  factory AuditPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditPayload(
      summary: jsonSerialization['summary'] as String,
      fromState: jsonSerialization['fromState'] as String?,
      toState: jsonSerialization['toState'] as String?,
      data: _ii1g677k.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['data'],
      ),
    );
  }

  String summary;

  String? fromState;

  String? toState;

  Map<String, String> data;

  /// Returns a shallow copy of this [AuditPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AuditPayload copyWith({
    String? summary,
    String? fromState,
    String? toState,
    Map<String, String>? data,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditPayload',
      'summary': summary,
      if (fromState != null) 'fromState': fromState,
      if (toState != null) 'toState': toState,
      'data': data.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditPayload',
      'summary': summary,
      if (fromState != null) 'fromState': fromState,
      if (toState != null) 'toState': toState,
      'data': data.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditPayloadImpl extends AuditPayload {
  _AuditPayloadImpl({
    required String summary,
    String? fromState,
    String? toState,
    required Map<String, String> data,
  }) : super._(
         summary: summary,
         fromState: fromState,
         toState: toState,
         data: data,
       );

  /// Returns a shallow copy of this [AuditPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AuditPayload copyWith({
    String? summary,
    Object? fromState = _Undefined,
    Object? toState = _Undefined,
    Map<String, String>? data,
  }) {
    return AuditPayload(
      summary: summary ?? this.summary,
      fromState: fromState is String? ? fromState : this.fromState,
      toState: toState is String? ? toState : this.toState,
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
