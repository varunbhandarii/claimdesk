import 'package:claimdesk_client/claimdesk_client.dart';
import 'package:flutter/material.dart';
import '../app/venue_session.dart';
import '../data/errors.dart';
import '../ui/item_form.dart';

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
      appBar: AppBar(title: Text('Edit ${widget.item.refCode}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ItemForm(
                controller: _form,
                zones: session.zones,
                edit: true,
                enabled: !_saving,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving…' : 'Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
