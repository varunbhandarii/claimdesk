import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../ai/providers.dart';
import '../ai/text_template.dart';
import '../generated/protocol.dart';
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
    return created;
  }
}

class _SeedCodes extends PublicCodes {
  _SeedCodes(this.ref);
  final String ref;
  @override
  String reference() => ref;
}
