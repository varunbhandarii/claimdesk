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
import 'found_item.dart' as _i52cv103;
import 'item_match.dart' as _i989z6nt;
import 'lost_report.dart' as _iyhihx8i;

abstract class MatchCard
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MatchCard._({
    required this.match,
    required this.item,
    required this.report,
    required this.clearLeader,
  });

  factory MatchCard({
    required _i989z6nt.ItemMatch match,
    required _i52cv103.FoundItem item,
    required _iyhihx8i.LostReport report,
    required bool clearLeader,
  }) = _MatchCardImpl;

  factory MatchCard.fromJson(Map<String, dynamic> jsonSerialization) {
    return MatchCard(
      match: _i3upg8fq.Protocol().deserialize<_i989z6nt.ItemMatch>(
        jsonSerialization['match'],
      ),
      item: _i3upg8fq.Protocol().deserialize<_i52cv103.FoundItem>(
        jsonSerialization['item'],
      ),
      report: _i3upg8fq.Protocol().deserialize<_iyhihx8i.LostReport>(
        jsonSerialization['report'],
      ),
      clearLeader: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['clearLeader'],
      ),
    );
  }

  _i989z6nt.ItemMatch match;

  _i52cv103.FoundItem item;

  _iyhihx8i.LostReport report;

  bool clearLeader;

  /// Returns a shallow copy of this [MatchCard]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MatchCard copyWith({
    _i989z6nt.ItemMatch? match,
    _i52cv103.FoundItem? item,
    _iyhihx8i.LostReport? report,
    bool? clearLeader,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MatchCard',
      'match': match.toJson(),
      'item': item.toJson(),
      'report': report.toJson(),
      'clearLeader': clearLeader,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MatchCard',
      'match': match.toJsonForProtocol(),
      'item': item.toJsonForProtocol(),
      'report': report.toJsonForProtocol(),
      'clearLeader': clearLeader,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MatchCardImpl extends MatchCard {
  _MatchCardImpl({
    required _i989z6nt.ItemMatch match,
    required _i52cv103.FoundItem item,
    required _iyhihx8i.LostReport report,
    required bool clearLeader,
  }) : super._(
         match: match,
         item: item,
         report: report,
         clearLeader: clearLeader,
       );

  /// Returns a shallow copy of this [MatchCard]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MatchCard copyWith({
    _i989z6nt.ItemMatch? match,
    _i52cv103.FoundItem? item,
    _iyhihx8i.LostReport? report,
    bool? clearLeader,
  }) {
    return MatchCard(
      match: match ?? this.match.copyWith(),
      item: item ?? this.item.copyWith(),
      report: report ?? this.report.copyWith(),
      clearLeader: clearLeader ?? this.clearLeader,
    );
  }
}
