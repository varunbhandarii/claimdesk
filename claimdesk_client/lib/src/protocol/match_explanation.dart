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

abstract class MatchExplanation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MatchExplanation._({
    this.cosSim,
    this.keywordCoverage,
    required this.matchedKeywords,
    this.category,
    this.colour,
    this.brand,
    this.zone,
    this.time,
    required this.weightsHash,
    bool? guardrailApplied,
  }) : guardrailApplied = guardrailApplied ?? false;

  factory MatchExplanation({
    double? cosSim,
    double? keywordCoverage,
    required List<String> matchedKeywords,
    double? category,
    double? colour,
    double? brand,
    double? zone,
    double? time,
    required String weightsHash,
    bool? guardrailApplied,
  }) = _MatchExplanationImpl;

  factory MatchExplanation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MatchExplanation(
      cosSim: (jsonSerialization['cosSim'] as num?)?.toDouble(),
      keywordCoverage: (jsonSerialization['keywordCoverage'] as num?)
          ?.toDouble(),
      matchedKeywords: _i3upg8fq.Protocol().deserialize<List<String>>(
        jsonSerialization['matchedKeywords'],
      ),
      category: (jsonSerialization['category'] as num?)?.toDouble(),
      colour: (jsonSerialization['colour'] as num?)?.toDouble(),
      brand: (jsonSerialization['brand'] as num?)?.toDouble(),
      zone: (jsonSerialization['zone'] as num?)?.toDouble(),
      time: (jsonSerialization['time'] as num?)?.toDouble(),
      weightsHash: jsonSerialization['weightsHash'] as String,
      guardrailApplied: jsonSerialization['guardrailApplied'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['guardrailApplied'],
            ),
    );
  }

  double? cosSim;

  double? keywordCoverage;

  List<String> matchedKeywords;

  double? category;

  double? colour;

  double? brand;

  double? zone;

  double? time;

  String weightsHash;

  bool guardrailApplied;

  /// Returns a shallow copy of this [MatchExplanation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MatchExplanation copyWith({
    double? cosSim,
    double? keywordCoverage,
    List<String>? matchedKeywords,
    double? category,
    double? colour,
    double? brand,
    double? zone,
    double? time,
    String? weightsHash,
    bool? guardrailApplied,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MatchExplanation',
      if (cosSim != null) 'cosSim': cosSim,
      if (keywordCoverage != null) 'keywordCoverage': keywordCoverage,
      'matchedKeywords': matchedKeywords.toJson(),
      if (category != null) 'category': category,
      if (colour != null) 'colour': colour,
      if (brand != null) 'brand': brand,
      if (zone != null) 'zone': zone,
      if (time != null) 'time': time,
      'weightsHash': weightsHash,
      'guardrailApplied': guardrailApplied,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MatchExplanation',
      if (cosSim != null) 'cosSim': cosSim,
      if (keywordCoverage != null) 'keywordCoverage': keywordCoverage,
      'matchedKeywords': matchedKeywords.toJson(),
      if (category != null) 'category': category,
      if (colour != null) 'colour': colour,
      if (brand != null) 'brand': brand,
      if (zone != null) 'zone': zone,
      if (time != null) 'time': time,
      'weightsHash': weightsHash,
      'guardrailApplied': guardrailApplied,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MatchExplanationImpl extends MatchExplanation {
  _MatchExplanationImpl({
    double? cosSim,
    double? keywordCoverage,
    required List<String> matchedKeywords,
    double? category,
    double? colour,
    double? brand,
    double? zone,
    double? time,
    required String weightsHash,
    bool? guardrailApplied,
  }) : super._(
         cosSim: cosSim,
         keywordCoverage: keywordCoverage,
         matchedKeywords: matchedKeywords,
         category: category,
         colour: colour,
         brand: brand,
         zone: zone,
         time: time,
         weightsHash: weightsHash,
         guardrailApplied: guardrailApplied,
       );

  /// Returns a shallow copy of this [MatchExplanation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MatchExplanation copyWith({
    Object? cosSim = _Undefined,
    Object? keywordCoverage = _Undefined,
    List<String>? matchedKeywords,
    Object? category = _Undefined,
    Object? colour = _Undefined,
    Object? brand = _Undefined,
    Object? zone = _Undefined,
    Object? time = _Undefined,
    String? weightsHash,
    bool? guardrailApplied,
  }) {
    return MatchExplanation(
      cosSim: cosSim is double? ? cosSim : this.cosSim,
      keywordCoverage: keywordCoverage is double?
          ? keywordCoverage
          : this.keywordCoverage,
      matchedKeywords:
          matchedKeywords ?? this.matchedKeywords.map((e0) => e0).toList(),
      category: category is double? ? category : this.category,
      colour: colour is double? ? colour : this.colour,
      brand: brand is double? ? brand : this.brand,
      zone: zone is double? ? zone : this.zone,
      time: time is double? ? time : this.time,
      weightsHash: weightsHash ?? this.weightsHash,
      guardrailApplied: guardrailApplied ?? this.guardrailApplied,
    );
  }
}
