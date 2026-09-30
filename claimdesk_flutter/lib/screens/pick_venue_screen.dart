import 'dart:async';
import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/venue_session.dart';
import '../client.dart';
import '../data/errors.dart';
import '../data/venue_choice.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your venues'),
        actions: [
          TextButton(onPressed: _signOut, child: const Text('Sign out')),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(errorMessage(_error!)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _load(),
                      child: const Text('Retry'),
                    ),
                  ],
                )
              : _venues!.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('This account is not assigned to a venue'),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      'Choose your desk',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    for (final choice in _venues!)
                      Card(
                        child: ListTile(
                          title: Text(choice.$2.name),
                          subtitle: Text(
                            choice.$1.role == StaffRole.supervisor
                                ? 'Supervisor'
                                : 'Staff',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () => _choose(choice),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
