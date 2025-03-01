// debug_logger.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DebugLogger {
  static const String _logKey = 'debug_logs';
  static const int _maxLogs = 1000;
  static int _buildCount = 0;
  static int _authAttempts = 0;

  static Future<void> log(String message, {String category = ''}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = [];

      final existingLogsStr = prefs.getString(_logKey);
      if (existingLogsStr != null) {
        logs = List<String>.from(jsonDecode(existingLogsStr));
      }

      final timestamp = DateTime.now().toIso8601String();
      String prefix = '';

      switch(category) {
        case 'BUILD':
          _buildCount++;
          prefix = '[BUILD #$_buildCount]';
          break;
        case 'AUTH':
          _authAttempts++;
          prefix = '[AUTH #$_authAttempts]';
          break;
        default:
          prefix = category.isNotEmpty ? '[$category]' : '';
      }

      String logEntry = '[$timestamp] $prefix $message';
      print(logEntry); // Print immediately

      logs.add(logEntry);
      if (logs.length > _maxLogs) {
        logs = logs.sublist(logs.length - _maxLogs);
      }

      await prefs.setString(_logKey, jsonEncode(logs));
    } catch (e) {
      print('Error saving log: $e');
    }
  }

  static Future<void> logAuth({
    required String action,
    required String source,
    String? token,
    String? error,
    Map<String, dynamic>? details
  }) async {
    String message = '[$action] from $source';
    if (token != null) {
      String truncatedToken = token.length > 20 ? '${token.substring(0, 20)}...' : token;
      message += ' | Token: $truncatedToken';
    }
    if (error != null) {
      message += ' | Error: $error';
    }
    if (details != null) {
      message += ' | Details: ${jsonEncode(details)}';
    }
    await log(message, category: 'AUTH');
  }

  static Future<void> logToken({
    required String token,
    required String action,
    required String source,
  }) async {
    String truncatedToken = token.length > 20 ? '${token.substring(0, 20)}...' : token;
    await log('Token $action | From: $source | Value: $truncatedToken', category: 'TOKEN');
  }

  static Future<void> logNavigation(String from, String to, {Map<String, dynamic>? params}) async {
    String message = 'Navigation: $from -> $to';
    if (params != null) {
      message += ' | Params: ${jsonEncode(params)}';
    }
    await log(message, category: 'NAV');
  }

  static Future<void> logStateChange(String bloc, String from, String to) async {
    await log('State Change in $bloc: $from -> $to', category: 'STATE');
  }

  static Future<void> printAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsStr = prefs.getString(_logKey);
      if (logsStr != null) {
        final logs = List<String>.from(jsonDecode(logsStr));
        print('\n=== START OF SAVED DEBUG LOGS ===');
        print('Total Logs: ${logs.length}');
        print('Total Builds: $_buildCount');
        print('Total Auth Attempts: $_authAttempts\n');

        for (final log in logs) {
          print(log);
        }
        print('=== END OF SAVED DEBUG LOGS ===\n');
      }
    } catch (e) {
      print('Error printing logs: $e');
    }
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logKey);
      _buildCount = 0;
      _authAttempts = 0;
      print('Debug logs cleared');
    } catch (e) {
      print('Error clearing logs: $e');
    }
  }
}