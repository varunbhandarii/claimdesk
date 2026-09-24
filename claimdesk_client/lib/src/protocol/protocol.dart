/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:claimdesk_client/src/protocol/caption_run.dart' as _i9gd0od7;
import 'package:claimdesk_client/src/protocol/found_item.dart' as _i8bj3kzd;
import 'package:claimdesk_client/src/protocol/staff_membership.dart'
    as _ing7mbhm;
import 'package:claimdesk_client/src/protocol/zone.dart' as _inmoeruh;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'already_released_exception.dart' as _igbhs0au;
import 'audit_event.dart' as _irb38j2y;
import 'audit_payload.dart' as _imod1ub6;
import 'caption_run.dart' as _igo1wxdq;
import 'create_item_input.dart' as _i6s4pod3;
import 'custody_event.dart' as _iq6v1376;
import 'desk_event.dart' as _iz4ruabw;
import 'found_item.dart' as _i52cv103;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'item_attributes.dart' as _i43d0yeo;
import 'item_filter.dart' as _ibf35g9z;
import 'item_match.dart' as _i989z6nt;
import 'item_patch.dart' as _i3b5hl76;
import 'item_status.dart' as _ibbyonnn;
import 'lost_report.dart' as _iyhihx8i;
import 'match_explanation.dart' as _i7ltg7v2;
import 'match_state.dart' as _idznkk1k;
import 'not_a_member_exception.dart' as _ilheyvx1;
import 'photo_upload_ticket.dart' as _ivh14x5g;
import 'release_record.dart' as _ieeq0b1h;
import 'report_answer.dart' as _ihkjjm70;
import 'report_status.dart' as _i8pcsu0p;
import 'retention_policy.dart' as _ic8ul1lq;
import 'staff_membership.dart' as _isosyfem;
import 'staff_role.dart' as _i120pgjk;
import 'value_band.dart' as _iphilgki;
import 'venue.dart' as _in4rmfby;
import 'work_item.dart' as _ik77na07;
import 'work_payload.dart' as _ib3jfnwt;
import 'work_state.dart' as _i6iais05;
import 'zone.dart' as _ixcxr4o1;
export 'already_released_exception.dart';
export 'audit_event.dart';
export 'audit_payload.dart';
export 'caption_run.dart';
export 'create_item_input.dart';
export 'custody_event.dart';
export 'desk_event.dart';
export 'found_item.dart';
export 'greetings/greeting.dart';
export 'item_attributes.dart';
export 'item_filter.dart';
export 'item_match.dart';
export 'item_patch.dart';
export 'item_status.dart';
export 'lost_report.dart';
export 'match_explanation.dart';
export 'match_state.dart';
export 'not_a_member_exception.dart';
export 'photo_upload_ticket.dart';
export 'release_record.dart';
export 'report_answer.dart';
export 'report_status.dart';
export 'retention_policy.dart';
export 'staff_membership.dart';
export 'staff_role.dart';
export 'value_band.dart';
export 'venue.dart';
export 'work_item.dart';
export 'work_payload.dart';
export 'work_state.dart';
export 'zone.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _igbhs0au.AlreadyReleasedException) {
      return _igbhs0au.AlreadyReleasedException.fromJson(data) as T;
    }
    if (t == _irb38j2y.AuditEvent) {
      return _irb38j2y.AuditEvent.fromJson(data) as T;
    }
    if (t == _imod1ub6.AuditPayload) {
      return _imod1ub6.AuditPayload.fromJson(data) as T;
    }
    if (t == _igo1wxdq.CaptionRun) {
      return _igo1wxdq.CaptionRun.fromJson(data) as T;
    }
    if (t == _i6s4pod3.CreateItemInput) {
      return _i6s4pod3.CreateItemInput.fromJson(data) as T;
    }
    if (t == _iq6v1376.CustodyEvent) {
      return _iq6v1376.CustodyEvent.fromJson(data) as T;
    }
    if (t == _iz4ruabw.DeskEvent) {
      return _iz4ruabw.DeskEvent.fromJson(data) as T;
    }
    if (t == _i52cv103.FoundItem) {
      return _i52cv103.FoundItem.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i43d0yeo.ItemAttributes) {
      return _i43d0yeo.ItemAttributes.fromJson(data) as T;
    }
    if (t == _ibf35g9z.ItemFilter) {
      return _ibf35g9z.ItemFilter.fromJson(data) as T;
    }
    if (t == _i989z6nt.ItemMatch) {
      return _i989z6nt.ItemMatch.fromJson(data) as T;
    }
    if (t == _i3b5hl76.ItemPatch) {
      return _i3b5hl76.ItemPatch.fromJson(data) as T;
    }
    if (t == _ibbyonnn.ItemStatus) {
      return _ibbyonnn.ItemStatus.fromJson(data) as T;
    }
    if (t == _iyhihx8i.LostReport) {
      return _iyhihx8i.LostReport.fromJson(data) as T;
    }
    if (t == _i7ltg7v2.MatchExplanation) {
      return _i7ltg7v2.MatchExplanation.fromJson(data) as T;
    }
    if (t == _idznkk1k.MatchState) {
      return _idznkk1k.MatchState.fromJson(data) as T;
    }
    if (t == _ilheyvx1.NotAMemberException) {
      return _ilheyvx1.NotAMemberException.fromJson(data) as T;
    }
    if (t == _ivh14x5g.PhotoUploadTicket) {
      return _ivh14x5g.PhotoUploadTicket.fromJson(data) as T;
    }
    if (t == _ieeq0b1h.ReleaseRecord) {
      return _ieeq0b1h.ReleaseRecord.fromJson(data) as T;
    }
    if (t == _ihkjjm70.ReportAnswer) {
      return _ihkjjm70.ReportAnswer.fromJson(data) as T;
    }
    if (t == _i8pcsu0p.ReportStatus) {
      return _i8pcsu0p.ReportStatus.fromJson(data) as T;
    }
    if (t == _ic8ul1lq.RetentionPolicy) {
      return _ic8ul1lq.RetentionPolicy.fromJson(data) as T;
    }
    if (t == _isosyfem.StaffMembership) {
      return _isosyfem.StaffMembership.fromJson(data) as T;
    }
    if (t == _i120pgjk.StaffRole) {
      return _i120pgjk.StaffRole.fromJson(data) as T;
    }
    if (t == _iphilgki.ValueBand) {
      return _iphilgki.ValueBand.fromJson(data) as T;
    }
    if (t == _in4rmfby.Venue) {
      return _in4rmfby.Venue.fromJson(data) as T;
    }
    if (t == _ik77na07.WorkItem) {
      return _ik77na07.WorkItem.fromJson(data) as T;
    }
    if (t == _ib3jfnwt.WorkPayload) {
      return _ib3jfnwt.WorkPayload.fromJson(data) as T;
    }
    if (t == _i6iais05.WorkState) {
      return _i6iais05.WorkState.fromJson(data) as T;
    }
    if (t == _ixcxr4o1.Zone) {
      return _ixcxr4o1.Zone.fromJson(data) as T;
    }
    if (t == _isc.getType<_igbhs0au.AlreadyReleasedException?>()) {
      return (data != null
              ? _igbhs0au.AlreadyReleasedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_irb38j2y.AuditEvent?>()) {
      return (data != null ? _irb38j2y.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_imod1ub6.AuditPayload?>()) {
      return (data != null ? _imod1ub6.AuditPayload.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_igo1wxdq.CaptionRun?>()) {
      return (data != null ? _igo1wxdq.CaptionRun.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6s4pod3.CreateItemInput?>()) {
      return (data != null ? _i6s4pod3.CreateItemInput.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iq6v1376.CustodyEvent?>()) {
      return (data != null ? _iq6v1376.CustodyEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iz4ruabw.DeskEvent?>()) {
      return (data != null ? _iz4ruabw.DeskEvent.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i52cv103.FoundItem?>()) {
      return (data != null ? _i52cv103.FoundItem.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i43d0yeo.ItemAttributes?>()) {
      return (data != null ? _i43d0yeo.ItemAttributes.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ibf35g9z.ItemFilter?>()) {
      return (data != null ? _ibf35g9z.ItemFilter.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i989z6nt.ItemMatch?>()) {
      return (data != null ? _i989z6nt.ItemMatch.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i3b5hl76.ItemPatch?>()) {
      return (data != null ? _i3b5hl76.ItemPatch.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ibbyonnn.ItemStatus?>()) {
      return (data != null ? _ibbyonnn.ItemStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iyhihx8i.LostReport?>()) {
      return (data != null ? _iyhihx8i.LostReport.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i7ltg7v2.MatchExplanation?>()) {
      return (data != null ? _i7ltg7v2.MatchExplanation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idznkk1k.MatchState?>()) {
      return (data != null ? _idznkk1k.MatchState.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ilheyvx1.NotAMemberException?>()) {
      return (data != null
              ? _ilheyvx1.NotAMemberException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ivh14x5g.PhotoUploadTicket?>()) {
      return (data != null ? _ivh14x5g.PhotoUploadTicket.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ieeq0b1h.ReleaseRecord?>()) {
      return (data != null ? _ieeq0b1h.ReleaseRecord.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ihkjjm70.ReportAnswer?>()) {
      return (data != null ? _ihkjjm70.ReportAnswer.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i8pcsu0p.ReportStatus?>()) {
      return (data != null ? _i8pcsu0p.ReportStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ic8ul1lq.RetentionPolicy?>()) {
      return (data != null ? _ic8ul1lq.RetentionPolicy.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_isosyfem.StaffMembership?>()) {
      return (data != null ? _isosyfem.StaffMembership.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i120pgjk.StaffRole?>()) {
      return (data != null ? _i120pgjk.StaffRole.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iphilgki.ValueBand?>()) {
      return (data != null ? _iphilgki.ValueBand.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_in4rmfby.Venue?>()) {
      return (data != null ? _in4rmfby.Venue.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ik77na07.WorkItem?>()) {
      return (data != null ? _ik77na07.WorkItem.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ib3jfnwt.WorkPayload?>()) {
      return (data != null ? _ib3jfnwt.WorkPayload.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6iais05.WorkState?>()) {
      return (data != null ? _i6iais05.WorkState.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ixcxr4o1.Zone?>()) {
      return (data != null ? _ixcxr4o1.Zone.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _isc.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_isc.UuidValue>) {
      return (data as List).map((e) => deserialize<_isc.UuidValue>(e)).toList()
          as T;
    }
    if (t ==
        _isc
            .getType<
              ({
                _isc.UuidValue staffId,
                _isc.UuidValue supervisorId,
                _isc.UuidValue venueId,
              })
            >()) {
      return (
            staffId: deserialize<_isc.UuidValue>(
              ((data as Map)['n'] as Map)['staffId'],
            ),
            supervisorId: deserialize<_isc.UuidValue>(
              data['n']['supervisorId'],
            ),
            venueId: deserialize<_isc.UuidValue>(data['n']['venueId']),
          )
          as T;
    }
    if (t == List<_i8bj3kzd.FoundItem>) {
      return (data as List)
              .map((e) => deserialize<_i8bj3kzd.FoundItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i9gd0od7.CaptionRun>) {
      return (data as List)
              .map((e) => deserialize<_i9gd0od7.CaptionRun>(e))
              .toList()
          as T;
    }
    if (t == List<_ing7mbhm.StaffMembership>) {
      return (data as List)
              .map((e) => deserialize<_ing7mbhm.StaffMembership>(e))
              .toList()
          as T;
    }
    if (t == List<_inmoeruh.Zone>) {
      return (data as List).map((e) => deserialize<_inmoeruh.Zone>(e)).toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _igbhs0au.AlreadyReleasedException => 'AlreadyReleasedException',
      _irb38j2y.AuditEvent => 'AuditEvent',
      _imod1ub6.AuditPayload => 'AuditPayload',
      _igo1wxdq.CaptionRun => 'CaptionRun',
      _i6s4pod3.CreateItemInput => 'CreateItemInput',
      _iq6v1376.CustodyEvent => 'CustodyEvent',
      _iz4ruabw.DeskEvent => 'DeskEvent',
      _i52cv103.FoundItem => 'FoundItem',
      _izw8z7ou.Greeting => 'Greeting',
      _i43d0yeo.ItemAttributes => 'ItemAttributes',
      _ibf35g9z.ItemFilter => 'ItemFilter',
      _i989z6nt.ItemMatch => 'ItemMatch',
      _i3b5hl76.ItemPatch => 'ItemPatch',
      _ibbyonnn.ItemStatus => 'ItemStatus',
      _iyhihx8i.LostReport => 'LostReport',
      _i7ltg7v2.MatchExplanation => 'MatchExplanation',
      _idznkk1k.MatchState => 'MatchState',
      _ilheyvx1.NotAMemberException => 'NotAMemberException',
      _ivh14x5g.PhotoUploadTicket => 'PhotoUploadTicket',
      _ieeq0b1h.ReleaseRecord => 'ReleaseRecord',
      _ihkjjm70.ReportAnswer => 'ReportAnswer',
      _i8pcsu0p.ReportStatus => 'ReportStatus',
      _ic8ul1lq.RetentionPolicy => 'RetentionPolicy',
      _isosyfem.StaffMembership => 'StaffMembership',
      _i120pgjk.StaffRole => 'StaffRole',
      _iphilgki.ValueBand => 'ValueBand',
      _in4rmfby.Venue => 'Venue',
      _ik77na07.WorkItem => 'WorkItem',
      _ib3jfnwt.WorkPayload => 'WorkPayload',
      _i6iais05.WorkState => 'WorkState',
      _ixcxr4o1.Zone => 'Zone',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('claimdesk.', '');
    }

    switch (data) {
      case _igbhs0au.AlreadyReleasedException():
        return 'AlreadyReleasedException';
      case _irb38j2y.AuditEvent():
        return 'AuditEvent';
      case _imod1ub6.AuditPayload():
        return 'AuditPayload';
      case _igo1wxdq.CaptionRun():
        return 'CaptionRun';
      case _i6s4pod3.CreateItemInput():
        return 'CreateItemInput';
      case _iq6v1376.CustodyEvent():
        return 'CustodyEvent';
      case _iz4ruabw.DeskEvent():
        return 'DeskEvent';
      case _i52cv103.FoundItem():
        return 'FoundItem';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i43d0yeo.ItemAttributes():
        return 'ItemAttributes';
      case _ibf35g9z.ItemFilter():
        return 'ItemFilter';
      case _i989z6nt.ItemMatch():
        return 'ItemMatch';
      case _i3b5hl76.ItemPatch():
        return 'ItemPatch';
      case _ibbyonnn.ItemStatus():
        return 'ItemStatus';
      case _iyhihx8i.LostReport():
        return 'LostReport';
      case _i7ltg7v2.MatchExplanation():
        return 'MatchExplanation';
      case _idznkk1k.MatchState():
        return 'MatchState';
      case _ilheyvx1.NotAMemberException():
        return 'NotAMemberException';
      case _ivh14x5g.PhotoUploadTicket():
        return 'PhotoUploadTicket';
      case _ieeq0b1h.ReleaseRecord():
        return 'ReleaseRecord';
      case _ihkjjm70.ReportAnswer():
        return 'ReportAnswer';
      case _i8pcsu0p.ReportStatus():
        return 'ReportStatus';
      case _ic8ul1lq.RetentionPolicy():
        return 'RetentionPolicy';
      case _isosyfem.StaffMembership():
        return 'StaffMembership';
      case _i120pgjk.StaffRole():
        return 'StaffRole';
      case _iphilgki.ValueBand():
        return 'ValueBand';
      case _in4rmfby.Venue():
        return 'Venue';
      case _ik77na07.WorkItem():
        return 'WorkItem';
      case _ib3jfnwt.WorkPayload():
        return 'WorkPayload';
      case _i6iais05.WorkState():
        return 'WorkState';
      case _ixcxr4o1.Zone():
        return 'Zone';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AlreadyReleasedException') {
      return deserialize<_igbhs0au.AlreadyReleasedException>(data['data']);
    }
    if (dataClassName == 'AuditEvent') {
      return deserialize<_irb38j2y.AuditEvent>(data['data']);
    }
    if (dataClassName == 'AuditPayload') {
      return deserialize<_imod1ub6.AuditPayload>(data['data']);
    }
    if (dataClassName == 'CaptionRun') {
      return deserialize<_igo1wxdq.CaptionRun>(data['data']);
    }
    if (dataClassName == 'CreateItemInput') {
      return deserialize<_i6s4pod3.CreateItemInput>(data['data']);
    }
    if (dataClassName == 'CustodyEvent') {
      return deserialize<_iq6v1376.CustodyEvent>(data['data']);
    }
    if (dataClassName == 'DeskEvent') {
      return deserialize<_iz4ruabw.DeskEvent>(data['data']);
    }
    if (dataClassName == 'FoundItem') {
      return deserialize<_i52cv103.FoundItem>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ItemAttributes') {
      return deserialize<_i43d0yeo.ItemAttributes>(data['data']);
    }
    if (dataClassName == 'ItemFilter') {
      return deserialize<_ibf35g9z.ItemFilter>(data['data']);
    }
    if (dataClassName == 'ItemMatch') {
      return deserialize<_i989z6nt.ItemMatch>(data['data']);
    }
    if (dataClassName == 'ItemPatch') {
      return deserialize<_i3b5hl76.ItemPatch>(data['data']);
    }
    if (dataClassName == 'ItemStatus') {
      return deserialize<_ibbyonnn.ItemStatus>(data['data']);
    }
    if (dataClassName == 'LostReport') {
      return deserialize<_iyhihx8i.LostReport>(data['data']);
    }
    if (dataClassName == 'MatchExplanation') {
      return deserialize<_i7ltg7v2.MatchExplanation>(data['data']);
    }
    if (dataClassName == 'MatchState') {
      return deserialize<_idznkk1k.MatchState>(data['data']);
    }
    if (dataClassName == 'NotAMemberException') {
      return deserialize<_ilheyvx1.NotAMemberException>(data['data']);
    }
    if (dataClassName == 'PhotoUploadTicket') {
      return deserialize<_ivh14x5g.PhotoUploadTicket>(data['data']);
    }
    if (dataClassName == 'ReleaseRecord') {
      return deserialize<_ieeq0b1h.ReleaseRecord>(data['data']);
    }
    if (dataClassName == 'ReportAnswer') {
      return deserialize<_ihkjjm70.ReportAnswer>(data['data']);
    }
    if (dataClassName == 'ReportStatus') {
      return deserialize<_i8pcsu0p.ReportStatus>(data['data']);
    }
    if (dataClassName == 'RetentionPolicy') {
      return deserialize<_ic8ul1lq.RetentionPolicy>(data['data']);
    }
    if (dataClassName == 'StaffMembership') {
      return deserialize<_isosyfem.StaffMembership>(data['data']);
    }
    if (dataClassName == 'StaffRole') {
      return deserialize<_i120pgjk.StaffRole>(data['data']);
    }
    if (dataClassName == 'ValueBand') {
      return deserialize<_iphilgki.ValueBand>(data['data']);
    }
    if (dataClassName == 'Venue') {
      return deserialize<_in4rmfby.Venue>(data['data']);
    }
    if (dataClassName == 'WorkItem') {
      return deserialize<_ik77na07.WorkItem>(data['data']);
    }
    if (dataClassName == 'WorkPayload') {
      return deserialize<_ib3jfnwt.WorkPayload>(data['data']);
    }
    if (dataClassName == 'WorkState') {
      return deserialize<_i6iais05.WorkState>(data['data']);
    }
    if (dataClassName == 'Zone') {
      return deserialize<_ixcxr4o1.Zone>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('claimdesk', this);
    _iacc.Protocol().registerHostProtocol('claimdesk', this);
  }

  @override
  String getModuleName() => 'claimdesk';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    if (record
        is ({
          _isc.UuidValue staffId,
          _isc.UuidValue supervisorId,
          _isc.UuidValue venueId,
        })) {
      return {
        "n": {
          "staffId": record.staffId.toJson(),
          "supervisorId": record.supervisorId.toJson(),
          "venueId": record.venueId.toJson(),
        },
      };
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}
