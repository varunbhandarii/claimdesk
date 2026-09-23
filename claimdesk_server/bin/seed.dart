import 'dart:io';

import 'package:claimdesk_server/src/authentication.dart';
import 'package:claimdesk_server/src/generated/serverpod.dart';
import 'package:claimdesk_server/src/services/seed_service.dart';

Future<void> main(List<String> args) async {
  final pod = Serverpod(args);
  configureAuthentication(pod);
  try {
    await pod.start();
    final result = await pod.withSession(SeedService.seedDemo);
    stdout.writeln('Demo venue ready: ${result.venueId}');
  } catch (_) {
    stderr.writeln('Demo seeding failed. Check server configuration and logs.');
    exitCode = 1;
  } finally {
    await pod.shutdown(exitProcess: false);
  }
}
