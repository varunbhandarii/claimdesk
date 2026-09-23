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

enum ValueBand implements _is.SerializableModel {
  under20,
  from20to99,
  from100to499,
  from500to4999,
  over5000;

  static ValueBand fromJson(String name) {
    switch (name) {
      case 'under20':
        return ValueBand.under20;
      case 'from20to99':
        return ValueBand.from20to99;
      case 'from100to499':
        return ValueBand.from100to499;
      case 'from500to4999':
        return ValueBand.from500to4999;
      case 'over5000':
        return ValueBand.over5000;
      default:
        return ValueBand.under20;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
