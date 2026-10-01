import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';

Future<String?> askDismissReason(
  BuildContext context, {
  bool undo = false,
}) async {
  final controller = TextEditingController();
  final form = GlobalKey<FormState>();
  final result = await showDialog<String>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(undo ? 'Undo this confirmation?' : 'Dismiss this match?'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason'),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Give a reason.' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialog),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) {
              Navigator.pop(dialog, controller.text.trim());
            }
          },
          child: Text(undo ? 'Undo confirmation' : 'Dismiss'),
        ),
      ],
    ),
  );
  // The dialog may still be animating out while its field is mounted.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  controller.dispose();
  return result;
}

class MatchActions extends StatefulWidget {
  const MatchActions({super.key, required this.match, this.onChanged});
  final ItemMatch match;
  final VoidCallback? onChanged;
  @override
  State<MatchActions> createState() => _MatchActionsState();
}

class _MatchActionsState extends State<MatchActions> {
  bool _busy = false;
  Future<void> _act(bool confirm) async {
    final session = VenueScope.of(context);
    String? reason;
    if (!confirm) {
      reason = await askDismissReason(
        context,
        undo: widget.match.state == MatchState.confirmed,
      );
      if (reason == null || !mounted) return;
    }
    setState(() => _busy = true);
    final result = await runGuarded(
      context,
      () => confirm
          ? session.client.match.confirm(widget.match.id!)
          : session.client.match.reject(widget.match.id!, reason!),
      onDenied: session.onDenied,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirm ? 'Match confirmed.' : 'Match dismissed.'),
        ),
      );
      session.scheduleRefresh();
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      if (widget.match.state == MatchState.pending)
        FilledButton(
          onPressed: _busy ? null : () => _act(true),
          child: const Text('Confirm'),
        ),
      if ({
        MatchState.pending,
        MatchState.confirmed,
      }.contains(widget.match.state))
        OutlinedButton(
          onPressed: _busy ? null : () => _act(false),
          child: Text(
            widget.match.state == MatchState.confirmed
                ? 'Undo confirmation'
                : 'Dismiss',
          ),
        ),
      if (_busy)
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
    ],
  );
}
