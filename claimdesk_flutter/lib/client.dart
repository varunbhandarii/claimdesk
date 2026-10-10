import 'dart:async';
import 'dart:convert';

import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

import 'data/read_retry.dart';

// When you are running the app on a physical device, you need to set the
// server URL to the IP address of your computer. You can find the IP
// address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
//
// You can set the variable when running or building your app like this:
// E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
//
// Otherwise, the server URL is fetched from the assets/config.json file or
// defaults to http://$localhost:8080/ if not found.
final serverUrl = getServerUrl();

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
late final Client client;

/// The generated client, with reads retried after network failures.
class DeskClient extends Client {
  DeskClient(super.host);

  @override
  Future<T> callServerEndpoint<T>(
    String endpoint,
    String method,
    Map<String, dynamic> args, {
    bool authenticated = true,
  }) => retryReads(
    endpoint,
    method,
    () => super.callServerEndpoint<T>(
      endpoint,
      method,
      args,
      authenticated: authenticated,
    ),
  );
}

late final Future<bool> authInitialization;

/// Whether Google sign-in is available: on the web when the server shares a
/// Google client ID in the app config, on Android when the build passes
/// `GOOGLE_SERVER_CLIENT_ID`. Staff can always sign in with email.
late final Future<bool> googleSignInReady;

Future<void> initializeClient() async {
  client = DeskClient(await serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();
  authInitialization = client.auth.initialize();
  unawaited(authInitialization);
  googleSignInReady = _initializeGoogleSignIn();
}

Future<bool> _initializeGoogleSignIn() async {
  try {
    if (kIsWeb) {
      final config =
          jsonDecode(await rootBundle.loadString('assets/config.json'))
              as Map<String, dynamic>;
      final clientId = config['googleClientId'] as String?;
      if (clientId == null || clientId.isEmpty) return false;
      await client.auth.initializeGoogleSignIn(
        clientId: clientId,
        redirectUri: '${Uri.base.origin}/auth/callback',
      );
      return true;
    }
    if (!const bool.hasEnvironment('GOOGLE_SERVER_CLIENT_ID')) return false;
    await client.auth.initializeGoogleSignIn();
    return true;
  } catch (e) {
    debugPrint('Google sign-in is unavailable: $e');
    return false;
  }
}
