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
import 'dart:typed_data' as _idt;
import 'package:claimdesk_server/src/generated/create_item_input.dart'
    as _io3ib2zd;
import 'package:claimdesk_server/src/generated/item_filter.dart' as _id50o94s;
import 'package:claimdesk_server/src/generated/item_patch.dart' as _isrhr89g;
import 'package:claimdesk_server/src/generated/protocol.dart' as _ii1g677k;
import 'package:claimdesk_server/src/generated/release_input.dart' as _i1zdvvde;
import 'package:claimdesk_server/src/generated/report_filter.dart' as _icei7w9h;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../endpoints/admin_endpoint.dart' as _i5t1w2d2;
import '../endpoints/desk_stream_endpoint.dart' as _io3746h0;
import '../endpoints/item_endpoint.dart' as _irwxp2xj;
import '../endpoints/match_endpoint.dart' as _iznotijq;
import '../endpoints/release_endpoint.dart' as _i3y57dtc;
import '../endpoints/report_endpoint.dart' as _i90z2r7i;
import '../endpoints/venue_endpoint.dart' as _im3sz6ep;
import '../greetings/greeting_endpoint.dart' as _il624ik7;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'admin': _i5t1w2d2.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'deskStream': _io3746h0.DeskStreamEndpoint()
        ..initialize(
          server,
          'deskStream',
          null,
        ),
      'item': _irwxp2xj.ItemEndpoint()
        ..initialize(
          server,
          'item',
          null,
        ),
      'match': _iznotijq.MatchEndpoint()
        ..initialize(
          server,
          'match',
          null,
        ),
      'release': _i3y57dtc.ReleaseEndpoint()
        ..initialize(
          server,
          'release',
          null,
        ),
      'report': _i90z2r7i.ReportEndpoint()
        ..initialize(
          server,
          'report',
          null,
        ),
      'venue': _im3sz6ep.VenueEndpoint()
        ..initialize(
          server,
          'venue',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['admin'] = _is.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'runNightly': _is.MethodConnector(
          name: 'runNightly',
          params: {
            'secret': _is.ParameterDescription(
              name: 'secret',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).runNightly(
                    session,
                    params['secret'],
                  ),
        ),
        'seedDemoItems': _is.MethodConnector(
          name: 'seedDemoItems',
          params: {
            'secret': _is.ParameterDescription(
              name: 'secret',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['admin'] as _i5t1w2d2.AdminEndpoint).seedDemoItems(
                    session,
                    params['secret'],
                  ),
        ),
        'seedDemoReports': _is.MethodConnector(
          name: 'seedDemoReports',
          params: {
            'secret': _is.ParameterDescription(
              name: 'secret',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .seedDemoReports(
                    session,
                    params['secret'],
                  ),
        ),
        'seedDemo': _is.MethodConnector(
          name: 'seedDemo',
          params: {
            'secret': _is.ParameterDescription(
              name: 'secret',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['admin'] as _i5t1w2d2.AdminEndpoint)
                  .seedDemo(
                    session,
                    params['secret'],
                  )
                  .then(
                    (record) => _ii1g677k.Protocol().mapRecordToJson(record),
                  ),
        ),
      },
    );
    connectors['deskStream'] = _is.EndpointConnector(
      name: 'deskStream',
      endpoint: endpoints['deskStream']!,
      methodConnectors: {
        'watchVenue': _is.MethodStreamConnector(
          name: 'watchVenue',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['deskStream'] as _io3746h0.DeskStreamEndpoint)
                  .watchVenue(
                    session,
                    params['venueId'],
                  ),
        ),
      },
    );
    connectors['item'] = _is.EndpointConnector(
      name: 'item',
      endpoint: endpoints['item']!,
      methodConnectors: {
        'requestPhotoUpload': _is.MethodConnector(
          name: 'requestPhotoUpload',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'contentType': _is.ParameterDescription(
              name: 'contentType',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['item'] as _irwxp2xj.ItemEndpoint)
                  .requestPhotoUpload(
                    session,
                    params['venueId'],
                    params['contentType'],
                  ),
        ),
        'createItem': _is.MethodConnector(
          name: 'createItem',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_io3ib2zd.CreateItemInput>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['item'] as _irwxp2xj.ItemEndpoint).createItem(
                    session,
                    params['venueId'],
                    params['input'],
                  ),
        ),
        'getItem': _is.MethodConnector(
          name: 'getItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['item'] as _irwxp2xj.ItemEndpoint).getItem(
                session,
                params['itemId'],
              ),
        ),
        'listItems': _is.MethodConnector(
          name: 'listItems',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'filter': _is.ParameterDescription(
              name: 'filter',
              type: _is.getType<_id50o94s.ItemFilter>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['item'] as _irwxp2xj.ItemEndpoint).listItems(
                    session,
                    params['venueId'],
                    params['filter'],
                  ),
        ),
        'photoUrl': _is.MethodConnector(
          name: 'photoUrl',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'thumb': _is.ParameterDescription(
              name: 'thumb',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['item'] as _irwxp2xj.ItemEndpoint).photoUrl(
                session,
                params['itemId'],
                thumb: params['thumb'],
              ),
        ),
        'updateItem': _is.MethodConnector(
          name: 'updateItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'patch': _is.ParameterDescription(
              name: 'patch',
              type: _is.getType<_isrhr89g.ItemPatch>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['item'] as _irwxp2xj.ItemEndpoint).updateItem(
                    session,
                    params['itemId'],
                    params['patch'],
                  ),
        ),
        'recaption': _is.MethodConnector(
          name: 'recaption',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['item'] as _irwxp2xj.ItemEndpoint).recaption(
                    session,
                    params['itemId'],
                  ),
        ),
        'captionRuns': _is.MethodConnector(
          name: 'captionRuns',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['item'] as _irwxp2xj.ItemEndpoint).captionRuns(
                    session,
                    params['itemId'],
                  ),
        ),
      },
    );
    connectors['match'] = _is.EndpointConnector(
      name: 'match',
      endpoint: endpoints['match']!,
      methodConnectors: {
        'answers': _is.MethodConnector(
          name: 'answers',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).answers(
                    session,
                    params['matchId'],
                  ),
        ),
        'inbox': _is.MethodConnector(
          name: 'inbox',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['match'] as _iznotijq.MatchEndpoint).inbox(
                session,
                params['venueId'],
              ),
        ),
        'forReport': _is.MethodConnector(
          name: 'forReport',
          params: {
            'reportId': _is.ParameterDescription(
              name: 'reportId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).forReport(
                    session,
                    params['reportId'],
                  ),
        ),
        'forItem': _is.MethodConnector(
          name: 'forItem',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).forItem(
                    session,
                    params['itemId'],
                  ),
        ),
        'rematch': _is.MethodConnector(
          name: 'rematch',
          params: {
            'reportId': _is.ParameterDescription(
              name: 'reportId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).rematch(
                    session,
                    params['reportId'],
                  ),
        ),
        'confirm': _is.MethodConnector(
          name: 'confirm',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['match'] as _iznotijq.MatchEndpoint).confirm(
                    session,
                    params['matchId'],
                  ),
        ),
        'reject': _is.MethodConnector(
          name: 'reject',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['match'] as _iznotijq.MatchEndpoint).reject(
                session,
                params['matchId'],
                params['reason'],
              ),
        ),
      },
    );
    connectors['release'] = _is.EndpointConnector(
      name: 'release',
      endpoint: endpoints['release']!,
      methodConnectors: {
        'markReady': _is.MethodConnector(
          name: 'markReady',
          params: {
            'matchId': _is.ParameterDescription(
              name: 'matchId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['release'] as _i3y57dtc.ReleaseEndpoint).markReady(
                    session,
                    params['matchId'],
                  ),
        ),
        'release': _is.MethodConnector(
          name: 'release',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'input': _is.ParameterDescription(
              name: 'input',
              type: _is.getType<_i1zdvvde.ReleaseInput>(),
              nullable: false,
            ),
            'signaturePng': _is.ParameterDescription(
              name: 'signaturePng',
              type: _is.getType<_idt.ByteData?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['release'] as _i3y57dtc.ReleaseEndpoint).release(
                    session,
                    params['itemId'],
                    params['input'],
                    params['signaturePng'],
                  ),
        ),
        'releaseRecord': _is.MethodConnector(
          name: 'releaseRecord',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['release'] as _i3y57dtc.ReleaseEndpoint)
                  .releaseRecord(
                    session,
                    params['itemId'],
                  ),
        ),
        'signatureUrl': _is.MethodConnector(
          name: 'signatureUrl',
          params: {
            'itemId': _is.ParameterDescription(
              name: 'itemId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['release'] as _i3y57dtc.ReleaseEndpoint)
                  .signatureUrl(
                    session,
                    params['itemId'],
                  ),
        ),
      },
    );
    connectors['report'] = _is.EndpointConnector(
      name: 'report',
      endpoint: endpoints['report']!,
      methodConnectors: {
        'listReports': _is.MethodConnector(
          name: 'listReports',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'filter': _is.ParameterDescription(
              name: 'filter',
              type: _is.getType<_icei7w9h.ReportFilter>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['report'] as _i90z2r7i.ReportEndpoint).listReports(
                    session,
                    params['venueId'],
                    params['filter'],
                  ),
        ),
        'getReport': _is.MethodConnector(
          name: 'getReport',
          params: {
            'reportId': _is.ParameterDescription(
              name: 'reportId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['report'] as _i90z2r7i.ReportEndpoint).getReport(
                    session,
                    params['reportId'],
                  ),
        ),
        'findByRefCode': _is.MethodConnector(
          name: 'findByRefCode',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'refCode': _is.ParameterDescription(
              name: 'refCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['report'] as _i90z2r7i.ReportEndpoint)
                  .findByRefCode(
                    session,
                    params['venueId'],
                    params['refCode'],
                  ),
        ),
        'closeReport': _is.MethodConnector(
          name: 'closeReport',
          params: {
            'reportId': _is.ParameterDescription(
              name: 'reportId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'reason': _is.ParameterDescription(
              name: 'reason',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['report'] as _i90z2r7i.ReportEndpoint).closeReport(
                    session,
                    params['reportId'],
                    params['reason'],
                  ),
        ),
      },
    );
    connectors['venue'] = _is.EndpointConnector(
      name: 'venue',
      endpoint: endpoints['venue']!,
      methodConnectors: {
        'myMemberships': _is.MethodConnector(
          name: 'myMemberships',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['venue'] as _im3sz6ep.VenueEndpoint)
                  .myMemberships(session),
        ),
        'getVenue': _is.MethodConnector(
          name: 'getVenue',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['venue'] as _im3sz6ep.VenueEndpoint).getVenue(
                    session,
                    params['venueId'],
                  ),
        ),
        'zones': _is.MethodConnector(
          name: 'zones',
          params: {
            'venueId': _is.ParameterDescription(
              name: 'venueId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['venue'] as _im3sz6ep.VenueEndpoint).zones(
                session,
                params['venueId'],
              ),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
