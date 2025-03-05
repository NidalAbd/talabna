import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talbna/theme_cubit.dart';
import '../../provider/language_theme_selector.dart';
import '../../main.dart' as main;
import 'package:talbna/provider/language_change_notifier.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final Language _language = Language();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentPage = 0;
  final PageController _pageController = PageController();
  bool _isLanguageSelected = false;

  // Welcome screen content with icons
  final List<Map<String, dynamic>> _welcomeContent = [];

  @override
  void initState() {
    super.initState();
    _checkLanguageSelection();
    _initializeAnimations();
  }

  Future<void> _checkLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLanguage = prefs.getString('language') != null;

    setState(() {
      _isLanguageSelected = hasLanguage;
    });

    if (hasLanguage) {
      _initializeWelcomeContent();
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  void _initializeWelcomeContent() {
    _welcomeContent.clear();
    _welcomeContent.addAll([
      {
        'title': _language.tWelcomeText(),
        'description': _language.tWelcomeDescText(),
        'icon': Icons.thumb_up_alt_rounded,
      },
      {
        'title': _language.tDiscoverText(),
        'description': _language.tDiscoverDescText(),
        'icon': Icons.search_rounded,
      },
      {
        'title': _language.tConnectText(),
        'description': _language.tConnectDescText(),
        'icon': Icons.connect_without_contact_rounded,
      },
    ]);
  }
  void _onLanguageChanged() {
    // Clear and rebuild welcome content with new language
    setState(() {
      _welcomeContent.clear();
      _initializeWelcomeContent();
    });

    // Reset animation to show the new content with animation
    _animationController.reset();
    _animationController.forward();
  }
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _completeOnboarding() async {
    // Save that onboarding is completed
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);

    if (mounted) {
      Routes.navigateToLogin(context);
    }
  }

  Future<void> _handleThemeChange() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final newMode = !isDarkMode;

    await prefs.setBool('isDarkTheme', newMode);
    await prefs.setInt('selected_theme', newMode ? 1 : 0);

    if (context.mounted) {
      if (newMode) {
        context.read<ThemeCubit>().emit(AppTheme.darkTheme);
        AppTheme.setSystemBarColors(Brightness.dark, AppTheme.darkPrimaryColor, AppTheme.darkPrimaryColor);
      } else {
        context.read<ThemeCubit>().emit(AppTheme.lightTheme);
        AppTheme.setSystemBarColors(Brightness.light, AppTheme.lightPrimaryColor, AppTheme.lightPrimaryColor);
      }
    }
  }

  Future<void> _updateLanguage(String language) async {
    // Show loading dialog
    _showLoadingDialog();

    // Wait a brief moment to ensure dialog is visible
    await Future.delayed(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();

    // Update global language variable
    main.language = language;

    await prefs.setString('language', language);
    await _language.setLanguage(language);

    // Force rebuild by updating state
    setState(() {
      _isLanguageSelected = true;
      _initializeWelcomeContent();
    });

    // Notify all listeners that language has changed to rebuild the UI
    LanguageChangeNotifier().notifyLanguageChanged();

    // Close loading dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Start page animation
    _animationController.reset();
    _animationController.forward();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _language.getLanguage() == 'ar'
                        ? 'جاري تغيير اللغة...'
                        : 'Changing language...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    // Set system UI overlay style based on theme
    AppTheme.setSystemBarColors(
        isDarkMode ? Brightness.light : Brightness.dark,
        backgroundColor,
        backgroundColor
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: !_isLanguageSelected
            ? _buildLanguageSelectionScreen(isDarkMode, primaryColor, textColor)
            : _buildOnboardingScreen(isDarkMode, primaryColor, textColor),
      ),
    );
  }

  Widget _buildLanguageSelectionScreen(bool isDarkMode, Color primaryColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Theme toggle at the top
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: _handleThemeChange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // App logo or icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language,
              size: 70,
              color: primaryColor,
            ),
          ),

          const SizedBox(height: 40),

          // Welcome title text (in both languages)
          Text(
            "مرحبا بك في طلبنا\nWelcome to Talbna",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Subtitle text (in both languages)
          Text(
            "الرجاء اختيار لغتك المفضلة\nPlease select your preferred language",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 16,
              height: 1.5,
            ),
          ),

          const Spacer(flex: 1),

          // Language selection buttons
          _buildLanguageOption('ar', 'العربية', 'Arabic', isDarkMode, primaryColor),
          const SizedBox(height: 16),
          _buildLanguageOption('en', 'English', 'الإنجليزية', isDarkMode, primaryColor),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String langCode, String primaryText, String secondaryText, bool isDarkMode, Color primaryColor) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: InkWell(
              onTap: () => _updateLanguage(langCode),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.translate,
                      color: primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            primaryText,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            secondaryText,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnboardingScreen(bool isDarkMode, Color primaryColor, Color textColor) {
    return Column(
      children: [
        // Top toolbar with language and theme toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Language and theme selector
              LanguageThemeSelector(
                compactMode: true,
                showThemeToggle: true,
                showConfirmationDialog: false,
                onLanguageChanged: _onLanguageChanged,
              ),
              // Skip button
              TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  _language.tSkipText(),
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Page view for welcome content
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _welcomeContent.length,
            itemBuilder: (context, index) {
              return _buildWelcomePage(
                _welcomeContent[index]['title'],
                _welcomeContent[index]['description'],
                _welcomeContent[index]['icon'],
                primaryColor,
                textColor,
              );
            },
          ),
        ),

        // Pagination dots
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _welcomeContent.length,
                  (index) => _buildDot(index, primaryColor),
            ),
          ),
        ),

        // Show auth buttons on last page, otherwise Next button
        _currentPage == _welcomeContent.length - 1
            ? _buildAuthButtons(context, primaryColor, isDarkMode)
            : _buildNextButton(primaryColor, isDarkMode),

        // Add padding at the bottom
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context, Color primaryColor, bool isDarkMode) {
    final secondaryColor = isDarkMode
        ? AppTheme.darkPrimaryColor
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDarkMode ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: () {
                Routes.navigateToLogin(context);
              },
              child: Text(
                _language.loginText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Register button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 2),
                backgroundColor: secondaryColor.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Routes.navigateToRegister(context);
              },
              child: Text(
                _language.tRegisterText(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(Color primaryColor, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    _language.tNextText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomePage(
      String title,
      String description,
      IconData icon,
      Color primaryColor,
      Color textColor,
      ) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon placeholder instead of image
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: _buildIconPlaceholder(icon, primaryColor),
                    ),
                  ),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  // Space at the bottom
                  const Expanded(flex: 2, child: SizedBox()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconPlaceholder(IconData icon, Color primaryColor) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 100,
        color: primaryColor,
      ),
    );
  }

  Widget _buildDot(int index, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? primaryColor : primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}