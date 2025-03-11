import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/provider/language.dart';

import '../profile/profile_completion_service.dart';

/// Service responsible for clearing app data when user logs out
class AppDataClearService {
  static final AppDataClearService _instance = AppDataClearService._internal();

  factory AppDataClearService() {
    return _instance;
  }

  AppDataClearService._internal();

  /// Clear all app data but preserve language setting
  Future<void> clearAllData() async {
    try {
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Save current language setting before clearing
      final Language language = Language();
      final currentLanguage = language.getLanguage();

      // Clear all shared preferences
      await prefs.clear();

      // Restore language setting
      await prefs.setString('app_language', currentLanguage);

      // Clear profile completion status
      await ProfileCompletionService().setProfileComplete(false);

      // Reset notification settings to default
      await NotificationService.setNotificationStatus(true);

      // Reset data saver to default
      await DataSaverService.setDataSaverStatus(false);

      // Clear cached files
      await _clearAppCacheDirectories();

      // Reset any other app-specific settings
      await _resetAppSpecificSettings();

    } catch (e) {
      // Log error but don't throw to avoid crashing during logout
      print('Error clearing app data: $e');
    }
  }

  /// Clear temporary files and cache directories
  Future<void> _clearAppCacheDirectories() async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      await _deleteDirectoryContents(tempDir);

      // Get application cache directory
      final appCacheDir = await getApplicationCacheDirectory();
      await _deleteDirectoryContents(appCacheDir);

      // Clear any downloaded images or files
      // If you're using any image caching packages, clear them here
      // Example: await DefaultCacheManager().emptyCache();

    } catch (e) {
      print('Error clearing cache directories: $e');
    }
  }

  /// Delete contents of a directory without deleting the directory itself
  Future<void> _deleteDirectoryContents(Directory directory) async {
    try {
      if (directory.existsSync()) {
        final List<FileSystemEntity> entities = directory.listSync();
        for (final FileSystemEntity entity in entities) {
          try {
            if (entity is Directory) {
              await entity.delete(recursive: true);
            } else if (entity is File) {
              await entity.delete();
            }
          } catch (e) {
            // If deletion of a single file fails, continue with others
            print('Error deleting ${entity.path}: $e');
          }
        }
      }
    } catch (e) {
      print('Error deleting directory contents: $e');
    }
  }

  /// Reset app-specific settings to defaults
  Future<void> _resetAppSpecificSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset any app tour or onboarding flags
    await prefs.setBool('has_seen_onboarding', false);

    // Reset search history
    await prefs.setStringList('search_history', []);

    // Reset any user preferences
    await prefs.setBool('dark_mode_enabled', false);
    await prefs.setBool('notifications_enabled', true);

    // Clear authentication tokens
    await prefs.remove('token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');

    // Reset app state
    await prefs.remove('last_screen');
    await prefs.remove('last_category_viewed');

    // Clear any saved posts or favorites
    await prefs.remove('saved_posts');
    await prefs.remove('favorite_categories');

    // Clear any draft posts
    await prefs.remove('draft_posts');
  }
}

// Add these imports and classes to your NotificationService.dart file
class NotificationService {
  static const String _notificationsKey = 'notifications_enabled';

  // Get current notification status
  static Future<bool> getNotificationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to true if not set
    return prefs.getBool(_notificationsKey) ?? true;
  }

  // Set notification status
  static Future<bool> setNotificationStatus(bool isEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_notificationsKey, isEnabled);
  }

  // Toggle notification status
  static Future<bool> toggleNotifications() async {
    final currentStatus = await getNotificationStatus();
    return await setNotificationStatus(!currentStatus);
  }
}

class DataSaverService {
  static const String _dataSaverKey = 'data_saver_enabled';

  // Get current data saver status
  static Future<bool> getDataSaverStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Default to false if not set
    return prefs.getBool(_dataSaverKey) ?? false;
  }

  // Set data saver status
  static Future<bool> setDataSaverStatus(bool isEnabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(_dataSaverKey, isEnabled);
  }

  // Toggle data saver status
  static Future<bool> toggleDataSaver() async {
    final currentStatus = await getDataSaverStatus();
    return await setDataSaverStatus(!currentStatus);
  }
}