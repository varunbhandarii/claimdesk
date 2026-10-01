import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:claimdesk_server/src/ai/provider_types.dart';
import 'package:claimdesk_server/src/ai/claude_normaliser.dart';
import 'package:claimdesk_server/src/ai/text_template.dart';
import 'package:claimdesk_server/src/generated/protocol.dart';
import 'package:claimdesk_server/src/matching/candidate_query.dart';
import 'package:claimdesk_server/src/matching/in_memory_candidates.dart';
import 'package:claimdesk_server/src/matching/scorer.dart';
import 'package:claimdesk_server/src/services/seed_service.dart';
import 'package:serverpod/serverpod.dart';
import 'metrics.dart';

class EvalHarness {
  EvalHarness({
    required this.embedder,
    required this.normaliser,
    this.cache,
    DateTime? now,
  }) : now = now ?? DateTime.now().toUtc();
  final TextEmbedder embedder;
  final ReportNormaliser normaliser;
  final Directory? cache;
  final DateTime now;
  late List<FoundItem> items;
  late List<LostReport> reports;
  late List<Zone> zones;
  final itemKeys = <UuidValue, String>{};
  final reportKeys = <UuidValue, String>{};
  final expected = <UuidValue, String?>{};
  final Map<String, dynamic> fixture =
      jsonDecode(
            File('test/fixtures/matching/synthetic_v1.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  Future<Object> _cached(
    String identity,
    Future<Object> Function() create,
  ) async {
    if (cache == null) return create();
    await cache!.create(recursive: true);
    final name = sha256.convert(utf8.encode(identity)).toString();
    final file = File('${cache!.path}/$name.json');
    if (await file.exists()) return jsonDecode(await file.readAsString());
    final value = await create();
    await file.writeAsString(jsonEncode(value));
    return value;
  }

  Future<Vector> _embed(String text, bool query) async {
    final result = await _cached(
      '${embedder.modelId}:$query:$text',
      () async =>
          query ? embedder.embedQuery(text) : embedder.embedDocument(text),
    );
    final values = (result as List).map((v) => (v as num).toDouble()).toList();
    final norm = sqrt(values.fold<double>(0, (n, v) => n + v * v));
    if (values.length != 1536 ||
        values.any((v) => !v.isFinite) ||
        (norm - 1).abs() > 1e-5) {
      throw StateError(
        'Evaluation vector must be finite, 1536-dimensional and unit length',
      );
    }
    return Vector(values);
  }

  Future<void> seed(Session s) async {
    final venue = await Venue.db.insertRow(
      s,
      Venue(name: 'Evaluation desk', slug: 'eval-${const Uuid().v4()}'),
    );
    final venueId = venue.id!;
    zones = await Zone.db.insert(s, [
      for (final name in SeedService.zoneNames)
        Zone(venueId: venueId, name: name, adjacentZoneIds: []),
    ]);
    final byZone = {for (final z in zones) z.name: z};
    const adjacency = {
      'Front desk': ['Gym floor', 'Locker rooms'],
      'Gym floor': ['Front desk'],
      'Pool deck': ['Locker rooms'],
      'Locker rooms': ['Front desk', 'Pool deck'],
    };
    zones = await Zone.db.update(s, [
      for (final z in zones)
        z.copyWith(
          adjacentZoneIds: [
            for (final name in adjacency[z.name] ?? <String>[])
              byZone[name]!.id!,
          ],
        ),
    ]);
    items = [];
    for (final raw in fixture['items'] as List) {
      final attrs = protectAttributes(
        ItemAttributes.fromJson(raw['attributes'] as Map<String, dynamic>),
      );
      final text = TextTemplate.render(attrs);
      final item = await FoundItem.db.insertRow(
        s,
        FoundItem(
          venueId: venueId,
          zoneId: byZone[raw['zone']]!.id,
          status: ItemStatus.unclaimed,
          refCode: 'EV${items.length.toString().padLeft(4, '0')}',
          attributes: attrs,
          restricted: restrictedAttributes(attrs),
          captionText: text,
          embedding: await _embed(text, false),
          embeddingModel: embedder.modelId,
          foundAt: now.subtract(Duration(days: raw['foundAtDaysAgo'] as int)),
          loggedByAuthUserId: venueId,
        ),
      );
      items.add(item);
      itemKeys[item.id!] = raw['key'] as String;
    }
    reports = [];
    for (final raw in fixture['reports'] as List) {
      final hints = ReportHints(
        categoryHint: raw['categoryHint'] as String?,
        colourHints: (raw['colourHints'] as List).cast<String>(),
        brandHint: raw['brandHint'] as String?,
        zoneName: raw['zone'] as String?,
        whereText: raw['whereText'] as String?,
      );
      final model = normaliser is ClaudeNormaliser
          ? '${(normaliser as ClaudeNormaliser).model}:${(normaliser as ClaudeNormaliser).effort ?? 'default'}'
          : normaliser.id;
      final identity = '$model:normalise_v1:${jsonEncode(raw)}';
      final result = await _cached(identity, () async {
        final normalized = await normaliser.normalise(
          raw['rawText'] as String,
          hints,
        );
        if (normalized.attributes == null) {
          throw StateError(
            'Evaluation normaliser failed: ${normalized.outcome}',
          );
        }
        return protectAttributes(normalized.attributes!).toJson();
      });
      final attrs = protectAttributes(
        ItemAttributes.fromJson((result as Map).cast<String, dynamic>()),
      );
      var report = LostReport(
        venueId: venueId,
        refCode: 'ER${reports.length.toString().padLeft(4, '0')}',
        publicToken: 'evaluation-$venueId-${reports.length}',
        status: ReportStatus.searching,
        rawText: raw['rawText'] as String,
        categoryHint: hints.categoryHint,
        colourHints: hints.colourHints,
        brandHint: hints.brandHint,
        zoneId: byZone[raw['zone']]?.id,
        whereText: hints.whereText,
        lostAt: raw['lostAtDaysAgo'] == null
            ? null
            : now.subtract(Duration(days: raw['lostAtDaysAgo'] as int)),
        lostAtFuzzyDays: raw['fuzzyDays'] as int,
        attributes: attrs,
        createdAt: now,
      );
      report = report.copyWith(
        embedding: await _embed(TextTemplate.render(attrs), true),
        embeddingModel: embedder.modelId,
      );
      report = await LostReport.db.insertRow(s, report);
      reports.add(report);
      reportKeys[report.id!] = raw['key'] as String;
      expected[report.id!] = raw['expectedItem'] as String?;
    }
  }

  Future<
    ({
      List<EvalRanking> rankings,
      List<String> differences,
      String cosineDistribution,
    })
  >
  run(Session s) async {
    final rankings = <EvalRanking>[], differences = <String>[];
    final trueCos = <double>[], falseCos = <double>[];
    for (final report in reports) {
      final sql = await CandidateQuery(now: () => now).forReport(s, report);
      final reference = InMemoryCandidates(
        now: () => now,
      ).forReport(report, items, zones);
      final sqlIds = sql.map((c) => c.item.id).toSet(),
          referenceIds = reference.map((c) => c.item.id).toSet();
      if (sqlIds.length != referenceIds.length ||
          !sqlIds.containsAll(referenceIds)) {
        differences.add(
          '${reportKeys[report.id]} SQL-only=${sqlIds.difference(referenceIds).map((id) => itemKeys[id]).toList()} reference-only=${referenceIds.difference(sqlIds).map((id) => itemKeys[id]).toList()}',
        );
      }
      for (final c in sql) {
        if (c.cosSim != null) {
          (itemKeys[c.item.id] == expected[report.id] ? trueCos : falseCos).add(
            c.cosSim!,
          );
        }
      }
      final rows = Scorer.kept(sql.map(const Scorer().score));
      rankings.add((
        reportKey: reportKeys[report.id]!,
        expectedItem: expected[report.id],
        rows: [
          for (final r in rows)
            (itemKey: itemKeys[r.candidate.item.id]!, result: r),
        ],
      ));
    }
    String distribution(List<double> values) {
      values.sort();
      if (values.isEmpty) return 'none';
      double percentile(double p) => values[((values.length - 1) * p).round()];
      return 'n=${values.length} min=${values.first.toStringAsFixed(3)} p10=${percentile(.1).toStringAsFixed(3)} median=${percentile(.5).toStringAsFixed(3)} p90=${percentile(.9).toStringAsFixed(3)} max=${values.last.toStringAsFixed(3)}';
    }

    return (
      rankings: rankings,
      differences: differences,
      cosineDistribution:
          'True pairs: ${distribution(trueCos)}\nFalse pairs: ${distribution(falseCos)}',
    );
  }
}
