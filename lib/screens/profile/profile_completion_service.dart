import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/user.dart';

/// Service to check profile completion status across the app
class ProfileCompletionService {
  static final ProfileCompletionService _instance = ProfileCompletionService._internal();

  // Singleton pattern
  factory ProfileCompletionService() {
    return _instance;
  }

  ProfileCompletionService._internal() {
    // Initialize the notifier value with the current status (if available)
    _initializeNotifier();
  }

  // Initialize the notifier with the current status
  Future<void> _initializeNotifier() async {
    final isComplete = await isProfileComplete();
    profileCompletionNotifier.value = isComplete;
  }

  // In-memory cache to avoid frequent SharedPreferences lookups
  bool? _cachedCompletionStatus;

  /// Check if the user profile is marked as complete
  ///
  /// This checks the SharedPreferences storage for the 'profileCompleted' flag
  /// Returns the cached value if available to minimize I/O operations
  Future<bool> isProfileComplete() async {
    // Return cached value if available
    if (_cachedCompletionStatus != null) {
      return _cachedCompletionStatus!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedCompletionStatus = prefs.getBool('profileCompleted') ?? false;
    return _cachedCompletionStatus!;
  }

  /// Update the profile completion status
  ///
  /// Sets the 'profileCompleted' flag in SharedPreferences and updates the cache
  Future<void> setProfileComplete(bool isComplete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('profileCompleted', isComplete);
    _cachedCompletionStatus = isComplete;

    // Also update the notifier value
    profileCompletionNotifier.value = isComplete;
    print('ProfileCompletionService: status updated to $isComplete');
  }

  /// Clear the cached status to force a fresh check
  void clearCache() {
    _cachedCompletionStatus = null;
    print('ProfileCompletionService: cache cleared');
  }

  /// Stream controller to notify listeners when profile completion status changes
  final ValueNotifier<bool> profileCompletionNotifier = ValueNotifier<bool>(false);

  /// Update profile completion status and notify listeners
  Future<void> updateProfileCompletionStatus() async {
    // Force clear the cache to get the latest value
    clearCache();

    // Get the latest status
    final isComplete = await isProfileComplete();

    // Update the notifier value to trigger listeners
    profileCompletionNotifier.value = isComplete;
    print('ProfileCompletionService: notifier updated to $isComplete');
  }

  Future<void> debugLogPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isComplete = prefs.getBool('profileCompleted') ?? false;
    final notifierValue = profileCompletionNotifier.value;
    final cachedValue = _cachedCompletionStatus;

    print('====== PROFILE COMPLETION DEBUG ======');
    print('SharedPreferences value: $isComplete');
    print('Notifier value: $notifierValue');
    print('Cached value: $cachedValue');
    print('======================================');
  }

  /// Debug method to manually check and log profile completion in UpdateUserProfile
  Future<bool> debugCheckProfileCompletion(User user) async {
    // Check each required field individually
    final bool hasPhones = user.phones != null && user.phones!.isNotEmpty;
    final bool hasWhatsApp = user.watsNumber != null && user.watsNumber!.isNotEmpty;
    final bool hasGender = user.gender != null && user.gender!.isNotEmpty;
    final bool hasDate = user.dateOfBirth != null;
    final bool hasCountry = user.country != null;
    final bool hasCity = user.city != null;

    // Check if all required fields are complete
    final bool isComplete = hasPhones && hasWhatsApp && hasGender &&
        hasDate && hasCountry && hasCity;

    print('====== PROFILE FIELDS DEBUG ======');
    print('User ID: ${user.id}');
    print('Phones: $hasPhones (${user.phones})');
    print('WhatsApp: $hasWhatsApp (${user.watsNumber})');
    print('Gender: $hasGender (${user.gender})');
    print('Date of Birth: $hasDate (${user.dateOfBirth})');
    print('Country: $hasCountry (${user.country?.id})');
    print('City: $hasCity (${user.city?.id})');
    print('OVERALL COMPLETE: $isComplete');
    print('==================================');

    return isComplete;
  }
}