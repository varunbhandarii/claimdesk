import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../config/app_config.dart';
import 'claude_captioner.dart';
import 'claude_normaliser.dart';
import 'report_normaliser.dart';
import 'gemini_embedder.dart';
import 'fakes.dart';
import 'provider_types.dart';
import 'template_captioner.dart';
export 'provider_types.dart';

class Providers {
  static ItemCaptioner captioner = ChainCaptioner(FakeCaptioner());
  static TextEmbedder embedder = FakeEmbedder();
  static ReportNormaliser normaliser = HintNormaliser();
  static AppConfig config = const AppConfig();
  static void configure(Serverpod pod) {
    config = AppConfig.load(pod);
    final real = pod.runMode != ServerpodRunMode.test;
    normaliser = real && (config.anthropicApiKey?.isNotEmpty ?? false)
        ? ChainNormaliser(
            ClaudeNormaliser(
              apiKey: config.anthropicApiKey!,
              model: config.normaliseModel,
            ),
          )
        : HintNormaliser();
    captioner = ChainCaptioner(
      real && (config.anthropicApiKey?.isNotEmpty ?? false)
          ? ClaudeCaptioner(
              apiKey: config.anthropicApiKey!,
              model: config.captionModel,
              effort: config.captionEffort,
            )
          : FakeCaptioner(),
    );
    embedder = real && (config.geminiApiKey?.isNotEmpty ?? false)
        ? GeminiEmbedder(
            apiKey: config.geminiApiKey!,
            model: config.embeddingModel,
          )
        : FakeEmbedder();
    stdout.writeln(
      'Providers selected: caption=${captioner.id}, embedding=${embedder.modelId}',
    );
  }
}
