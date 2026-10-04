import 'package:serverpod/serverpod.dart';

class AppConfigWidget extends JsonWidget {
  final String apiUrl;

  /// The public Google web client ID when Google sign-in is set up. It is an
  /// identifier, not a secret; the client secret stays on the server.
  final String? googleClientId;

  AppConfigWidget({
    required this.apiUrl,
    this.googleClientId,
  }) : super(
         object: {
           'apiUrl': apiUrl,
           'googleClientId': ?googleClientId,
         },
       );
}

class AppConfigRoute extends WidgetRoute {
  AppConfigWidget widget;

  AppConfigRoute({
    required final ServerConfig apiConfig,
    String? googleClientId,
  }) : widget = AppConfigWidget(
         apiUrl: apiConfig.apiUrl.toString(),
         googleClientId: googleClientId,
       );

  @override
  Future<WebWidget> build(Session session, Request request) async {
    return widget;
  }
}

extension on ServerConfig {
  Uri get apiUrl => Uri(
    scheme: publicScheme,
    host: publicHost,
    port: publicPort,
  );
}
