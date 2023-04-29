import 'package:flutter/material.dart';

class SuccessWidget {
  static void show(BuildContext context,  String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}