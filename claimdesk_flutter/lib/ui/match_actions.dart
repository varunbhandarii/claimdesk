import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import 'desk_theme.dart';
import 'format.dart';

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
          decoration: const InputDecoration(
            labelText: 'Reason',
            helperText: 'Staff only. Saved in the match history.',
          ),
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

/// Decision buttons for a proposal. The bar layout offers every next step;
/// the inbox layout offers Dismiss and a way into the full review.
class MatchActions extends StatefulWidget {
  const MatchActions({
    super.key,
    required this.match,
    this.onChanged,
    this.reportStatus,
    this.onRelease,
    this.releasedAt,
    this.onReview,
  });
  final ItemMatch match;
  final VoidCallback? onChanged;
  final ReportStatus? reportStatus;
  final VoidCallback? onRelease;
  final DateTime? releasedAt;

  /// When set, a pending proposal offers "Review match" instead of
  /// confirming directly.
  final VoidCallback? onReview;
  @override
  State<MatchActions> createState() => _MatchActionsState();
}

class _MatchActionsState extends State<MatchActions> {
  bool _busy = false;
  Future<void> _ready() async {
    final s = VenueScope.of(context);
    setState(() => _busy = true);
    final result = await runGuarded(
      context,
      () => s.client.release.markReady(widget.match.id!),
      onDenied: s.onDenied,
    );
    if (mounted) setState(() => _busy = false);
    if (result != null) {
      s.scheduleRefresh();
      widget.onChanged?.call();
    }
  }

  Future<void> _act(bool confirm) async {
    final session = VenueScope.of(context);
    final actionContext = Navigator.of(context).context;
    final match = widget.match;
    final onChanged = widget.onChanged;
    String? reason;
    if (!confirm) {
      reason = await askDismissReason(
        context,
        undo: match.state == MatchState.confirmed,
      );
      if (reason == null || !actionContext.mounted) return;
    }
    if (mounted) setState(() => _busy = true);
    final result = await runGuarded(
      actionContext,
      () => confirm
          ? session.client.match.confirm(match.id!)
          : session.client.match.reject(match.id!, reason!),
      onDenied: session.onDenied,
    );
    if (mounted) setState(() => _busy = false);
    if (result != null) {
      if (actionContext.mounted) {
        ScaffoldMessenger.of(actionContext).showSnackBar(
          SnackBar(
            content: Text(confirm ? 'Match confirmed.' : 'Match dismissed.'),
          ),
        );
      }
      session.scheduleRefresh();
      onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final match = widget.match;
    final released =
        widget.releasedAt != null ||
        widget.reportStatus == ReportStatus.returned;
    final note = context.type.body.copyWith(fontSize: 14, color: c.ink2);
    Widget pair(Widget secondary, Widget primary) => Row(
      children: [
        Expanded(child: secondary),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: primary),
      ],
    );
    final List<Widget> rows;
    if (released) {
      rows = [
        Row(
          children: [
            Icon(Icons.check_circle_outline, color: c.ok, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Returned${widget.releasedAt == null ? '' : ' on ${dateTimeLabel(widget.releasedAt!, midSentence: true)}'}',
                style: note,
              ),
            ),
          ],
        ),
      ];
    } else if (match.state == MatchState.pending) {
      final dismiss = OutlinedButton(
        onPressed: _busy ? null : () => _act(false),
        child: const Text('Dismiss'),
      );
      rows = [
        widget.onReview != null
            ? pair(
                dismiss,
                FilledButton(
                  onPressed: _busy ? null : widget.onReview,
                  child: const Text('Review match'),
                ),
              )
            : pair(
                dismiss,
                FilledButton.icon(
                  onPressed: _busy ? null : () => _act(true),
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Confirm match'),
                ),
              ),
      ];
    } else if (match.state == MatchState.confirmed) {
      final undo = OutlinedButton(
        onPressed: _busy ? null : () => _act(false),
        child: const Text('Undo confirmation'),
      );
      rows = [
        if (widget.reportStatus == ReportStatus.possibleMatch) ...[
          OutlinedButton.icon(
            onPressed: _busy ? null : _ready,
            icon: const Icon(Icons.inventory_2_outlined, size: 20),
            label: const Text('Mark ready for pickup'),
          ),
          const SizedBox(height: 10),
        ],
        widget.onRelease == null
            ? undo
            : pair(
                undo,
                FilledButton.icon(
                  onPressed: _busy ? null : widget.onRelease,
                  icon: const Icon(Icons.check, size: 20),
                  label: const Text('Return to owner'),
                ),
              ),
      ];
    } else {
      rows = [
        Text(
          match.state == MatchState.rejected
              ? 'This proposal was dismissed.'
              : 'A newer proposal replaced this one.',
          style: note,
        ),
      ];
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_busy) ...[
          const LinearProgressIndicator(minHeight: 2),
          const SizedBox(height: 10),
        ],
        ...rows,
      ],
    );
  }
}
