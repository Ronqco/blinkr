import 'package:flutter/material.dart';

class VirtualizedFeed extends StatefulWidget {
  final List<dynamic> items;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final EdgeInsets padding;

  const VirtualizedFeed({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.scrollController,
    this.onLoadMore,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  State<VirtualizedFeed> createState() => _VirtualizedFeedState();
}

class _VirtualizedFeedState extends State<VirtualizedFeed> {
  late ScrollController _scrollController;
  final Set<int> _visibleItems = {};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      widget.onLoadMore?.call();
    }
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return widget.itemBuilder(context, index);
      },
    );
  }
}
