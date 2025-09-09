import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef KeyboardNavigableItemBuilder = Widget Function(BuildContext context, int index, bool selected);

class KeyboardNavigableScrollView extends StatefulWidget {
  final int itemCount;
  final KeyboardNavigableItemBuilder itemBuilder;
  final ScrollView Function(ScrollController controller, List<Widget> children) builder;
  final int? initialSelectedIndex;
  final ValueChanged<int>? onSelectedChanged;

  const KeyboardNavigableScrollView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.builder,
    this.initialSelectedIndex,
    this.onSelectedChanged,
  });

  @override
  State<KeyboardNavigableScrollView> createState() => _KeyboardNavigableScrollViewState();
}

class _KeyboardNavigableScrollViewState extends State<KeyboardNavigableScrollView> {
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  int _selectedIndex = 0;
  final itemKeys = <GlobalKey>[];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialSelectedIndex ?? 0;
    _focusNode = FocusNode();
    _scrollController = ScrollController();
    itemKeys.addAll(List.generate(widget.itemCount, (_) => GlobalKey()));
  }

  void _changeSelection(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.itemCount) return;
    setState(() => _selectedIndex = newIndex);
    widget.onSelectedChanged?.call(newIndex);

    // 自动滚动
    final key = itemKeys[newIndex];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;

      if (key == LogicalKeyboardKey.arrowDown) {
        _changeSelection(_selectedIndex + 1);
      } else if (key == LogicalKeyboardKey.arrowUp) {
        _changeSelection(_selectedIndex - 1);
      } else if (key == LogicalKeyboardKey.pageDown) {
        final viewportHeight = _scrollController.position.viewportDimension;
        _scrollController.animateTo(
          _scrollController.offset + viewportHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (key == LogicalKeyboardKey.pageUp) {
        final viewportHeight = _scrollController.position.viewportDimension;
        _scrollController.animateTo(
          _scrollController.offset - viewportHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (key == LogicalKeyboardKey.home) {
        _changeSelection(0);
      } else if (key == LogicalKeyboardKey.end) {
        _changeSelection(widget.itemCount - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = List.generate(widget.itemCount, (index) {
      return KeyedSubtree(
        key: itemKeys[index],
        child: widget.itemBuilder(context, index, index == _selectedIndex),
      );
    });

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKey,
      autofocus: true,
      child: widget.builder(_scrollController, children),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
