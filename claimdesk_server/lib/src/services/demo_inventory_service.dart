import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../ai/providers.dart';
import '../ai/text_template.dart';
import '../generated/protocol.dart';
import '../matching/scorer.dart';
import '../seed/demo_inventory.dart';
import '../web/public/report_form_input.dart';
import 'child_records.dart';
import 'public_codes.dart';
import 'public_intake_service.dart';
import 'seed_service.dart';

class DemoInventoryService {
  static Map<String, dynamic> _fixture() =>
      jsonDecode(demoInventoryJson) as Map<String, dynamic>;
  static Future<int> items(Session s) async {
    final demo = await SeedService.seedDemo(s);
    final zones = await Zone.db.find(
      s,
      where: (t) => t.venueId.equals(demo.venueId),
    );
    final byName = {for (final z in zones) z.name: z.id!};
    final now = DateTime.now().toUtc();
    final created = await s.db.transaction((tx) async {
      await Venue.db.findById(
        s,
        demo.venueId,
        transaction: tx,
        lockMode: LockMode.forUpdate,
      );
      final rows = <FoundItem>[];
      final inputs = _fixture()['items'] as List;
      for (var i = 0; i < inputs.length; i++) {
        final ref = 'SEED${(i + 1).toString().padLeft(2, '0')}';
        if (await FoundItem.db.findFirstRow(
              s,
              where: (t) =>
                  t.venueId.equals(demo.venueId) & t.refCode.equals(ref),
              transaction: tx,
            ) !=
            null) {
          continue;
        }
        final raw = inputs[i];
        final attributes = protectAttributes(
          ItemAttributes.fromJson(
            (raw['attributes'] as Map).cast<String, dynamic>(),
          ),
        );
        final item = await FoundItem.db.insertRow(
          s,
          FoundItem(
            venueId: demo.venueId,
            refCode: ref,
            status: ItemStatus.captioning,
            attributes: attributes,
            restricted: restrictedAttributes(attributes),
            zoneId: byName[raw['zone']],
            storageBin: 'Demo shelf ${(i ~/ 10) + 1}',
            foundAt: now.subtract(Duration(days: raw['foundAtDaysAgo'] as int)),
            loggedByAuthUserId: demo.staffId,
          ),
          transaction: tx,
        );
        await AuditEvent.db.insertRow(
          s,
          AuditEvent(
            venueId: demo.venueId,
            entityType: 'item',
            entityId: item.id!,
            action: 'created',
            actorAuthUserId: demo.staffId,
            payload: AuditPayload(
              summary: 'Demo found item recorded',
              toState: 'captioning',
              data: {'refCode': ref},
            ),
          ),
          transaction: tx,
        );
        await ChildRecords.itemWork(
          s,
          itemId: item.id!,
          kind: 'caption_item',
          identifier: 'caption_${item.id}',
          data: {'promptVersion': Providers.config.captionPromptVersion},
          maxAttempts: 2,
          transaction: tx,
        );
        rows.add(item);
      }
      return rows;
    });
    for (final item in created) {
      await s.messages.postMessage(
        'venue_${demo.venueId}',
        DeskEvent(
          kind: 'itemCreated',
          venueId: demo.venueId,
          itemId: item.id!,
          at: item.createdAt,
        ),
      );
    }
    return created.length;
  }

  static Future<int> reports(Session s) async {
    final demo = await SeedService.seedDemo(s);
    final venue = (await Venue.db.findById(s, demo.venueId))!;
    final zones = await Zone.db.find(
      s,
      where: (t) => t.venueId.equals(demo.venueId),
    );
    final byName = {for (final z in zones) z.name: z.id!};
    final inputs = _fixture()['reports'] as List;
    var created = 0;
    final now = DateTime.now().toUtc();
    for (var i = 0; i < inputs.length; i++) {
      final ref = 'SEEDR${i + 1}';
      if (await LostReport.db.findFirstRow(
            s,
            where: (t) =>
                t.venueId.equals(demo.venueId) & t.refCode.equals(ref),
          ) !=
          null) {
        continue;
      }
      final raw = inputs[i];
      final result = await PublicIntakeService(codes: _SeedCodes(ref)).submit(
        s,
        venue,
        ReportFormInput(
          rawText: raw['rawText'] as String,
          categoryHint: raw['categoryHint'] as String?,
          colourHints: (raw['colourHints'] as List).cast<String>(),
          brandHint: raw['brandHint'] as String?,
          zoneId: byName[raw['zone']]?.toString(),
          whereText: raw['whereText'] as String?,
          lostAt: raw['lostAtDaysAgo'] == null
              ? now
              : now.subtract(Duration(days: raw['lostAtDaysAgo'] as int)),
          lostAtFuzzyDays: raw['fuzzyDays'] as int,
          contactEmail: 'seed-${i + 1}@example.test',
        ),
        PublicCodes.ipHash(
          s.passwords['ipHashSalt'] ??
              'synthetic-demo-salt-with-thirty-two-characters',
          'synthetic-demo',
        ),
      );
      if (!result.duplicate) created++;
    }
    return created + await _lifecycle(s, demo.venueId, demo.staffId);
  }

  // Dedicated terminal examples preserve the reviewed, open matching examples.
  static Future<int> _lifecycle(
    Session s,
    UuidValue venueId,
    UuidValue staffId,
  ) => s.db.transaction((tx) async {
    await Venue.db.findById(
      s,
      venueId,
      transaction: tx,
      lockMode: LockMode.forUpdate,
    );
    final now = DateTime.now().toUtc();
    final attributes = ItemAttributes(
      category: 'water_bottle_or_flask',
      colours: ['blue'],
      marks: ['small dent in the base'],
      description: 'Blue reusable bottle with a small dent in the base',
      personalDataKinds: [],
      keywords: ['blue', 'bottle', 'dent'],
      source: 'demo',
    );
    if (await FoundItem.db.findFirstRow(
          s,
          where: (t) => t.venueId.equals(venueId) & t.refCode.equals('DEMOEX'),
          transaction: tx,
        ) ==
        null) {
      final item = await FoundItem.db.insertRow(
        s,
        FoundItem(
          venueId: venueId,
          refCode: 'DEMOEX',
          status: ItemStatus.expired,
          attributes: attributes,
          captionText: attributes.description,
          foundAt: now.subtract(const Duration(days: 15)),
          holdUntil: now.subtract(const Duration(days: 1)),
          storageBin: 'Demo expired shelf',
          loggedByAuthUserId: staffId,
        ),
        transaction: tx,
      );
      await AuditEvent.db.insertRow(
        s,
        AuditEvent(
          venueId: venueId,
          entityType: 'item',
          entityId: item.id!,
          action: 'expired',
          actorAuthUserId: staffId,
          payload: AuditPayload(
            summary: 'Fictional expired demo item',
            toState: 'expired',
            data: {},
          ),
        ),
        transaction: tx,
      );
    }
    if (await LostReport.db.findFirstRow(
          s,
          where: (t) => t.venueId.equals(venueId) & t.refCode.equals('DEMORT'),
          transaction: tx,
        ) !=
        null) {
      return 0;
    }
    final item = await FoundItem.db.insertRow(
      s,
      FoundItem(
        venueId: venueId,
        refCode: 'DEMORE',
        status: ItemStatus.claimed,
        attributes: attributes,
        captionText: attributes.description,
        foundAt: now.subtract(const Duration(days: 2)),
        holdUntil: now.add(const Duration(days: 12)),
        storageBin: 'Demo returned shelf',
        loggedByAuthUserId: staffId,
      ),
      transaction: tx,
    );
    final report = await LostReport.db.insertRow(
      s,
      LostReport(
        venueId: venueId,
        refCode: 'DEMORT',
        publicToken: PublicCodes().token(),
        rawText: 'A blue reusable bottle with a small dent in its base',
        colourHints: ['blue'],
        categoryHint: attributes.category,
        attributes: attributes,
        status: ReportStatus.returned,
        createdAt: now.subtract(const Duration(days: 2)),
        closedAt: now,
      ),
      transaction: tx,
    );
    await ItemMatch.db.insertRow(
      s,
      ItemMatch(
        venueId: venueId,
        itemId: item.id!,
        reportId: report.id!,
        state: MatchState.confirmed,
        score: .6,
        label: 'possible',
        rank: 1,
        explanation: MatchExplanation(
          matchedKeywords: ['blue', 'bottle', 'dent'],
          weightsHash: const Scorer().weights.hash,
        ),
        algorithmVersion: Scorer.algorithmVersion,
        decidedByAuthUserId: staffId,
        decidedAt: now,
      ),
      transaction: tx,
    );
    await ChildRecords.release(
      s,
      itemId: item.id!,
      reportId: report.id,
      claimantName: 'Fictional Demo Owner',
      idTypeSeen: 'none',
      detailsMatched: 1,
      describedBeforeViewing: true,
      releasedByAuthUserId: staffId,
      transaction: tx,
    );
    for (final parent in [
      ('item', item.id!, 'released', 'claimed'),
      ('report', report.id!, 'returned', 'returned'),
    ]) {
      await AuditEvent.db.insertRow(
        s,
        AuditEvent(
          venueId: venueId,
          entityType: parent.$1,
          entityId: parent.$2,
          action: parent.$3,
          actorAuthUserId: staffId,
          payload: AuditPayload(
            summary: 'Fictional demo return',
            toState: parent.$4,
            data: {},
          ),
        ),
        transaction: tx,
      );
    }
    return 1;
  });
}

class _SeedCodes extends PublicCodes {
  _SeedCodes(this.ref);
  final String ref;
  @override
  String reference() => ref;
}
