import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/claim_shapes.dart';
import '../ui/desk_theme.dart';
import '../ui/desk_widgets.dart';
import '../ui/item_form.dart';
import 'log_item_screen.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key, required this.item});
  final FoundItem item;
  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late final ItemFormController _form = ItemFormController(item: widget.item);
  bool _saving = false;
  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final session = VenueScope.of(context);
    setState(() => _saving = true);
    final item = await runGuarded(
      context,
      () => session.client.item.updateItem(
        widget.item.id!,
        _form.buildPatch(widget.item),
      ),
      onDenied: session.onDenied,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (item != null) {
      session.photos.invalidate(item.id!);
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = VenueScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Edit details'),
            const SizedBox(width: 12),
            RefTag(widget.item.refCode),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, box) => ListView(
          padding: EdgeInsets.fromLTRB(
            box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
            8,
            box.maxWidth > 712 ? (box.maxWidth - 680) / 2 : 16,
            32,
          ),
          children: [
            Text(
              'Changes replace the photo’s description. Private notes stay staff only.',
              style: TextStyle(color: context.desk.ink2),
            ),
            const SizedBox(height: 20),
            ItemForm(
              controller: _form,
              zones: session.zones,
              edit: true,
              enabled: !_saving,
              handoffHint: handoffHint(session.venue),
              onChanged: () => setState(() {}),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StickyBar(
        child: FilledButton(
          style: bigButtonStyle(context),
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Saving…' : 'Save changes'),
        ),
      ),
    );
  }
}
