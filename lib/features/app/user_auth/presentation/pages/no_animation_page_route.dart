import 'package:flutter/material.dart';

class NoAnimationPageRoute extends PageRouteBuilder {
  final Widget page;

  NoAnimationPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
          transitionDuration: Duration.zero, // No animation duration
          reverseTransitionDuration: Duration.zero, // No animation duration for reverse transition
        );
}
