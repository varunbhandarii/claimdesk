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
import 'report_status.dart' as _i8pcsu0p;

abstract class ReportFilter
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ReportFilter._({
    this.status,
    this.zoneId,
    this.category,
  });

  factory ReportFilter({
    _i8pcsu0p.ReportStatus? status,
    _isc.UuidValue? zoneId,
    String? category,
  }) = _ReportFilterImpl;

  factory ReportFilter.fromJson(Map<String, dynamic> jsonSerialization) {
    return ReportFilter(
      status: jsonSerialization['status'] == null
          ? null
          : _i8pcsu0p.ReportStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      zoneId: jsonSerialization['zoneId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['zoneId']),
      category: jsonSerialization['category'] as String?,
    );
  }

  _i8pcsu0p.ReportStatus? status;

  _isc.UuidValue? zoneId;

  String? category;

  /// Returns a shallow copy of this [ReportFilter]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ReportFilter copyWith({
    _i8pcsu0p.ReportStatus? status,
    _isc.UuidValue? zoneId,
    String? category,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ReportFilter',
      if (status != null) 'status': status?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (category != null) 'category': category,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ReportFilter',
      if (status != null) 'status': status?.toJson(),
      if (zoneId != null) 'zoneId': zoneId?.toJson(),
      if (category != null) 'category': category,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ReportFilterImpl extends ReportFilter {
  _ReportFilterImpl({
    _i8pcsu0p.ReportStatus? status,
    _isc.UuidValue? zoneId,
    String? category,
  }) : super._(
         status: status,
         zoneId: zoneId,
         category: category,
       );

  /// Returns a shallow copy of this [ReportFilter]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ReportFilter copyWith({
    Object? status = _Undefined,
    Object? zoneId = _Undefined,
    Object? category = _Undefined,
  }) {
    return ReportFilter(
      status: status is _i8pcsu0p.ReportStatus? ? status : this.status,
      zoneId: zoneId is _isc.UuidValue? ? zoneId : this.zoneId,
      category: category is String? ? category : this.category,
    );
  }
}
