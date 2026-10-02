import 'package:claimdesk_server/src/config/app_config.dart';
import 'package:test/test.dart';

void main() {
  test(
    'worker slots default to three and clamp malformed/extreme settings',
    () {
      expect(AppConfig.concurrencyFromEnvironment({}), 3);
      for (final entry in {'bad': 3, '0': 1, '1': 1, '3': 3, '99': 5}.entries) {
        expect(
          AppConfig.concurrencyFromEnvironment({
            'CLAIMDESK_WORKER_CONCURRENCY': entry.key,
          }),
          entry.value,
        );
      }
    },
  );
  test(
    'caption effort defaults low and accepts omission and supported levels',
    () {
      expect(AppConfig.effortFromEnvironment({}), 'low');
      for (final effort in ['', 'low', 'medium', 'high']) {
        expect(
          AppConfig.effortFromEnvironment({
            'CLAIMDESK_CAPTION_EFFORT': effort,
          }),
          effort,
        );
      }
      expect(
        AppConfig.effortFromEnvironment({
          'CLAIMDESK_CAPTION_EFFORT': 'max',
        }),
        'low',
      );
    },
  );
}
