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

abstract class CaptionRun
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CaptionRun._({
    this.id,
    required this.venueId,
    required this.itemId,
    required this.provider,
    required this.modelId,
    required this.promptVersion,
    required this.outcome,
    required this.latencyMs,
    this.inputTokens,
    this.outputTokens,
    this.errorMessage,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CaptionRun({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    required String provider,
    required String modelId,
    required String promptVersion,
    required String outcome,
    required int latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  }) = _CaptionRunImpl;

  factory CaptionRun.fromJson(Map<String, dynamic> jsonSerialization) {
    return CaptionRun(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      itemId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      provider: jsonSerialization['provider'] as String,
      modelId: jsonSerialization['modelId'] as String,
      promptVersion: jsonSerialization['promptVersion'] as String,
      outcome: jsonSerialization['outcome'] as String,
      latencyMs: jsonSerialization['latencyMs'] as int,
      inputTokens: jsonSerialization['inputTokens'] as int?,
      outputTokens: jsonSerialization['outputTokens'] as int?,
      errorMessage: jsonSerialization['errorMessage'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue venueId;

  _isc.UuidValue itemId;

  String provider;

  String modelId;

  String promptVersion;

  String outcome;

  int latencyMs;

  int? inputTokens;

  int? outputTokens;

  String? errorMessage;

  DateTime createdAt;

  /// Returns a shallow copy of this [CaptionRun]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CaptionRun copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    String? provider,
    String? modelId,
    String? promptVersion,
    String? outcome,
    int? latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CaptionRun',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'provider': provider,
      'modelId': modelId,
      'promptVersion': promptVersion,
      'outcome': outcome,
      'latencyMs': latencyMs,
      if (inputTokens != null) 'inputTokens': inputTokens,
      if (outputTokens != null) 'outputTokens': outputTokens,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CaptionRun',
      if (id != null) 'id': id?.toJson(),
      'venueId': venueId.toJson(),
      'itemId': itemId.toJson(),
      'provider': provider,
      'modelId': modelId,
      'promptVersion': promptVersion,
      'outcome': outcome,
      'latencyMs': latencyMs,
      if (inputTokens != null) 'inputTokens': inputTokens,
      if (outputTokens != null) 'outputTokens': outputTokens,
      if (errorMessage != null) 'errorMessage': errorMessage,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CaptionRunImpl extends CaptionRun {
  _CaptionRunImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue itemId,
    required String provider,
    required String modelId,
    required String promptVersion,
    required String outcome,
    required int latencyMs,
    int? inputTokens,
    int? outputTokens,
    String? errorMessage,
    DateTime? createdAt,
  }) : super._(
         id: id,
         venueId: venueId,
         itemId: itemId,
         provider: provider,
         modelId: modelId,
         promptVersion: promptVersion,
         outcome: outcome,
         latencyMs: latencyMs,
         inputTokens: inputTokens,
         outputTokens: outputTokens,
         errorMessage: errorMessage,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CaptionRun]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CaptionRun copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    _isc.UuidValue? itemId,
    String? provider,
    String? modelId,
    String? promptVersion,
    String? outcome,
    int? latencyMs,
    Object? inputTokens = _Undefined,
    Object? outputTokens = _Undefined,
    Object? errorMessage = _Undefined,
    DateTime? createdAt,
  }) {
    return CaptionRun(
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      itemId: itemId ?? this.itemId,
      provider: provider ?? this.provider,
      modelId: modelId ?? this.modelId,
      promptVersion: promptVersion ?? this.promptVersion,
      outcome: outcome ?? this.outcome,
      latencyMs: latencyMs ?? this.latencyMs,
      inputTokens: inputTokens is int? ? inputTokens : this.inputTokens,
      outputTokens: outputTokens is int? ? outputTokens : this.outputTokens,
      errorMessage: errorMessage is String? ? errorMessage : this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
