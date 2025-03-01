import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/authentication/authentication_bloc.dart';
import 'package:talbna/blocs/authentication/authentication_event.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/routes.dart';
import 'package:talbna/theme_cubit.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

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
  String selectedLanguage = 'en'; // Default language

  // Welcome screen content with icons
  final List<Map<String, dynamic>> _welcomeContent = [];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeWelcomeContent();

    // Initialize animations
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

  Future<void> _loadLanguage() async {
    try {
      final lang = await _language.getLanguage();
      if (mounted) {
        setState(() {
          selectedLanguage = lang;
        });
      }
    } catch (e) {
      // Handle error
    }
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

  void _showLanguageBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final backgroundColor = isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    final List<String> _languages = [
      'ar',
      'en',
      'Español',
      '中文',
      'हिन्दी',
      'Português',
      'Русский',
      '日本語',
      'Français',
      'Deutsch',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  _language.tSelectLanguageText(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _languages.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final language = _languages[index];
                      final isSelected = selectedLanguage == language;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            language,
                            style: TextStyle(
                              color: isSelected ? primaryColor : textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: primaryColor)
                              : Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          onTap: () async {
                            SharedPreferences pref = await SharedPreferences.getInstance();
                            await pref.setString('language', language);
                            setState(() {
                              selectedLanguage = language;
                              _initializeWelcomeContent(); // Refresh content with new language
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
        child: Column(
          children: [
            // Top toolbar with language and theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Language selector
                  InkWell(
                    onTap: () => _showLanguageBottomSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedLanguage,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Theme toggle and skip
                  Row(
                    children: [
                      // Theme toggle
                      InkWell(
                        onTap: () {
                          BlocProvider.of<ThemeCubit>(context).toggleTheme();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDarkMode ? Icons.light_mode : Icons.dark_mode,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
        ),
      ),
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