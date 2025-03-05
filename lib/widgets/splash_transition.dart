import 'package:flutter/material.dart';

/// A widget that provides a smooth fade transition from splash screen to content
class SplashTransition extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Duration fadeInDuration;

  const SplashTransition({
    Key? key,
    required this.child,
    required this.backgroundColor,
    this.fadeInDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<SplashTransition> createState() => _SplashTransitionState();
}

class _SplashTransitionState extends State<SplashTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Delay the animation slightly to ensure the UI is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Enhanced version for more complex layouts
class AppLoadingTransition extends StatefulWidget {
  final Widget child;
  final Widget? logo;
  final Color backgroundColor;
  final Duration animationDuration;

  const AppLoadingTransition({
    Key? key,
    required this.child,
    this.logo,
    required this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: key);

  @override
  State<AppLoadingTransition> createState() => _AppLoadingTransitionState();
}

class _AppLoadingTransitionState extends State<AppLoadingTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // Start the animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background matching splash screen
        Container(color: widget.backgroundColor),

        // Logo that will fade out (if provided)
        if (widget.logo != null)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: 1.0 - _controller.value,
                child: Center(child: widget.logo),
              );
            },
          ),

        // Main content that fades and scales in
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
            );
          },
        ),
      ],
    );
  }
}