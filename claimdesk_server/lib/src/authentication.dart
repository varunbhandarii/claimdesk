import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';

import 'auth/staff_google_link.dart';

/// Shared by the server, the demo seed command, and integration tests.
///
/// Google sign-in is offered only when the `googleClientSecret` password
/// holds the Google web client's JSON; without it the server, the seeder and
/// the tests run with email sign-in alone.
void configureAuthentication(Serverpod pod) {
  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      ServerpodCloudEmailIdpConfig(appDisplayName: 'claimdesk'),
      if (googleClientId(pod) != null)
        GoogleIdpConfigFromPasswords(
          onAfterGoogleAccountCreated: StaffGoogleLink.refuseNewUser,
        ),
    ],
  );
}

/// The public Google web client ID, read from the client secret JSON, or null
/// when Google sign-in is not set up. The secret itself never leaves the
/// server.
String? googleClientId(Serverpod pod) {
  final secret = pod.getPassword('googleClientSecret');
  if (secret == null || secret.trim().isEmpty) return null;
  try {
    return GoogleClientSecret.fromJsonString(secret).clientId;
  } on Object {
    return null;
  }
}
