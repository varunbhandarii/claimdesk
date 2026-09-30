import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'categories.dart';

class AttributeChips extends StatelessWidget {
  const AttributeChips({
    super.key,
    required this.attributes,
    this.restricted = false,
  });
  final ItemAttributes attributes;
  final bool restricted;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        categoryLabel(attributes.category),
        style: Theme.of(context).textTheme.titleLarge,
      ),
      Text(fineLabel(attributes.category)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final colour in attributes.colours) Chip(label: Text(colour)),
          if (attributes.brand != null) Chip(label: Text(attributes.brand!)),
          if (attributes.material != null)
            Chip(label: Text(attributes.material!)),
        ],
      ),
      if (attributes.description.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(attributes.description),
        ),
      for (final mark in attributes.marks) Text('• $mark'),
      if (restricted)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_outline),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Staff only — this item is never shown publicly.',
                    ),
                  ),
                ],
              ),
              for (final kind in attributes.personalDataKinds)
                Text(fineLabel(kind)),
            ],
          ),
        ),
    ],
  );
}
