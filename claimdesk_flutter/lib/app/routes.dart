import 'package:flutter/material.dart';
import 'venue_session.dart';

Future<T?> openDeskScreen<T>(
  BuildContext context,
  VenueSession session,
  Widget screen,
) => Navigator.of(context).push<T>(
  MaterialPageRoute(
    builder: (_) => VenueScope(session: session, child: screen),
  ),
);
