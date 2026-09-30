import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:claimdesk_flutter/ui/item_form.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'intake requires zone, allows colour selection and defaults to under twenty',
    (tester) async {
      final form = ItemFormController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Column(
                  children: [
                    ItemForm(
                      controller: form,
                      zones: [
                        Zone(
                          id: venueId,
                          venueId: venueId,
                          name: 'Pool',
                          adjacentZoneIds: [],
                        ),
                      ],
                      onChanged: () => setState(() {}),
                    ),
                    FilledButton(
                      key: const Key('save'),
                      onPressed: form.zoneId == null ? null : () {},
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('save'))).onPressed,
        isNull,
      );
      expect(form.valueBand, ValueBand.under20);
      await tester.tap(find.byType(DropdownButtonFormField<UuidValue>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pool').last);
      await tester.pumpAndSettle();
      expect(form.zoneId, venueId);
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('save'))).onPressed,
        isNotNull,
      );
      await tester.ensureVisible(find.text('black'));
      await tester.tap(find.text('black'));
      await tester.pump();
      expect(form.colours, contains('black'));
      await tester.tap(find.text('black'));
      await tester.pump();
      expect(form.colours, isEmpty);
      for (final colour in ['black', 'white', 'red']) {
        await tester.ensureVisible(find.text(colour));
        await tester.tap(find.text(colour));
        await tester.pump();
      }
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'blue'))
            .onSelected,
        isNull,
      );
      await tester.ensureVisible(find.text('red'));
      await tester.tap(find.text('red'));
      await tester.pump();
      expect(
        tester
            .widget<FilterChip>(find.widgetWithText(FilterChip, 'blue'))
            .onSelected,
        isNotNull,
      );
      await tester.pumpWidget(const SizedBox());
      form.dispose();
    },
  );
  test(
    'upload proof and expiry pass through unchanged; edits clear emptied fields',
    () {
      final form = ItemFormController(rememberedZone: venueId);
      final expiry = DateTime.utc(2026, 10, 1);
      final ticket = PhotoUploadTicket(
        itemId: itemId,
        path: 'venues/photo.jpg',
        uploadDescription: 'ticket',
        expiresAt: expiry,
        proof: 'signed-proof',
      );
      final input = form.buildInput(ticket: ticket);
      expect(input.itemId, itemId);
      expect(input.photoPath, ticket.path);
      expect(input.uploadProof, ticket.proof);
      expect(input.uploadExpiresAt, expiry);
      expect(input.zoneId, venueId);
      expect(input.valueBand, ValueBand.under20);
      form.zoneId = null;
      form.description.text = 'A black umbrella';
      final patch = form.buildPatch(item());
      expect(patch.clearZone, true);
      expect(patch.clearPrivateNotes, true);
      expect(patch.clearStorageBin, true);
      form.dispose();
    },
  );
  test(
    'edit validation explains empty descriptions and excessive words or marks',
    () {
      final form = ItemFormController();
      expect(
        () => form.buildPatch(item()),
        throwsA(predicate((e) => e.toString().contains('Add a description'))),
      );
      form.description.text = List.filled(61, 'word').join(' ');
      expect(
        () => form.buildInput(),
        throwsA(predicate((e) => e.toString().contains('60 words'))),
      );
      form.description.text = 'An umbrella';
      form.marks.text = List.filled(6, 'mark').join('\n');
      expect(
        () => form.buildPatch(item()),
        throwsA(predicate((e) => e.toString().contains('five marks'))),
      );
      form.dispose();
    },
  );
}
