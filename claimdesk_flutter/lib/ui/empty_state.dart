import 'package:flutter/material.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.onLog});
  final VoidCallback onLog;
  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        children: [
          ExcludeSemantics(
            child: Transform.rotate(
              angle: -.12,
              child: Container(
                width: 132,
                height: 64,
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: TagShape(
                    point: 22,
                    radius: 12,
                    side: BorderSide(color: c.lineStrong, width: 2),
                  ),
                ),
                alignment: const Alignment(-.55, 0),
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: c.lineStrong, width: 2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('A clear shelf', style: context.type.headingAt(26)),
          const SizedBox(height: 10),
          Text(
            'No items match this view. Log something found to give it a place at the desk.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.ink2),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: tagButtonStyle(context),
            onPressed: onLog,
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Log item'),
          ),
        ],
      ),
    );
  }
}
