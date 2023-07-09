import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talbna/app_theme.dart';

import 'check_auth.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  startLaunching() async {
    var durasi = const Duration(seconds: 3);
    return Timer(durasi, () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) {
        return  const CheckAuthScreen();
      }));
    });
  }

  @override
  void initState() {
    super.initState();
    startLaunching();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        resizeToAvoidBottomInset: true,
        body: Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: AppTheme.primaryColor,
            backgroundImage: AssetImage("assets/talabnaLogo.png"),
          ),
        ));
  }
}
