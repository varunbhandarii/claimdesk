import 'dart:convert';
import 'package:claimdesk_server/src/web/routes/app_config_route.dart';
import 'package:serverpod_auth_idp_server/providers/google.dart';
import 'package:test/test.dart';

void main() {
  test('the app config shares the Google client ID only when it is set', () {
    final plain =
        jsonDecode(AppConfigWidget(apiUrl: 'https://api.example/').render())
            as Map;
    expect(plain, {'apiUrl': 'https://api.example/'});

    final secret = jsonEncode({
      'web': {
        'client_id': 'public-id.apps.googleusercontent.com',
        'client_secret': 'never-shared',
        'redirect_uris': ['https://desk.example/auth/callback'],
      },
    });
    final clientId = GoogleClientSecret.fromJsonString(secret).clientId;
    final body = AppConfigWidget(
      apiUrl: 'https://api.example/',
      googleClientId: clientId,
    ).render();
    expect(jsonDecode(body), {
      'apiUrl': 'https://api.example/',
      'googleClientId': 'public-id.apps.googleusercontent.com',
    });
    expect(body, isNot(contains('never-shared')));
    expect(body, isNot(contains('client_secret')));
  });
}
