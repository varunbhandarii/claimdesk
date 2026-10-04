import 'dart:async';
import 'package:flutter/material.dart';

class ItemSearchField extends StatefulWidget {
  const ItemSearchField({
    super.key,
    required this.query,
    required this.onQuery,
    required this.results,
  });
  final String query;
  final ValueChanged<String> onQuery;
  final int results;
  @override
  State<ItemSearchField> createState() => _ItemSearchFieldState();
}

class _ItemSearchFieldState extends State<ItemSearchField> {
  late final _controller = TextEditingController(text: widget.query);
  Timer? _timer;
  @override
  void didUpdateWidget(ItemSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query &&
        _controller.text.trim() != widget.query) {
      _timer?.cancel();
      _controller.text = widget.query;
    }
  }

  void _change(String value) {
    _timer?.cancel();
    setState(() {});
    _timer = Timer(const Duration(milliseconds: 400), () {
      final text = value.trim();
      if (text.isEmpty || text.length >= 2) {
        widget.onQuery(text);
      } else if (widget.query.isNotEmpty) {
        widget.onQuery('');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: _controller,
        onChanged: _change,
        maxLength: 80,
        decoration: InputDecoration(
          labelText: 'Search items',
          hintText: 'Caption, private notes, bin or reference',
          counterText: '',
          helperText: _controller.text.trim().length == 1
              ? 'Enter at least two characters'
              : null,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _timer?.cancel();
                    _controller.clear();
                    setState(() {});
                    widget.onQuery('');
                  },
                ),
        ),
      ),
      if (widget.query.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('${widget.results} results for “${widget.query}”'),
        ),
    ],
  );
}
