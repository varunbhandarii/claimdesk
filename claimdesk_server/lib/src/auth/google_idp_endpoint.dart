import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'staff_google_link.dart';

/// Google sign-in for existing staff. Each sign-in first links the Google
/// account to the staff member with the same verified email address, or
/// refuses it, before the identity provider issues a session.
class GoogleIdpEndpoint extends GoogleIdpBaseEndpoint {
  @override
  Future<AuthSuccess> login(
    Session session, {
    required String idToken,
    required String? accessToken,
  }) async {
    final details = await googleIdp.utils.fetchAccountDetails(
      session,
      idToken: idToken,
      accessToken: accessToken,
    );
    await StaffGoogleLink.linkIfStaff(session, details);
    return super.login(session, idToken: idToken, accessToken: accessToken);
  }

  /// The web flow: the authorization code can be exchanged only once, so it
  /// is exchanged here and the tokens go through [login].
  @override
  Future<AuthSuccess> loginWithCode(
    Session session, {
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    final tokens = await googleIdp.utils.exchangeCodeForToken(
      session,
      code: code,
      codeVerifier: codeVerifier,
      redirectUri: redirectUri,
    );
    return login(
      session,
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
  }
}
