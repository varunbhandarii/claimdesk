import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

/// Shared by the server, the demo seed command, and integration tests.
void configureAuthentication(Serverpod pod) {
  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      ServerpodCloudEmailIdpConfig(appDisplayName: 'claimdesk'),
    ],
  );
}
