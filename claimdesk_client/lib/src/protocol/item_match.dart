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
import 'match_explanation.dart' as _i7ltg7v2;
import 'match_state.dart' as _idznkk1k;

abstract class ItemMatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue reportId,
    required _isc.UuidValue itemId,
    _idznkk1k.MatchState? state,
    required double score,
    required String label,
    required int rank,
    required _i7ltg7v2.MatchExplanation explanation,
    required String algorithmVersion,
    _isc.UuidValue? decidedByAuthUserId,
    DateTime? decidedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ItemMatchImpl;

  factory ItemMatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemMatch(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      venueId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['venueId'],
      ),
      reportId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['reportId'],
      ),
      itemId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['itemId']),
      state: jsonSerialization['state'] == null
          ? null
          : _idznkk1k.MatchState.fromJson(
              (jsonSerialization['state'] as String),
            ),
      score: (jsonSerialization['score'] as num).toDouble(),
      label: jsonSerialization['label'] as String,
      rank: jsonSerialization['rank'] as int,
      explanation: _i3upg8fq.Protocol().deserialize<_i7ltg7v2.MatchExplanation>(
        jsonSerialization['explanation'],
      ),
      algorithmVersion: jsonSerialization['algorithmVersion'] as String,
      decidedByAuthUserId: jsonSerialization['decidedByAuthUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['decidedByAuthUserId'],
            ),
      decidedAt: jsonSerialization['decidedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['decidedAt']),
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

  _isc.UuidValue venueId;

  _isc.UuidValue reportId;

  _isc.UuidValue itemId;

  _idznkk1k.MatchState state;

  double score;

  String label;

  int rank;

  _i7ltg7v2.MatchExplanation explanation;

  String algorithmVersion;

  _isc.UuidValue? decidedByAuthUserId;

  DateTime? decidedAt;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [ItemMatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ItemMatch copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? venueId,
    _isc.UuidValue? reportId,
    _isc.UuidValue? itemId,
    _idznkk1k.MatchState? state,
    double? score,
    String? label,
    int? rank,
    _i7ltg7v2.MatchExplanation? explanation,
    String? algorithmVersion,
    _isc.UuidValue? decidedByAuthUserId,
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

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemMatchImpl extends ItemMatch {
  _ItemMatchImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue venueId,
    required _isc.UuidValue reportId,
    required _isc.UuidValue itemId,
    _idznkk1k.MatchState? state,
    required double score,
    required String label,
    required int rank,
    required _i7ltg7v2.MatchExplanation explanation,
    required String algorithmVersion,
    _isc.UuidValue? decidedByAuthUserId,
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
  @_isc.useResult
  @override
  ItemMatch copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? venueId,
    _isc.UuidValue? reportId,
    _isc.UuidValue? itemId,
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
      id: id is _isc.UuidValue? ? id : this.id,
      venueId: venueId ?? this.venueId,
      reportId: reportId ?? this.reportId,
      itemId: itemId ?? this.itemId,
      state: state ?? this.state,
      score: score ?? this.score,
      label: label ?? this.label,
      rank: rank ?? this.rank,
      explanation: explanation ?? this.explanation.copyWith(),
      algorithmVersion: algorithmVersion ?? this.algorithmVersion,
      decidedByAuthUserId: decidedByAuthUserId is _isc.UuidValue?
          ? decidedByAuthUserId
          : this.decidedByAuthUserId,
      decidedAt: decidedAt is DateTime? ? decidedAt : this.decidedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
