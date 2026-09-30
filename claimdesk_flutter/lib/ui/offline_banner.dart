import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => MaterialBanner(
    content: const Text(
      'Connection lost. Reconnecting… Your loaded items are still available.',
    ),
    leading: const Icon(Icons.wifi_off),
    actions: [TextButton(onPressed: onRetry, child: const Text('Retry'))],
  );
}
