import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/errors.dart';
import '../data/external_links.dart';
import 'export_sheet.dart';

/// The desk options menu: supervisor tools first, then the venue and
/// sign-out entries.
List<PopupMenuEntry<String>> deskMenuItems(
  StaffMembership membership, {
  bool venue = true,
}) => [
  if (canExport(membership)) ...[
    const PopupMenuItem(
      value: 'export',
      child: ListTile(
        leading: Icon(Icons.file_download_outlined),
        title: Text('Export CSV'),
      ),
    ),
    const PopupMenuItem(
      value: 'poster',
      child: ListTile(
        leading: Icon(Icons.print_outlined),
        title: Text('Print poster'),
      ),
    ),
  ],
  if (venue)
    const PopupMenuItem(
      value: 'venue',
      child: ListTile(
        leading: Icon(Icons.swap_horiz),
        title: Text('Change venue'),
      ),
    ),
  const PopupMenuItem(
    value: 'out',
    child: ListTile(leading: Icon(Icons.logout), title: Text('Sign out')),
  ),
];

/// Fetches the venue's poster address, then offers to open it. The second
/// tap keeps the browser's pop-up permission after the request.
Future<void> showPosterDialog(
  BuildContext context,
  Future<String> Function() link, {
  Future<bool> Function(String url) open = openExternalLink,
}) async {
  final String url;
  try {
    url = await link();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
    }
    return;
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Venue poster'),
      content: const Text(
        'Open the poster, then print it from your browser at 100% scale. It fits A4 and Letter paper and reads in English and Spanish.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () => Clipboard.setData(ClipboardData(text: url)),
          child: const Text('Copy link'),
        ),
        FilledButton(
          onPressed: () async {
            try {
              await open(url);
            } catch (e) {
              if (ctx.mounted) {
                ScaffoldMessenger.of(
                  ctx,
                ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
              }
            }
          },
          child: const Text('Open poster'),
        ),
      ],
    ),
  );
}
