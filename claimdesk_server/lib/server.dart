import 'dart:io';

import 'package:serverpod_cloud_storage/serverpod_cloud_storage.dart';

import 'src/authentication.dart';
import 'src/ai/providers.dart';
import 'src/jobs/job_worker.dart';
import 'src/jobs/handlers/caption_item_handler.dart';
import 'src/jobs/handlers/reembed_item_handler.dart';
import 'src/jobs/handlers/match_item_handler.dart';
import 'src/jobs/handlers/match_report_handler.dart';
import 'src/jobs/handlers/nightly_handler.dart';
import 'src/jobs/nightly.dart';
import 'src/cache_busting.dart';
import 'src/generated/serverpod.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';
import 'src/services/photo_upload_relay.dart';
import 'src/web/public/venue_page_route.dart';
import 'src/web/public/lost_form_route.dart';
import 'src/web/public/ticket_route.dart';
import 'src/web/public/ticket_answer_route.dart';
import 'src/web/public/ticket_photo_route.dart';
import 'src/web/middleware/rate_limit.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod. The generated Serverpod class is already connected
  // with your project's generated code.
  final pod = Serverpod(args);

  configureAuthentication(pod);
  final ipHashSalt = pod.getPassword('ipHashSalt') ?? '';
  if (ipHashSalt.length < 32) {
    throw StateError(
      'Configure a random ipHashSalt of at least 32 characters before starting public intake.',
    );
  }
  final trustProxy = pod.runMode == 'production';
  pod.webServer.addMiddleware(
    rateLimit(
      limit: 10,
      window: const Duration(minutes: 10),
      methods: {Method.post},
      trustProxy: trustProxy,
      salt: ipHashSalt,
    ),
    '/v',
  );
  pod.webServer.addMiddleware(
    rateLimit(
      limit: 60,
      window: const Duration(minutes: 10),
      methods: {Method.get},
      trustProxy: trustProxy,
      salt: ipHashSalt,
    ),
    '/v',
  );
  pod.webServer.addMiddleware(
    rateLimit(
      limit: 60,
      window: const Duration(minutes: 10),
      trustProxy: trustProxy,
      salt: ipHashSalt,
    ),
    '/t',
  );
  pod.webServer.addRoute(VenuePageRoute(), '/v/:slug');
  pod.webServer.addRoute(
    LostFormRoute(salt: ipHashSalt, trustProxy: trustProxy),
    '/v/:slug/lost',
  );
  pod.webServer.addRoute(TicketRoute(), '/t/:token');
  pod.webServer.addRoute(TicketAnswerRoute(), '/t/:token/answer');
  pod.webServer.addRoute(TicketPhotoRoute(), '/t/:token/photo');
  pod.webServer.addRoute(TicketJsonRoute(), '/t/:token/status.json');
  pod.webServer.addRoute(
    StaticRoute.file(File('web/static/robots.txt')),
    '/robots.txt',
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /web.
  // These are used by the default web page.
  pod.webServer.addRoute(
    StaticRoute.withCacheBusting(cacheBustingConfig),
    cacheBustingConfig.mountPrefix,
  );

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        appDir,
        // If building the Flutter app with WASM, set the below parameter to
        // true and add the --wasm flag to the flutter build command.
        enableWasmHeaders: false,
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    final defaultRoute = StaticRoute.file(
      File(
        Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
      ),
    );

    pod.webServer.addRoute(
      defaultRoute,
      '/app/**',
    );
  }

  // Configure cloud storage.
  // This setup works with Serverpod Cloud without extra configuration.
  // If you want to use a custom provider for cloud storage, replace these
  // with your preferred provider.
  final privateStorage = await ServerpodCloudProvider.private(
    fallback: () => DatabaseCloudStorage('private'),
  );
  pod.addCloudStorage(privateStorage);
  stdout.writeln('Private storage selected: ${privateStorage.runtimeType}');
  pod.addCloudStorage(
    await ServerpodCloudProvider.public(
      fallback: () => DatabaseCloudStorage('public'),
    ),
  );
  pod.experimental.registerStartHook(PhotoUploadRelay().register);

  // Start the server.
  await pod.start();
  await pod.withSession((session) => Nightly.schedule(session));
  Providers.configure(pod);
  JobWorker(
    pod,
    handlers: [
      CaptionItemHandler(),
      ReembedItemHandler(),
      MatchReportHandler(),
      MatchItemHandler(),
      NightlyHandler(),
    ],
    interval: Duration(seconds: Providers.config.workerIntervalSeconds),
    concurrency: Providers.config.workerConcurrency,
  ).start();
}
