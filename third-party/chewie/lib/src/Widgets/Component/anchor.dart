import 'package:flutter/cupertino.dart';

import 'package:awesome_chewie/awesome_chewie.dart';

enum AnchorType {
  top,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6;

  String get tagName {
    switch (this) {
      case AnchorType.top:
        return 'TOP';
      case AnchorType.h1:
        return 'h1';
      case AnchorType.h2:
        return 'h2';
      case AnchorType.h3:
        return 'h3';
      case AnchorType.h4:
        return 'h4';
      case AnchorType.h5:
        return 'h5';
      case AnchorType.h6:
        return 'h6';
    }
  }

  static AnchorType fromString(String type) {
    switch (type) {
      case 'h1':
        return AnchorType.h1;
      case 'h2':
        return AnchorType.h2;
      case 'h3':
        return AnchorType.h3;
      case 'h4':
        return AnchorType.h4;
      case 'h5':
        return AnchorType.h5;
      case 'h6':
        return AnchorType.h6;
    }
    return AnchorType.h1;
  }
}

class Anchor {
  bool get isTop => type == AnchorType.top;

  final AnchorType type;
  final String title;

  final String id;

  Anchor(this.type, this.title) : id = StringUtil.generateUid();

  @override
  String toString() {
    return '$id: $type-$title';
  }
}

class AnchorManager {
  static final AnchorManager instance = AnchorManager._internal();

  final Map<String, BuildContext> _contexts = {};

  AnchorManager._internal();

  void register(String id, BuildContext context) {
    _contexts[id] = context;
  }

  void unregister(String id) {
    _contexts.remove(id);
  }

  BuildContext? getContext(String id) => _contexts[id];

  void clear() {
    _contexts.clear();
  }
}

class AnchorWidget extends StatelessWidget {
  final String id;
  final Widget child;

  const AnchorWidget({super.key, required this.id, required this.child});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnchorManager.instance.register(id, context);
    });
    return child;
  }
}

class AnchorUtil {
  static void scrollToAnchor( Anchor anchor, ScrollController controller) {
    final context = AnchorManager.instance.getContext(anchor.id);
    if (context != null && context.findRenderObject() is RenderBox) {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.localToGlobal(Offset.zero, ancestor: null).dy;

      controller.animateTo(
        controller.offset + offset - 116,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
