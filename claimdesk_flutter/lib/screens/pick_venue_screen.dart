import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/venue_session.dart';
import '../client.dart';
import '../data/errors.dart';
import '../data/venue_choice.dart';
import '../ui/brand.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import 'item_list_screen.dart';

class PickVenueScreen extends StatefulWidget {
  const PickVenueScreen({super.key});
  @override
  State<PickVenueScreen> createState() => _PickVenueScreenState();
}

class _PickVenueScreenState extends State<PickVenueScreen> {
  List<(StaffMembership, Venue)>? _venues;
  VenueSession? _session;
  Object? _error;
  bool _loading = true;
  int _version = 0;
  String get _choiceKey => 'venue_${client.auth.authInfo?.authUserId}';
  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    try {
      final choice = await rememberedVenue(client.auth.authInfo!.authUserId);
      if (!mounted) return;
      if (choice != null) {
        await _choose(choice);
        if (_session != null) return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
      }
    }
    if (mounted) await _load();
  }

  Future<void> _load({bool remember = true}) async {
    final version = ++_version;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final memberships = await client.venue.myMemberships();
      final venues = await Future.wait(
        memberships.map(
          (m) async => (m, await client.venue.getVenue(m.venueId)),
        ),
      );
      final preferences = await SharedPreferences.getInstance();
      if (!mounted || version != _version) return;
      setState(() {
        _venues = venues;
        _loading = false;
      });
      final remembered = remember ? preferences.getString(_choiceKey) : null;
      final choice = venues.length == 1
          ? venues.single
          : venues.where((v) => v.$2.id.toString() == remembered).firstOrNull;
      if (choice != null) await _choose(choice);
    } catch (e) {
      if (mounted && version == _version) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _choose((StaffMembership, Venue) choice) async {
    await runGuarded(context, () async {
      await rememberVenue(
        client.auth.authInfo!.authUserId,
        choice.$1,
        choice.$2,
      );
      if (!mounted) return;
      _session?.dispose();
      final session = VenueSession(
        client: client,
        venue: choice.$2,
        membership: choice.$1,
        onDenied: _denied,
      );
      setState(() => _session = session);
      unawaited(session.start());
    });
  }

  void _denied() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    final old = _session;
    setState(() => _session = null);
    old?.dispose();
    unawaited(
      runGuarded(context, () => forgetDesk(client.auth.authInfo!.authUserId)),
    );
    unawaited(_load(remember: false));
  }

  Future<void> _signOut() async {
    await runGuarded(context, () async {
      final userId = client.auth.authInfo!.authUserId;
      await client.auth.signOutDevice();
      _session?.dispose();
      _session = null;
      await forgetDesk(userId);
    });
  }

  @override
  void dispose() {
    ++_version;
    _session?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_session != null) {
      return VenueScope(
        session: _session!,
        child: ItemListScreen(onSignOut: _signOut, onChangeVenue: _denied),
      );
    }
    final c = context.desk;
    return Scaffold(
      appBar: AppBar(
        title: const DeskWordmark(size: 19),
        actions: [
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Sign out'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
              ? RetryMessage(message: errorMessage(_error!), onRetry: _load)
              : _venues!.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const IconDisc(Icons.storefront_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'This account is not assigned to a venue',
                        textAlign: TextAlign.center,
                        style: context.type.headingAt(21),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ask your supervisor to add you to their desk.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.ink2),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    Text(
                      'Choose your desk',
                      style: context.type.displayAt(32),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can switch venues any time from the desk menu.',
                      style: TextStyle(color: c.ink2),
                    ),
                    const SizedBox(height: 24),
                    for (final choice in _venues!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DeskCard(
                          onTap: () => _choose(choice),
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                          child: Row(
                            children: [
                              const ClaimDeskMark(width: 38),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      choice.$2.name,
                                      style: context.type.headingAt(18),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      choice.$1.role == StaffRole.supervisor
                                          ? 'Supervisor'
                                          : 'Staff',
                                      style: context.type.small.copyWith(
                                        color: c.ink3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: c.ink2),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
