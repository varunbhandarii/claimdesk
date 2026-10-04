import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/errors.dart';
import '../data/external_links.dart';

class TagButton extends StatefulWidget {
  const TagButton({
    super.key,
    required this.link,
    this.open = openExternalLink,
  });
  final Future<String> Function() link;
  final Future<bool> Function(String url) open;
  @override
  State<TagButton> createState() => _TagButtonState();
}

class _TagButtonState extends State<TagButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    icon: const Icon(Icons.print_outlined),
    label: Text(_busy ? 'Preparing tag…' : 'Print tag'),
    onPressed: _busy
        ? null
        : () async {
            setState(() => _busy = true);
            try {
              final url = await widget.link();
              if (!context.mounted) return;
              // A second tap preserves the browser's popup gesture after the RPC.
              await showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Printable tag ready'),
                  content: const Text(
                    'Open the tag, then use your browser’s Print command. Link valid for 24 hours.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                      },
                      child: const Text('Copy tag link'),
                    ),
                    FilledButton(
                      onPressed: () async {
                        try {
                          await widget.open(url);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(errorMessage(e))),
                            );
                          }
                        }
                      },
                      child: const Text('Open tag'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(errorMessage(e))));
              }
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          },
  );
}
