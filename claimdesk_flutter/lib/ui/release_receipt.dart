import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import 'claim_shapes.dart';
import 'desk_theme.dart';
import 'desk_widgets.dart';
import 'format.dart';
import 'release_rules.dart';

/// Staff receipt for a permanent return: who collected, what was checked and
/// who handed it over.
class ReleaseReceipt extends StatefulWidget {
  const ReleaseReceipt({
    super.key,
    required this.summary,
    this.showSignature = false,
  });
  final ReleaseSummary summary;
  final bool showSignature;
  @override
  State<ReleaseReceipt> createState() => _ReleaseReceiptState();
}

class _ReleaseReceiptState extends State<ReleaseReceipt> {
  String? _url;
  bool _loading = false;
  Future<void> _signature() async {
    setState(() => _loading = true);
    final s = VenueScope.of(context);
    final url = await runGuarded(
      context,
      () => s.photos.signature(widget.summary.record.itemId),
      onDenied: s.onDenied,
    );
    if (mounted) {
      setState(() {
        _url = url;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.desk;
    final r = widget.summary.record;
    Widget row(String label, Widget value) => Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: DeskLabel(label),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
    return DeskCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconDisc(Icons.check, tone: DiscTone.ok, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Returned', style: context.type.headingAt(19)),
                    Text(
                      dateTimeLabel(r.releasedAt),
                      style: context.type.small.copyWith(color: c.ink3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (widget.summary.reportRefCode != null)
            row(
              'Report',
              Align(
                alignment: Alignment.centerLeft,
                child: RefTicket(widget.summary.reportRefCode!),
              ),
            ),
          row('Claimant', CopyableText(r.claimantName)),
          row(
            'ID type seen',
            Text(ReleaseRules.labels[r.idTypeSeen] ?? r.idTypeSeen),
          ),
          row('Details matched', Text('${r.detailsMatched}')),
          if (r.thirdPartyAuthorisationNote != null)
            row(
              'Authorisation',
              CopyableText(r.thirdPartyAuthorisationNote!),
            ),
          row('Released by', Text(widget.summary.releasedByName)),
          if (widget.showSignature && r.signaturePath != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _loading ? null : _signature,
                icon: const Icon(Icons.draw_outlined, size: 18),
                label: Text(_loading ? 'Loading signature…' : 'View signature'),
              ),
            ),
            if (_url != null)
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.line),
                ),
                child: Image.network(
                  _url!,
                  errorBuilder: (_, _, _) => const Center(
                    child: Text(
                      'Signature unavailable. Tap View signature to retry.',
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
