import 'package:flutter/material.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/screens/profile/profile_completion_service.dart';
import 'package:talbna/screens/profile/profile_edit_screen.dart';

/// A widget that handles UI conditionals based on profile completion status
class ProfileCheckBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isProfileComplete) builder;
  final User user;
  final int userId;
  final bool showUpdateProfilePrompt;

  const ProfileCheckBuilder({
    super.key,
    required this.builder,
    required this.user,
    required this.userId,
    this.showUpdateProfilePrompt = true,
  });

  @override
  State<ProfileCheckBuilder> createState() => _ProfileCheckBuilderState();
}

class _ProfileCheckBuilderState extends State<ProfileCheckBuilder> {
  bool _isProfileComplete = false;
  bool _isLoading = true;
  final ProfileCompletionService _profileService = ProfileCompletionService();

  @override
  void initState() {
    super.initState();
    _checkProfileCompletion();

    // Listen for changes to profile completion status
    _profileService.profileCompletionNotifier.addListener(_onProfileStatusChanged);
  }

  @override
  void dispose() {
    _profileService.profileCompletionNotifier.removeListener(_onProfileStatusChanged);
    super.dispose();
  }

  void _onProfileStatusChanged() {
    if (mounted) {
      setState(() {
        _isProfileComplete = _profileService.profileCompletionNotifier.value;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkProfileCompletion() async {
    final isComplete = await _profileService.isProfileComplete();

    if (mounted) {
      setState(() {
        _isProfileComplete = isComplete;
        _isLoading = false;
      });
    }
  }

  void _navigateToUpdateProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateUserProfile(
          userId: widget.userId,
          user: widget.user,
        ),
      ),
    ).then((_) {
      // Re-check profile completion when returning from profile update screen
      _checkProfileCompletion();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(); // Return empty during loading
    }

    // If profile is incomplete and we should show update prompt
    if (!_isProfileComplete && widget.showUpdateProfilePrompt) {
      return _buildUpdateProfilePrompt(context);
    }

    // Otherwise, return the builder with current completion status
    return widget.builder(context, _isProfileComplete);
  }

  Widget _buildUpdateProfilePrompt(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 48,
            color: Colors.orangeAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Complete Your Profile',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You need to complete your profile before you can add posts or access other features.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _navigateToUpdateProfile(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}

/// Extension method to easily check if an action requires a complete profile
extension ProfileActionExtension on BuildContext {
  /// Performs an action only if profile is complete, otherwise navigates to update profile
  void performWithProfileCheck({
    required VoidCallback action,
    required User user,
    required int userId,
  }) async {
    final profileService = ProfileCompletionService();
    final isComplete = await profileService.isProfileComplete();

    if (isComplete) {
      action();
    } else {
      if (!mounted) return;

      Navigator.push(
        this,
        MaterialPageRoute(
          builder: (context) => UpdateUserProfile(
            userId: userId,
            user: user,
          ),
        ),
      ).then((_) {
        // Refresh profile completion status after returning
        profileService.updateProfileCompletionStatus();
      });
    }
  }
}