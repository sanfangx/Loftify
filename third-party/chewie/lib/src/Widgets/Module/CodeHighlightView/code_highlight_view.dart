import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

/// Highlight Flutter Widget
class CodeHighlightView extends StatelessWidget {
  /// The original code to be highlighted
  final String source;

  /// Highlight language
  ///
  /// It is recommended to give it a value for performance
  ///
  /// [All available languages](https://github.com/pd4d10/highlight/tree/master/highlight/lib/languages)
  final String? language;

  /// If text is selectable
  final bool isSelectable;

  /// Highlight theme
  ///
  /// [All available themes](https://github.com/pd4d10/highlight/blob/master/flutter_highlight/lib/themes)
  final Map<String, TextStyle> theme;

  /// Padding
  final EdgeInsetsGeometry? padding;

  /// Precomputed Text styles
  final TextStyle textStyle;

  final ScrollController _scrollController = ScrollController();

  CodeHighlightView(
    this.source, {
    super.key,
    this.language,
    this.isSelectable = false,
    this.theme = const {},
    this.padding,
    required this.textStyle,
  });

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    traverse(Node node) {
      if (node.value != null) {
        if (node.value!.contains('\n')) {
          var lines = node.value!.split('\n');
          for (var i = 0; i < lines.length; i++) {
            currentSpans.add(
              TextSpan(
                text: lines[i] + (i < lines.length - 1 ? '\n' : ''),
                style: theme[node.className ?? ''],
              ),
            );
          }
        } else {
          currentSpans.add(TextSpan(
            text: node.value,
            style: theme[node.className ?? ''],
          ));
        }
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans
            .add(TextSpan(children: tmp, style: theme[node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;

        for (var n in node.children!) {
          traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        }
      }
    }

    for (var node in nodes) {
      traverse(node);
    }

    return spans;
  }

  TextSpan _getTextHighlight() {
    return TextSpan(
      style: textStyle,
      children: _convert(highlight.parse(source, language: language).nodes!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme['root']?.backgroundColor ?? const Color(0xffffffff),
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          child: Container(
            padding: padding,
            child: isSelectable
                ? SelectableText.rich(
                    _getTextHighlight(),
                  )
                : Text.rich(
                    _getTextHighlight(),
                    overflow: TextOverflow.visible,
                  ),
          ),
        ),
      ),
    );
  }
}
