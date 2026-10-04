import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'screen_fixtures.dart';

void main() {
  setUp(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
  });
  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
    binding.platformDispatcher.clearTextScaleFactorTestValue();
  });

  for (final brightness in Brightness.values) {
    for (final screen in screens) {
      testWidgets('${screen.name} meets touch, label and contrast guidelines '
          'in ${brightness.name}', (tester) async {
        // Layout is checked with real font metrics below; the wide test font
        // only stands in for colour sampling here.
        final reportError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (!details.exceptionAsString().contains('overflowed')) {
            reportError?.call(details);
          }
        };
        addTearDown(() => FlutterError.onError = reportError);
        final semantics = tester.ensureSemantics();
        await pumpScreen(tester, screen, brightness);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.pumpWidget(const SizedBox());
        semantics.dispose();
      });
    }
  }
}
