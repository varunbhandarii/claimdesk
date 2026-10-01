import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../data/photo_urls.dart';
import '../live/venue_events.dart';

class VenueSession extends ChangeNotifier {
  VenueSession({
    required this.client,
    required this.venue,
    required this.membership,
    required this.onDenied,
  }) {
    photos = PhotoUrls((id, thumb) => client.item.photoUrl(id, thumb: thumb));
    live = VenueEvents(
      openStream: () => client.deskStream.watchVenue(venue.id!),
      onReconnect: () {
        reconnectRevision++;
        notifyListeners();
        scheduleRefresh();
      },
      onDenied: (error) => onDenied(),
    );
    _events = live.events.listen((event) {
      lastEvent = event;
      if (event.itemId != null) {
        photos.invalidate(event.itemId!);
        if (event.kind == 'captionFailed') {
          failedItems.add(event.itemId!);
        } else {
          failedItems.remove(event.itemId);
        }
      }
      notifyListeners();
      scheduleRefresh();
    });
    live.addListener(_liveChanged);
    client.connectivityMonitor?.addListener(_connectivityChanged);
  }
  final Client client;
  final Venue venue;
  final StaffMembership membership;
  final VoidCallback onDenied;
  late final PhotoUrls photos;
  late final VenueEvents live;
  late final StreamSubscription<DeskEvent> _events;
  List<FoundItem> items = [];
  List<LostReport> reports = [];
  List<MatchCard> inbox = [];
  bool inboxLoading = true, inboxRefreshing = false, _inboxAgain = false;
  Object? inboxError;
  ReportStatus? reportStatusFilter;
  UuidValue? reportZoneFilter;
  String? reportCategoryFilter;
  Object? reportError;
  bool reportsLoading = true;
  bool reportsRefreshing = false;
  bool _reportsAgain = false;
  List<Zone> zones = [];
  final failedItems = <UuidValue>{};
  DeskEvent? lastEvent;
  int reconnectRevision = 0;
  ItemStatus? statusFilter;
  UuidValue? zoneFilter;
  Object? error;
  bool loading = true;
  bool refreshing = false;
  bool offline = false;
  bool _disposed = false;
  int _queryVersion = 0;
  Timer? _refreshTimer;
  bool _refreshAgain = false;
  Future<void> start() async {
    live.start();
    await Future.wait([refreshItems(), refreshReports(), refreshInbox()]);
  }

  void _liveChanged() {
    if (!_disposed) notifyListeners();
  }

  void _connectivityChanged(bool connected) {
    offline = !connected;
    live.connectivityChanged(connected);
    if (!_disposed) notifyListeners();
  }

  void scheduleRefresh() {
    if (_disposed || _refreshTimer?.isActive == true) return;
    _refreshTimer = Timer(
      const Duration(seconds: 1),
      () {
        unawaited(refreshItems());
        unawaited(refreshReports());
        unawaited(refreshInbox());
      },
    );
  }

  Future<void> refreshItems() async {
    if (_disposed) return;
    if (refreshing) {
      _refreshAgain = true;
      return;
    }
    refreshing = true;
    final version = ++_queryVersion;
    notifyListeners();
    try {
      final result = await client.item.listItems(
        venue.id!,
        ItemFilter(status: statusFilter, zoneId: zoneFilter),
      );
      final newZones = await client.venue.zones(venue.id!);
      if (_disposed || version != _queryVersion) return;
      items = result;
      zones = newZones;
      error = null;
      offline = false;
      live.serverAvailable();
    } catch (e) {
      if (_disposed) return;
      error = e;
      if (e is NotAMemberException) {
        onDenied();
      } else {
        offline = true;
      }
    } finally {
      if (!_disposed) {
        loading = false;
        refreshing = false;
        notifyListeners();
        if (_refreshAgain) {
          _refreshAgain = false;
          scheduleRefresh();
        }
      }
    }
  }

  String zoneName(UuidValue? id) =>
      zones.where((z) => z.id == id).firstOrNull?.name ?? 'No zone';
  Future<void> refreshReports() async {
    if (_disposed) return;
    if (reportsRefreshing) {
      _reportsAgain = true;
      return;
    }
    reportsRefreshing = true;
    notifyListeners();
    try {
      final result = await client.report.listReports(
        venue.id!,
        ReportFilter(
          status: reportStatusFilter,
          zoneId: reportZoneFilter,
          category: reportCategoryFilter,
        ),
      );
      if (_disposed) return;
      reports = result;
      reportError = null;
    } catch (e) {
      if (_disposed) return;
      reportError = e;
      if (e is NotAMemberException) onDenied();
    } finally {
      if (!_disposed) {
        reportsLoading = false;
        reportsRefreshing = false;
        notifyListeners();
        if (_reportsAgain) {
          _reportsAgain = false;
          scheduleRefresh();
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_queryVersion;
    _refreshTimer?.cancel();
    client.connectivityMonitor?.removeListener(_connectivityChanged);
    _events.cancel();
    live.removeListener(_liveChanged);
    live.dispose();
    photos.dispose();
    super.dispose();
  }

  Future<void> refreshInbox() async {
    if (_disposed) return;
    if (inboxRefreshing) {
      _inboxAgain = true;
      return;
    }
    inboxRefreshing = true;
    notifyListeners();
    try {
      final result = await client.match.inbox(venue.id!);
      if (_disposed) return;
      inbox = result;
      inboxError = null;
    } catch (e) {
      if (_disposed) return;
      inboxError = e;
      if (e is NotAMemberException) onDenied();
    } finally {
      if (!_disposed) {
        inboxLoading = false;
        inboxRefreshing = false;
        notifyListeners();
        if (_inboxAgain) {
          _inboxAgain = false;
          scheduleRefresh();
        }
      }
    }
  }
}

class VenueScope extends InheritedNotifier<VenueSession> {
  const VenueScope({
    super.key,
    required VenueSession session,
    required super.child,
  }) : super(notifier: session);
  static VenueSession of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<VenueScope>()!.notifier!;
}
