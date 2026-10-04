import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:claimdesk_flutter/ui/export_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'fixtures.dart';

void main() {
  testWidgets(
    'supervisor role controls menu availability and all five kinds are offered',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      final staff = StaffMembership(
        authUserId: venueId,
        venueId: venueId,
        displayName: 'Staff',
      );
      expect(canExport(staff), false);
      expect(canExport(staff.copyWith(role: StaffRole.supervisor)), true);
      final opened = <String>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExportSheet(
                export: (kind) async => ExportResult(
                  url: 'https://example.test/download',
                  rows: 12,
                  expiresAt: DateTime.now().add(const Duration(minutes: 10)),
                  kind: kind,
                ),
                open: (url) async {
                  opened.add(url);
                  return true;
                },
              ),
            ),
          ),
        ),
      );
      for (final label in [
        'Items',
        'Reports',
        'Matches',
        'Releases',
        'Custody',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      await tester.ensureVisible(find.text('Create CSV'));
      await tester.tap(find.text('Create CSV'));
      await tester.pumpAndSettle();
      expect(find.text('12 rows · Link valid for 10 minutes'), findsOneWidget);
      await tester.ensureVisible(find.text('Open CSV'));
      await tester.tap(find.text('Open CSV'));
      await tester.pumpAndSettle();
      expect(opened, ['https://example.test/download']);
      await tester.ensureVisible(find.text('Copy download link'));
      await tester.tap(find.text('Copy download link'));
      await tester.pumpAndSettle();
      expect(
        copied,
        'https://example.test/download',
      );
    },
  );
}
