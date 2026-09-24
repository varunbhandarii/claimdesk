import 'dart:io';
import 'package:serverpod/serverpod.dart';
import '../config/app_config.dart';
import 'claude_captioner.dart';
import 'gemini_embedder.dart';
import 'fakes.dart';
import 'provider_types.dart';
import 'template_captioner.dart';
export 'provider_types.dart';

class Providers {
  static ItemCaptioner captioner = ChainCaptioner(FakeCaptioner());
  static TextEmbedder embedder = FakeEmbedder();
  static AppConfig config = const AppConfig();
  static void configure(Serverpod pod) {
    config = AppConfig.load(pod);
    final real = pod.runMode != ServerpodRunMode.test;
    captioner = ChainCaptioner(
      real && (config.anthropicApiKey?.isNotEmpty ?? false)
          ? ClaudeCaptioner(
              apiKey: config.anthropicApiKey!,
              model: config.captionModel,
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
