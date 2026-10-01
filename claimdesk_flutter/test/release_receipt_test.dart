import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/release_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'Staff receipt identifies the collector and authorisation, with signature viewing only on item detail',
    (tester) async {
      final summary = ReleaseSummary(
        record: ReleaseRecord(
          venueId: venueId,
          itemId: itemId,
          claimantName: 'Demo Collector',
          idTypeSeen: 'passport',
          detailsMatched: 2,
          describedBeforeViewing: true,
          releasedByAuthUserId: venueId,
          thirdPartyAuthorisationNote: 'Approved in person',
          signaturePath: 'private-signature',
        ),
        releasedByName: 'Demo Staff',
        reportRefCode: 'REPORT1',
      );
      for (final signature in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReleaseReceipt(summary: summary, showSignature: signature),
            ),
          ),
        );
        expect(find.text('Claimant: Demo Collector'), findsOneWidget);
        expect(find.text('ID type seen: Passport'), findsOneWidget);
        expect(find.text('Released by: Demo Staff'), findsOneWidget);
        expect(find.text('Authorisation: Approved in person'), findsOneWidget);
        expect(
          find.text('View signature'),
          signature ? findsOneWidget : findsNothing,
        );
      }
    },
  );
}
