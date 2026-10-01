import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import 'release_rules.dart';

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
    final r = widget.summary.record;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Released', style: Theme.of(context).textTheme.titleLarge),
            Text(
              'Returned ${r.releasedAt.toLocal().toString().split('.').first}',
            ),
            if (widget.summary.reportRefCode != null)
              Text('Report ${widget.summary.reportRefCode}'),
            SelectableText('Claimant: ${r.claimantName}'),
            Text(
              'ID type seen: ${ReleaseRules.labels[r.idTypeSeen] ?? r.idTypeSeen}',
            ),
            Text('Owner-only details matched: ${r.detailsMatched}'),
            if (r.thirdPartyAuthorisationNote != null)
              SelectableText('Authorisation: ${r.thirdPartyAuthorisationNote}'),
            Text('Released by: ${widget.summary.releasedByName}'),
            if (widget.showSignature && r.signaturePath != null) ...[
              TextButton(
                onPressed: _loading ? null : _signature,
                child: Text(_loading ? 'Loading signature…' : 'View signature'),
              ),
              if (_url != null)
                Image.network(
                  _url!,
                  height: 160,
                  errorBuilder: (_, _, _) => const Text(
                    'Signature unavailable. Tap View signature to retry.',
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
