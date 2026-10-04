import 'dart:typed_data';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/screens/release_screen.dart';
import 'package:claimdesk_flutter/ui/release_rules.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'Checklist disables return until ownership and ID are verified; optional signature stays empty',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ReleaseInput? sent;
      ByteData? signature;
      await tester.pumpWidget(
        MaterialApp(
          home: ReleaseScreen(
            item: item(),
            submit: (input, png) async {
              sent = input;
              signature = png;
              return ReleaseSummary(
                record: ReleaseRecord(
                  venueId: venueId,
                  itemId: itemId,
                  claimantName: input.claimantName,
                  idTypeSeen: input.idTypeSeen,
                  detailsMatched: input.detailsMatched,
                  describedBeforeViewing: true,
                  releasedByAuthUserId: venueId,
                ),
                releasedByName: 'Staff',
              );
            },
          ),
        ),
      );
      FilledButton button() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Mark as returned'),
      );
      expect(button().onPressed, isNull);
      expect(find.text('0 of 4 checks done'), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pump();
      await tester.tap(find.byTooltip('More details'));
      await tester.pump();
      await tester.tap(find.text('Passport'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('claimant-name')),
        'Demo Owner',
      );
      await tester.pump();
      expect(find.text('4 of 4 checks done'), findsOneWidget);
      expect(button().onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FilledButton, 'Mark as returned'));
      await tester.pumpAndSettle();
      expect(sent!.detailsMatched, 1);
      expect(sent!.idTypeSeen, 'passport');
      expect(signature, isNull);
      expect(find.text('Item returned'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'Restricted wallets require two details, exclude None and require third-party authorisation',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: ReleaseScreen(
            item: item(
              restricted: true,
            ).copyWith(attributes: attributes(category: 'wallet_or_purse')),
          ),
        ),
      );
      FilledButton button() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Mark as returned'),
      );
      expect(find.text('None'), findsNothing);
      await tester.tap(find.text('Student ID'));
      await tester.pump();
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.tap(find.byTooltip('More details'));
      await tester.pump();
      await tester.enterText(
        find.byKey(const Key('claimant-name')),
        'Demo Owner',
      );
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.tap(find.byTooltip('More details'));
      await tester.pump();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Someone else is collecting'),
      );
      await tester.pump();
      expect(button().onPressed, isNull);
      await tester.enterText(
        find.byKey(const Key('authorisation-note')),
        'Authorised in person by the owner',
      );
      await tester.pump();
      expect(button().onPressed, isNotNull);
      expect(find.text('ID number'), findsNothing);
    },
  );
  test(
    'Checklist mirror respects high-value and restricted identity requirements',
    () {
      expect(
        ReleaseRules.minimum(
          item().copyWith(valueBand: ValueBand.from100to499),
        ),
        2,
      );
      expect(
        ReleaseRules.allowsNoId(
          item().copyWith(valueBand: ValueBand.from20to99),
        ),
        isFalse,
      );
      expect(ReleaseRules.allowsNoId(item(restricted: true)), isFalse);
    },
  );
}
