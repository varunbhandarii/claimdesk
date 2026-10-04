import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'screen_fixtures.dart';

/// Layout at 100% and 200% text with real font metrics. Kept apart from the
/// guideline checks, which need the default test font loaded alone.
void main() {
  setUpAll(loadRoboto);
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

  for (final scale in [1.0, 2.0]) {
    for (final screen in screens) {
      testWidgets('${screen.name} lays out at ${(scale * 100).round()}% text', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await pumpScreen(tester, screen, Brightness.light, fonts: roboto);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
