import 'package:flutter/material.dart';
import 'desk_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: c.warn50,
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(
          children: [
            Icon(Icons.wifi_off, size: 20, color: c.warn),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connection lost. Reconnecting… Your loaded items are still available.',
                style: context.type.body.copyWith(fontSize: 13.5, color: c.ink),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
