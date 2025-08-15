import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FadeTransitionPage extends CustomTransitionPage<dynamic> {
  /// The child (screen) that would be transitioned to.
  final Widget screen;

  /// Custom TransitionPage created to prevent code redundancy.
  FadeTransitionPage({required this.screen})
    : super(
        child: screen,
        transitionDuration: Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}
