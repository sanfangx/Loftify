import 'package:flutter/material.dart';

class DialogAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final bool useAnimation;

  const DialogAnimation({
    super.key,
    required this.animation,
    required this.child,
    this.useAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutBack,
    );

    return useAnimation
        ? ScaleTransition(
            scale: curvedAnimation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          )
        : FadeTransition(
            opacity: animation,
            child: child,
          );
  }
}
