import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalLink(String value) => launchUrl(
  Uri.parse(value),
  mode: LaunchMode.externalApplication,
  webOnlyWindowName: '_blank',
);
