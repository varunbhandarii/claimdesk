import 'dart:io';
import 'package:serverpod/serverpod.dart';

class AppConfig {
  const AppConfig({
    this.captionModel = 'claude-opus-5-5',
    this.captionPromptVersion = 'caption_v1',
    String? normaliseModel,
    this.embeddingModel = 'gemini-embedding-2',
    this.workerIntervalSeconds = 3,
    this.workerConcurrency = 3,
    this.captionEffort = 'low',
    this.anthropicApiKey,
    this.geminiApiKey,
  }) : normaliseModel = normaliseModel ?? captionModel;
  final String normaliseModel;
  final String captionModel, captionPromptVersion, embeddingModel;
  final int workerIntervalSeconds;
  final int workerConcurrency;
  final String captionEffort;
  static int concurrencyFromEnvironment(Map<String, String> env) =>
      (int.tryParse(env['CLAIMDESK_WORKER_CONCURRENCY'] ?? '3') ?? 3).clamp(
        1,
        5,
      );
  static String effortFromEnvironment(Map<String, String> env) {
    final effort = env['CLAIMDESK_CAPTION_EFFORT'] ?? 'low';
    return {'', 'low', 'medium', 'high'}.contains(effort) ? effort : 'low';
  }

  int get embeddingDimensions => 1536;
  final String? anthropicApiKey, geminiApiKey;
  static AppConfig load(Serverpod pod) {
    final env = Platform.environment;
    final interval = int.tryParse(env['CLAIMDESK_WORKER_INTERVAL'] ?? '3') ?? 3;
    return AppConfig(
      captionModel: env['CLAIMDESK_CAPTION_MODEL'] ?? 'claude-opus-5-5',
      captionPromptVersion: env['CLAIMDESK_CAPTION_PROMPT'] ?? 'caption_v1',
      normaliseModel: env['CLAIMDESK_NORMALISE_MODEL'],
      embeddingModel: env['CLAIMDESK_EMBEDDING_MODEL'] ?? 'gemini-embedding-2',
      workerIntervalSeconds: interval.clamp(3, 60),
      workerConcurrency: concurrencyFromEnvironment(env),
      captionEffort: effortFromEnvironment(env),
      anthropicApiKey:
          pod.getPassword('anthropicApiKey') ?? env['ANTHROPIC_API_KEY'],
      geminiApiKey: pod.getPassword('geminiApiKey') ?? env['GEMINI_API_KEY'],
    );
  }
}
