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
import 'dart:async' as _ida;
import 'package:claimdesk_client/src/protocol/caption_run.dart' as _i9gd0od7;
import 'package:claimdesk_client/src/protocol/create_item_input.dart'
    as _i0l2w05c;
import 'package:claimdesk_client/src/protocol/desk_event.dart' as _idjit943;
import 'package:claimdesk_client/src/protocol/found_item.dart' as _i8bj3kzd;
import 'package:claimdesk_client/src/protocol/greetings/greeting.dart'
    as _i8l8ycv0;
import 'package:claimdesk_client/src/protocol/item_filter.dart' as _inizcy6n;
import 'package:claimdesk_client/src/protocol/item_patch.dart' as _i410ys6o;
import 'package:claimdesk_client/src/protocol/photo_upload_ticket.dart'
    as _i1f97sgb;
import 'package:claimdesk_client/src/protocol/staff_membership.dart'
    as _ing7mbhm;
import 'package:claimdesk_client/src/protocol/venue.dart' as _i53htkm0;
import 'package:claimdesk_client/src/protocol/work_item.dart' as _i5t1jx4h;
import 'package:claimdesk_client/src/protocol/zone.dart' as _inmoeruh;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'protocol.dart' as _il2as5qe;

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// {@category Endpoint}
class EndpointAdmin extends _isc.EndpointRef {
  EndpointAdmin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  _ida.Future<
    ({
      _isc.UuidValue staffId,
      _isc.UuidValue supervisorId,
      _isc.UuidValue venueId,
    })
  >
  seedDemo(String secret) =>
      caller.callServerEndpoint<
        ({
          _isc.UuidValue staffId,
          _isc.UuidValue supervisorId,
          _isc.UuidValue venueId,
        })
      >(
        'admin',
        'seedDemo',
        {'secret': secret},
      );
}

/// Live desk updates are visible only to staff assigned to the venue.
/// {@category Endpoint}
class EndpointDeskStream extends _isc.EndpointRef {
  EndpointDeskStream(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'deskStream';

  _ida.Stream<_idjit943.DeskEvent> watchVenue(_isc.UuidValue venueId) =>
      caller.callStreamingServerEndpoint<
        _ida.Stream<_idjit943.DeskEvent>,
        _idjit943.DeskEvent
      >(
        'deskStream',
        'watchVenue',
        {'venueId': venueId},
        {},
      );
}

/// {@category Endpoint}
class EndpointItem extends _isc.EndpointRef {
  EndpointItem(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'item';

  _ida.Future<_i1f97sgb.PhotoUploadTicket> requestPhotoUpload(
    _isc.UuidValue venueId,
    String contentType,
  ) => caller.callServerEndpoint<_i1f97sgb.PhotoUploadTicket>(
    'item',
    'requestPhotoUpload',
    {
      'venueId': venueId,
      'contentType': contentType,
    },
  );

  _ida.Future<_i8bj3kzd.FoundItem> createItem(
    _isc.UuidValue venueId,
    _i0l2w05c.CreateItemInput input,
  ) => caller.callServerEndpoint<_i8bj3kzd.FoundItem>(
    'item',
    'createItem',
    {
      'venueId': venueId,
      'input': input,
    },
  );

  _ida.Future<_i8bj3kzd.FoundItem> getItem(_isc.UuidValue itemId) =>
      caller.callServerEndpoint<_i8bj3kzd.FoundItem>(
        'item',
        'getItem',
        {'itemId': itemId},
      );

  _ida.Future<List<_i8bj3kzd.FoundItem>> listItems(
    _isc.UuidValue venueId,
    _inizcy6n.ItemFilter filter,
  ) => caller.callServerEndpoint<List<_i8bj3kzd.FoundItem>>(
    'item',
    'listItems',
    {
      'venueId': venueId,
      'filter': filter,
    },
  );

  _ida.Future<String?> photoUrl(
    _isc.UuidValue itemId, {
    required bool thumb,
  }) => caller.callServerEndpoint<String?>(
    'item',
    'photoUrl',
    {
      'itemId': itemId,
      'thumb': thumb,
    },
  );

  _ida.Future<_i8bj3kzd.FoundItem> updateItem(
    _isc.UuidValue itemId,
    _i410ys6o.ItemPatch patch,
  ) => caller.callServerEndpoint<_i8bj3kzd.FoundItem>(
    'item',
    'updateItem',
    {
      'itemId': itemId,
      'patch': patch,
    },
  );

  _ida.Future<_i5t1jx4h.WorkItem> recaption(_isc.UuidValue itemId) =>
      caller.callServerEndpoint<_i5t1jx4h.WorkItem>(
        'item',
        'recaption',
        {'itemId': itemId},
      );

  _ida.Future<List<_i9gd0od7.CaptionRun>> captionRuns(_isc.UuidValue itemId) =>
      caller.callServerEndpoint<List<_i9gd0od7.CaptionRun>>(
        'item',
        'captionRuns',
        {'itemId': itemId},
      );
}

/// {@category Endpoint}
class EndpointVenue extends _isc.EndpointRef {
  EndpointVenue(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'venue';

  _ida.Future<List<_ing7mbhm.StaffMembership>> myMemberships() =>
      caller.callServerEndpoint<List<_ing7mbhm.StaffMembership>>(
        'venue',
        'myMemberships',
        {},
      );

  _ida.Future<_i53htkm0.Venue> getVenue(_isc.UuidValue venueId) =>
      caller.callServerEndpoint<_i53htkm0.Venue>(
        'venue',
        'getVenue',
        {'venueId': venueId},
      );

  _ida.Future<List<_inmoeruh.Zone>> zones(_isc.UuidValue venueId) =>
      caller.callServerEndpoint<List<_inmoeruh.Zone>>(
        'venue',
        'zones',
        {'venueId': venueId},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i8l8ycv0.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i8l8ycv0.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    admin = EndpointAdmin(this);
    deskStream = EndpointDeskStream(this);
    item = EndpointItem(this);
    venue = EndpointVenue(this);
    greeting = EndpointGreeting(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointAdmin admin;

  late final EndpointDeskStream deskStream;

  late final EndpointItem item;

  late final EndpointVenue venue;

  late final EndpointGreeting greeting;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'admin': admin,
    'deskStream': deskStream,
    'item': item,
    'venue': venue,
    'greeting': greeting,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
