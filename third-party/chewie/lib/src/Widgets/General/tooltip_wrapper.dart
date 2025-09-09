import 'package:awesome_chewie/awesome_chewie.dart';
import 'package:flutter/material.dart';

class ToolTipWrapper extends StatelessWidget {
  final String? message;
  final InlineSpan? richMessage;
  final Widget child;
  final TooltipPosition? position;
  final Duration? waitDuration;
  final double? maxWidth;

  const ToolTipWrapper({
    super.key,
    this.message,
    required this.child,
    this.richMessage,
    this.maxWidth = 400,
    this.position = TooltipPosition.bottom,
    this.waitDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    bool hasMessage = message != null && message!.isNotEmpty;
    bool hasRichMessage = richMessage != null && richMessage is InlineSpan;
    if (hasMessage || hasRichMessage) {
      return MyTooltip(
        message: message,
        richMessage: richMessage,
        maxWidth: maxWidth,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: ChewieTheme.defaultDecoration.copyWith(
          color: ChewieTheme.canvasColor,
          border: null,
          borderRadius: ChewieDimens.borderRadius8,
        ),
        textStyle: hasRichMessage ? null : ChewieTheme.bodyMedium,
        waitDuration: waitDuration,
        position: position ?? TooltipPosition.bottom,
        child: child,
      );
    } else {
      return child;
    }
  }
}
