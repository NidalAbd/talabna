import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:talbna/blocs/internet/internet_bloc.dart';
import 'package:talbna/blocs/internet/internet_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

// create an instance of SharedPreferences
final SharedPreferences sharedPreferences =
    SharedPreferences.getInstance() as SharedPreferences;

// create an instance of GetIt
GetIt getIt = GetIt.instance;

/// Display a snackbar with the given [message] on the current [Scaffold].
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Make an HTTP GET request to the given [url], and return the response as a
/// JSON object.
Future<Map<String, dynamic>> getJson(String url) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data from server');
  }
}

/// Return true if the given [value] is a valid email address, and false
/// otherwise.
bool isValidEmail(String value) {
  const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  final regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

/// Return true if the given [value] is a valid phone number, and false
/// otherwise.
bool isValidPhoneNumber(String value) {
  const pattern = r'^\+?[0-9]{8,}$';
  final regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

class NetworkHelper {
  static void observeNetwork() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        NetworkBloc().add(NetworkNotify());
      } else {
        NetworkBloc().add(NetworkNotify(isConnected: true));
      }
    });
  }
}

