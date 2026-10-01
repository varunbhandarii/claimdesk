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

abstract class ReleaseInput
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ReleaseInput._({
    this.matchId,
    required this.claimantName,
    required this.idTypeSeen,
    required this.detailsMatched,
    required this.describedBeforeViewing,
    required this.thirdParty,
    this.thirdPartyAuthorisationNote,
  });

  factory ReleaseInput({
    _is.UuidValue? matchId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    required bool thirdParty,
    String? thirdPartyAuthorisationNote,
  }) = _ReleaseInputImpl;

  factory ReleaseInput.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReleaseInput(
      matchId: jsonSerialization['matchId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['matchId']),
      claimantName: jsonSerialization['claimantName'] as String,
      idTypeSeen: jsonSerialization['idTypeSeen'] as String,
      detailsMatched: jsonSerialization['detailsMatched'] as int,
      describedBeforeViewing: _is.BoolJsonExtension.fromJson(
        jsonSerialization['describedBeforeViewing'],
      ),
      thirdParty: _is.BoolJsonExtension.fromJson(
        jsonSerialization['thirdParty'],
      ),
      thirdPartyAuthorisationNote:
          jsonSerialization['thirdPartyAuthorisationNote'] as String?,
    );
  }

  _is.UuidValue? matchId;

  String claimantName;

  String idTypeSeen;

  int detailsMatched;

  bool describedBeforeViewing;

  bool thirdParty;

  String? thirdPartyAuthorisationNote;

  /// Returns a shallow copy of this [ReleaseInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ReleaseInput copyWith({
    _is.UuidValue? matchId,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    bool? thirdParty,
    String? thirdPartyAuthorisationNote,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReleaseInput',
      if (matchId != null) 'matchId': matchId?.toJson(),
      'claimantName': claimantName,
      'idTypeSeen': idTypeSeen,
      'detailsMatched': detailsMatched,
      'describedBeforeViewing': describedBeforeViewing,
      'thirdParty': thirdParty,
      if (thirdPartyAuthorisationNote != null)
        'thirdPartyAuthorisationNote': thirdPartyAuthorisationNote,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReleaseInput',
      if (matchId != null) 'matchId': matchId?.toJson(),
      'claimantName': claimantName,
      'idTypeSeen': idTypeSeen,
      'detailsMatched': detailsMatched,
      'describedBeforeViewing': describedBeforeViewing,
      'thirdParty': thirdParty,
      if (thirdPartyAuthorisationNote != null)
        'thirdPartyAuthorisationNote': thirdPartyAuthorisationNote,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReleaseInputImpl extends ReleaseInput {
  _ReleaseInputImpl({
    _is.UuidValue? matchId,
    required String claimantName,
    required String idTypeSeen,
    required int detailsMatched,
    required bool describedBeforeViewing,
    required bool thirdParty,
    String? thirdPartyAuthorisationNote,
  }) : super._(
         matchId: matchId,
         claimantName: claimantName,
         idTypeSeen: idTypeSeen,
         detailsMatched: detailsMatched,
         describedBeforeViewing: describedBeforeViewing,
         thirdParty: thirdParty,
         thirdPartyAuthorisationNote: thirdPartyAuthorisationNote,
       );

  /// Returns a shallow copy of this [ReleaseInput]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ReleaseInput copyWith({
    Object? matchId = _Undefined,
    String? claimantName,
    String? idTypeSeen,
    int? detailsMatched,
    bool? describedBeforeViewing,
    bool? thirdParty,
    Object? thirdPartyAuthorisationNote = _Undefined,
  }) {
    return ReleaseInput(
      matchId: matchId is _is.UuidValue? ? matchId : this.matchId,
      claimantName: claimantName ?? this.claimantName,
      idTypeSeen: idTypeSeen ?? this.idTypeSeen,
      detailsMatched: detailsMatched ?? this.detailsMatched,
      describedBeforeViewing:
          describedBeforeViewing ?? this.describedBeforeViewing,
      thirdParty: thirdParty ?? this.thirdParty,
      thirdPartyAuthorisationNote: thirdPartyAuthorisationNote is String?
          ? thirdPartyAuthorisationNote
          : this.thirdPartyAuthorisationNote,
    );
  }
}
