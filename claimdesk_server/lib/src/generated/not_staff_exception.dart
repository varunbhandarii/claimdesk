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

/// Thrown when someone signs in with an outside account that does not belong
/// to a member of any desk team.
abstract class NotStaffException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  NotStaffException._({required this.message});

  factory NotStaffException({required String message}) = _NotStaffExceptionImpl;

  factory NotStaffException.fromJson(Map<String, dynamic> jsonSerialization) {
    return NotStaffException(message: jsonSerialization['message'] as String);
  }

  String message;

  /// Returns a shallow copy of this [NotStaffException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  NotStaffException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'NotStaffException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'NotStaffException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'NotStaffException(message: $message)';
  }
}

class _NotStaffExceptionImpl extends NotStaffException {
  _NotStaffExceptionImpl({required String message}) : super._(message: message);

  /// Returns a shallow copy of this [NotStaffException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  NotStaffException copyWith({String? message}) {
    return NotStaffException(message: message ?? this.message);
  }
}
