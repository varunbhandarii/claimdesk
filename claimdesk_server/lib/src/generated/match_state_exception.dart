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

abstract class MatchStateException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  MatchStateException._({
    required this.message,
    required this.matchId,
  });

  factory MatchStateException({
    required String message,
    required _is.UuidValue matchId,
  }) = _MatchStateExceptionImpl;

  factory MatchStateException.fromJson(Map<String, dynamic> jsonSerialization) {
    return MatchStateException(
      message: jsonSerialization['message'] as String,
      matchId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['matchId'],
      ),
    );
  }

  String message;

  _is.UuidValue matchId;

  /// Returns a shallow copy of this [MatchStateException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MatchStateException copyWith({
    String? message,
    _is.UuidValue? matchId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MatchStateException',
      'message': message,
      'matchId': matchId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MatchStateException',
      'message': message,
      'matchId': matchId.toJson(),
    };
  }

  @override
  String toString() {
    return 'MatchStateException(message: $message, matchId: $matchId)';
  }
}

class _MatchStateExceptionImpl extends MatchStateException {
  _MatchStateExceptionImpl({
    required String message,
    required _is.UuidValue matchId,
  }) : super._(
         message: message,
         matchId: matchId,
       );

  /// Returns a shallow copy of this [MatchStateException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MatchStateException copyWith({
    String? message,
    _is.UuidValue? matchId,
  }) {
    return MatchStateException(
      message: message ?? this.message,
      matchId: matchId ?? this.matchId,
    );
  }
}
