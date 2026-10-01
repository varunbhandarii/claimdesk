import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/venue_session.dart';
import '../app/routes.dart';
import '../data/errors.dart';
import '../ui/photo_view.dart';
import '../ui/status.dart';
import '../ui/attribute_chips.dart';
import 'edit_item_screen.dart';
import '../ui/item_form.dart';
import '../ui/match_list.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final UuidValue itemId;
  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  VenueSession? _session;
  FoundItem? _item;
  List<CaptionRun> _runs = [];
  List<MatchCard> _matches = [];
  Object? _error;
  DeskEvent? _lastEvent;
  int _reconnectRevision = 0;
  bool _loading = false;
  bool _again = false;
  bool _acting = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = VenueScope.of(context);
    if (_session == session) return;
    _session?.removeListener(_changed);
    _session = session;
    session.addListener(_changed);
    _load();
  }

  void _changed() {
    if (_reconnectRevision != _session!.reconnectRevision) {
      _reconnectRevision = _session!.reconnectRevision;
      _load();
    }
    final event = _session!.lastEvent;
    if (event != null && !identical(event, _lastEvent)) {
      _lastEvent = event;
      if (event.itemId == widget.itemId) _load();
    }
  }

  Future<void> _load() async {
    if (_loading) {
      _again = true;
      return;
    }
    _loading = true;
    try {
      final item = await _session!.client.item.getItem(widget.itemId);
      final runs = await _session!.client.item.captionRuns(widget.itemId);
      final matches = await _session!.client.match.forItem(widget.itemId);
      if (mounted) {
        setState(() {
          _item = item;
          _runs = runs.reversed.toList();
          _matches = matches;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
        if (e is NotAMemberException) _session!.onDenied();
      }
    } finally {
      _loading = false;
      if (_again && mounted) {
        _again = false;
        _load();
      }
    }
  }

  @override
  void dispose() {
    _session?.removeListener(_changed);
    super.dispose();
  }

  Future<void> _recaption() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Caption this photo again?'),
        content: const Text(
          'The new caption replaces the current attributes. Your private notes stay with the item.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Recaption'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    setState(() => _acting = true);
    await runGuarded(context, () async {
      await _session!.client.item.recaption(widget.itemId);
      await _load();
    }, onDenied: _session!.onDenied);
    if (mounted) setState(() => _acting = false);
  }

  String _date(DateTime date) => date.toLocal().toString().split('.').first;
  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    final item = _item;
    return Scaffold(
      appBar: AppBar(title: const Text('Found item')),
      body: item == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(errorMessage(_error!)),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      SizedBox(
                        height: 320,
                        child: GestureDetector(
                          onTap: () => openDeskScreen(
                            context,
                            session,
                            Scaffold(
                              appBar: AppBar(title: Text(item.refCode)),
                              body: InteractiveViewer(
                                child: Center(
                                  child: PhotoView(
                                    urls: session.photos,
                                    itemId: item.id!,
                                    revision: item.updatedAt,
                                    onDenied: session.onDenied,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PhotoView(
                              urls: session.photos,
                              itemId: item.id!,
                              revision: item.updatedAt,
                              onDenied: session.onDenied,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SelectableText(
                            item.refCode,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontFamily: 'monospace'),
                          ),
                          IconButton(
                            tooltip: 'Copy reference',
                            onPressed: () => Clipboard.setData(
                              ClipboardData(text: item.refCode),
                            ),
                            icon: const Icon(Icons.copy),
                          ),
                          StatusChip(item.status),
                        ],
                      ),
                      Text(
                        '${session.zoneName(item.zoneId)} · Found ${_date(item.foundAt)}',
                      ),
                      const SizedBox(height: 16),
                      Text('Storage bin: ${item.storageBin ?? 'Not set'}'),
                      Text('Value: ${valueBandLabel(item.valueBand)}'),
                      if (item.holdUntil != null)
                        Text('Hold until: ${_date(item.holdUntil!)}'),
                      if (item.handoffDueAt != null)
                        Text(
                          'Hand-off due: ${_date(item.handoffDueAt!)}',
                          style: TextStyle(
                            color: item.handoffDueAt!.isBefore(DateTime.now())
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _acting
                                ? null
                                : () async {
                                    final edited =
                                        await openDeskScreen<FoundItem>(
                                          context,
                                          session,
                                          EditItemScreen(item: item),
                                        );
                                    if (edited != null && mounted) {
                                      setState(() => _item = edited);
                                    }
                                  },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit details'),
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                !_acting && item.status == ItemStatus.unclaimed
                                ? _recaption
                                : null,
                            icon: const Icon(Icons.auto_awesome_outlined),
                            label: const Text('Recaption'),
                          ),
                        ],
                      ),
                      const Divider(height: 40),
                      if (item.attributes != null)
                        AttributeChips(
                          attributes: item.attributes!,
                          restricted: item.restricted,
                        ),
                      if (item.captionText != null)
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainer,
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          child: SelectableText(item.captionText!),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Matches',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      MatchList(cards: _matches),
                      const SizedBox(height: 24),
                      Text(
                        'Item journey',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Logged at the desk'),
                        subtitle: Text(_date(item.createdAt)),
                      ),
                      ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(statusLabel(item.status)),
                        subtitle: Text('Updated ${_date(item.updatedAt)}'),
                      ),
                      ExpansionTile(
                        title: Text('Caption history (${_runs.length})'),
                        children: [
                          if (_runs.isEmpty)
                            const ListTile(title: Text('No caption runs yet')),
                          for (final run in _runs)
                            ListTile(
                              title: Text('${run.provider} · ${run.outcome}'),
                              subtitle: Text(
                                '${run.modelId}\n${run.latencyMs} ms · ${run.inputTokens ?? 0} input / ${run.outputTokens ?? 0} output tokens\n${_date(run.createdAt)}${run.errorMessage == null ? '' : '\n${run.errorMessage}'}',
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Private notes · staff only',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(item.privateNotes ?? 'No private notes'),
                      if (item.finderName != null)
                        Text('Finder: ${item.finderName}'),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
