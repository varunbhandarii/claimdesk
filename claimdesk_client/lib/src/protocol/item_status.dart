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

enum ItemStatus implements _isc.SerializableModel {
  intake,
  captioning,
  unclaimed,
  matched,
  claimed,
  transferred,
  disposed,
  expired;

  static ItemStatus fromJson(String name) {
    switch (name) {
      case 'intake':
        return ItemStatus.intake;
      case 'captioning':
        return ItemStatus.captioning;
      case 'unclaimed':
        return ItemStatus.unclaimed;
      case 'matched':
        return ItemStatus.matched;
      case 'claimed':
        return ItemStatus.claimed;
      case 'transferred':
        return ItemStatus.transferred;
      case 'disposed':
        return ItemStatus.disposed;
      case 'expired':
        return ItemStatus.expired;
      default:
        return ItemStatus.intake;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
