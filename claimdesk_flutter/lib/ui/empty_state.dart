import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onLog});
  final VoidCallback onLog;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      children: [
        const SizedBox(height: 48),
        const Icon(Icons.inventory_2_outlined, size: 64),
        const SizedBox(height: 24),
        Text(
          'A clear shelf',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        const Text(
          'No items match this view. Log something found to give it a place at the desk.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onLog,
          icon: const Icon(Icons.add),
          label: const Text('Log item'),
        ),
      ],
    ),
  );
}
