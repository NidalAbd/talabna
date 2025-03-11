// lib/utils/custom_routes.dart

import 'package:flutter/material.dart';

/// A custom route transition for the Reels screen that uses a slide up animation
class ReelsRouteTransition extends PageRouteBuilder {
  final Widget page;

  ReelsRouteTransition({required this.page, RouteSettings? settings})
      : super(
    settings: settings,
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 200),
  );
}