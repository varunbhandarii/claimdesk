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
import 'item_status.dart' as _ibbyonnn;

abstract class ItemFilter
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ItemFilter._({
    this.status,
    this.zoneId,
    this.category,
  });

  factory ItemFilter({
    _ibbyonnn.ItemStatus? status,
    _is.UuidValue? zoneId,
    String? category,
  }) = _ItemFilterImpl;

  factory ItemFilter.fromJson(Map<String, dynamic> jsonSerialization) {
    return ItemFilter(
      status: jsonSerialization['status'] == null
          ? null
          : _ibbyonnn.ItemStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      category: jsonSerialization['category'] as String?,
    );
  }

  _ibbyonnn.ItemStatus? status;

  _is.UuidValue? zoneId;

  String? category;

  /// Returns a shallow copy of this [ItemFilter]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ItemFilter copyWith({
    _ibbyonnn.ItemStatus? status,
    _is.UuidValue? zoneId,
    String? category,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ItemFilter',
      if (status != null) 'status': status?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (category != null) 'category': category,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ItemFilter',
      if (status != null) 'status': status?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (category != null) 'category': category,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ItemFilterImpl extends ItemFilter {
  _ItemFilterImpl({
    _ibbyonnn.ItemStatus? status,
    _is.UuidValue? zoneId,
    String? category,
  }) : super._(
         status: status,
         zoneId: zoneId,
         category: category,
       );

  /// Returns a shallow copy of this [ItemFilter]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ItemFilter copyWith({
    Object? status = _Undefined,
    Object? zoneId = _Undefined,
    Object? category = _Undefined,
  }) {
    return ItemFilter(
      status: status is _ibbyonnn.ItemStatus? ? status : this.status,
      zoneId: zoneId is _is.UuidValue? ? zoneId : this.zoneId,
      category: category is String? ? category : this.category,
    );
  }
}
