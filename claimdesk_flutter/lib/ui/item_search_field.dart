import 'dart:async';
import 'package:flutter/material.dart';
import 'desk_theme.dart';

class ItemSearchField extends StatefulWidget {
  const ItemSearchField({
    super.key,
    required this.query,
    required this.onQuery,
    required this.results,
    this.focusNode,
  });
  final String query;
  final ValueChanged<String> onQuery;
  final int results;
  final FocusNode? focusNode;
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
        focusNode: widget.focusNode,
        onChanged: _change,
        maxLength: 80,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search items, notes or a code',
          counterText: '',
          helperText: _controller.text.trim().length == 1
              ? 'Enter at least two characters'
              : null,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close, size: 20),
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
          child: Text(
            '${widget.results} results for “${widget.query}”',
            style: context.type.small.copyWith(color: context.desk.ink2),
          ),
        ),
    ],
  );
}
