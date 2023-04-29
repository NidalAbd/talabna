import 'package:flutter/material.dart';

class ErrorCustomWidget {
  static SnackBar show(BuildContext context, String message) {
    return SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 7),
    );
  }
}
