import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/match_card.dart';
import '../ui/match_actions.dart';
import '../ui/photo_view.dart';
import '../ui/offline_banner.dart';
import 'match_detail_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = VenueScope.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Column(
          children: [
            if (s.offline || s.live.reconnecting)
              OfflineBanner(
                onRetry: () {
                  s.live.connectivityChanged(true);
                  s.refreshInbox();
                },
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Inbox · ${s.inbox.length} to review',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            if (s.inboxRefreshing && !s.inboxLoading)
              const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: s.inboxLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: s.refreshInbox,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (s.inboxError != null)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(errorMessage(s.inboxError!)),
                                  FilledButton(
                                    onPressed: s.refreshInbox,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          if (s.inbox.isEmpty && s.inboxError == null)
                            const Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'No matches to review. New reports and new items are compared automatically.',
                              ),
                            ),
                          for (final card in s.inbox)
                            MatchCardTile(
                              key: ValueKey(card.match.id),
                              card: card,
                              zoneName: s.zoneName(card.item.zoneId),
                              photo: card.item.photoPath == null
                                  ? null
                                  : PhotoView(
                                      urls: s.photos,
                                      itemId: card.item.id!,
                                      thumb: true,
                                      revision: card.item.thumbPath,
                                      onDenied: s.onDenied,
                                    ),
                              actions: MatchActions(match: card.match),
                              onTap: () => openDeskScreen(
                                context,
                                s,
                                MatchDetailScreen(
                                  matchId: card.match.id!,
                                  reportId: card.report.id!,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
