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

enum WorkState implements _isc.SerializableModel {
  pending,
  running,
  done,
  failed,
  cancelled;

  static WorkState fromJson(String name) {
    switch (name) {
      case 'pending':
        return WorkState.pending;
      case 'running':
        return WorkState.running;
      case 'done':
        return WorkState.done;
      case 'failed':
        return WorkState.failed;
      case 'cancelled':
        return WorkState.cancelled;
      default:
        return WorkState.pending;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
