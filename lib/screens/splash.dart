import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/theme_cubit.dart';
import 'check_auth.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late ThemeCubit _themeCubit;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _themeCubit = context.read<ThemeCubit>();

    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = TweenSequence([
      // First very fast pulse
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
      // Fast pulse
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      // Second very fast pulse
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 0.5,
      ),
    ]).animate(_animationController);

    _animationController.forward();
    startLaunching();
  }

  Future<Timer> startLaunching() async {
    var duration = const Duration(seconds: 3);
    await _themeCubit.loadTheme();
    _themeCubit.updateTheme();
    return Timer(duration, () async {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return const CheckAuthScreen();
      }));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.primaryColor,
          body: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/talabnaLogo.png"),
              ),
            ),
          ),
        );
      },
    );
  }
}
