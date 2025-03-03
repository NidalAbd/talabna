import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/home_screen_list_appBar_icon.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';
import 'package:talbna/data/repositories/categories_repository.dart';
import '../../utils/debug_logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userId});
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // BLoC and Repository instances
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CategoriesRepository _categoryRepository;
  final Language language = Language();

  // UI State
  bool showSubcategoryGridView = false;
  int _selectedCategory = 1;
  List<Category> _categories = [];
  bool isLoading = true;
  String currentLanguage = 'en';
  bool _justUpdated = false;
  bool _profileCompleted = false;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
    DebugLogger.printAllLogs();

    // Set system UI overlay style for consistent appearance
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setSystemUIOverlayStyle();
    });
  }

  // Apply consistent system UI colors
  void _setSystemUIOverlayStyle() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDarkMode ? AppTheme.darkPrimaryColor : Colors.white;
    final brightness = isDarkMode ? Brightness.light : Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: barColor,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarColor: barColor,
      systemNavigationBarIconBrightness: brightness,
    ));
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;
    _initializeControllers();
    if (!mounted) return;
    await _loadLanguage();
    if (!mounted) return;
    await _loadInitialData();
    if (mounted) {
      _animationController.forward();
    }
  }

  void _initializeControllers() {
    if (!mounted) return;

    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _categoryRepository = CategoriesRepository();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
  }

  Future<void> _loadLanguage() async {
    if (!mounted) return;
    final lang = await language.getLanguage();
    if (mounted) {
      setState(() {
        currentLanguage = lang;
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    await _loadShowSubcategoryGridView();
    if (!mounted) return;
    await _fetchCategories();
  }

  Future<void> _loadShowSubcategoryGridView() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        showSubcategoryGridView = prefs.getBool('showSubcategoryGridView') ?? false;
      });
    }
  }

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }

  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (!mounted) return;
    if (canToggle) {
      setState(() {
        showSubcategoryGridView = !showSubcategoryGridView;
      });
      await _saveShowSubcategoryGridView(showSubcategoryGridView);
    }
  }

  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1: return Icons.work_outline_rounded;
      case 2: return Icons.devices_rounded;
      case 3: return Icons.home_rounded;
      case 7: return Icons.play_circle_fill_rounded;
      case 4: return Icons.directions_car_rounded;
      case 5: return Icons.miscellaneous_services_rounded;
      case 6: return Icons.location_on_rounded;
      default: return Icons.work_outline_rounded;
    }
  }

  String _getCategoryName(Category category) {
    return category.name[currentLanguage] ?? category.name['en'] ?? 'Unknown';
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;

    try {
      final categories = await _categoryRepository.getCategories();
      if (!mounted) return;

      final arrangedCategories = _arrangeCategories(categories);
      if (mounted) {
        setState(() {
          _categories = arrangedCategories;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error fetching categories: $e\n$stackTrace');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<Category> _arrangeCategories(List<Category> categories) {
    final reelsCategory = categories.firstWhere(
          (category) => category.id == 7,
      orElse: () => categories.first,
    );

    final otherCategories = categories
        .where((category) => category.id != 7)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final middleIndex = otherCategories.length ~/ 2;
    return [
      ...otherCategories.sublist(0, middleIndex),
      reelsCategory,
      ...otherCategories.sublist(middleIndex),
    ];
  }

  void _onCategorySelected(int categoryId, BuildContext context, User user) {
    if (!mounted) return;

    setState(() => _selectedCategory = categoryId);

    if (categoryId == 6 || categoryId == 0) {
      _toggleSubcategoryGridView(canToggle: false);
    }

    if (categoryId == 7) {
      _navigateToReels(context, user);
    }
  }

  Future<void> _navigateToReels(BuildContext context, User user) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReelsHomeScreen(
          userId: widget.userId,
          user: user,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: Duration(milliseconds: 500),
      ),
    );
    if (mounted) {
      setState(() => _selectedCategory = 1);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) return Container();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Use consistent colors for all UI elements
    final backgroundColor = isDarkMode ? AppTheme.darkPrimaryColor : Colors.white;
    final primaryColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightPrimaryColor;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final iconColor = isDarkMode ? AppTheme.darkIconColor : AppTheme.lightIconColor;

    // Make sure system colors are consistent with theme
    _setSystemUIOverlayStyle();

    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        if (state is UserProfileUpdateSuccess && mounted) {
          _handleProfileUpdate();
        }
      },
      builder: (context, state) {
        if (!mounted) return Container();

        if (state is UserProfileLoadInProgress || state is UserProfileInitial) {
          return _buildLoadingScreen(backgroundColor, primaryColor);
        }

        if (state is UserProfileLoadFailure) {
          return _buildErrorScreen(state.error, backgroundColor, primaryColor);
        }

        if (state is UserProfileLoadSuccess) {
          final user = state.user;
          return _buildMainScreen(user, backgroundColor, primaryColor, textColor, iconColor);
        }

        return _buildEmptyScreen(backgroundColor);
      },
    );
  }

  void _handleProfileUpdate() {
    if (!mounted) return;

    setState(() {
      _justUpdated = true;
      _profileCompleted = true; // Mark profile as completed when it's updated
    });

    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _justUpdated = false;
        });
      }
    });

    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
  }

  Widget _buildLoadingScreen(Color backgroundColor, Color primaryColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
  }

  Widget _buildErrorScreen(String error, Color backgroundColor, Color primaryColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _userProfileBloc.add(UserProfileRequested(id: widget.userId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScreen(Color backgroundColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(child: Text('No user home data found.')),
    );
  }

  Widget _buildMainScreen(User user, Color backgroundColor, Color primaryColor, Color textColor, Color iconColor) {
    if (isLoading) {
      return _buildLoadingScreen(backgroundColor, primaryColor);
    }

    if (_categories.isEmpty) {
      return _buildEmptyCategoriesScreen(backgroundColor, primaryColor);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(user, backgroundColor, primaryColor, textColor),
        body: _buildBody(user, backgroundColor),
        bottomNavigationBar: _buildBottomNavBar(user, backgroundColor, primaryColor, textColor, iconColor),
      ),
    );
  }

  Widget _buildEmptyCategoriesScreen(Color backgroundColor, Color primaryColor) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 60),
            SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(User user, Color backgroundColor, Color primaryColor, Color textColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = GoogleFonts.poppins().fontFamily;

    // Use consistent accent color for logo
    final accentColor = isDarkMode ? AppTheme.darkSecondaryColor : AppTheme.lightSecondaryColor;

    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
        child: Row(
          children: [
            Text(
              'TALAB',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: accentColor,
              ),
            ),
            Text(
              'NA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      actions: [
        VertIconAppBar(
          userId: widget.userId,
          user: user,
          showSubcategoryGridView: showSubcategoryGridView,
          toggleSubcategoryGridView: _toggleSubcategoryGridView,
        ),
      ],
    );
  }

  Widget _buildBody(User user, Color backgroundColor) {
    if (!mounted) return Container();

    if (_selectedCategory == 7) {
      return Container();
    }

    return Container(
      decoration: BoxDecoration(color: backgroundColor),
      child: MainMenuPostScreen(
        key: ValueKey(_selectedCategory),
        category: _selectedCategory,
        userID: widget.userId,
        servicePostBloc: _servicePostBloc,
        showSubcategoryGridView: showSubcategoryGridView,
        user: user,
      ),
    );
  }

  Widget _buildBottomNavBar(User user, Color backgroundColor, Color primaryColor, Color textColor, Color iconColor) {
    if (!mounted) return Container();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.06),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _categories.map((category) {
                  if (category.id == 7) {
                    return SizedBox(width: 50);
                  }

                  bool isSelected = _selectedCategory == category.id;
                  return _buildNavItem(
                    category: category,
                    isSelected: isSelected,
                    user: user,
                    primaryColor: primaryColor,
                    iconColor: iconColor,
                    textColor: textColor,
                  );
                }).toList(),
              ),
            ),
            if (_hasReelsCategory)
              Positioned(
                top: 5,
                child: _buildReelsButton(
                  reelsCategory: _getReelsCategory()!,
                  user: user,
                  primaryColor: primaryColor,
                ),
              ),
            if (_hasReelsCategory)
              Positioned(
                bottom: 8,
                child: _buildReelsLabel(
                  reelsCategory: _getReelsCategory()!,
                  primaryColor: primaryColor,
                  textColor: textColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool get _hasReelsCategory => _categories.any((c) => c.id == 7);

  Category? _getReelsCategory() {
    try {
      return _categories.firstWhere((c) => c.id == 7);
    } catch (e) {
      return null;
    }
  }

  Widget _buildNavItem({
    required Category category,
    required bool isSelected,
    required User user,
    required Color primaryColor,
    required Color iconColor,
    required Color textColor,
  }) {
    if (!mounted) return Container();

    return GestureDetector(
      onTap: () => _onCategorySelected(category.id, context, user),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 10 : 8),
            decoration: isSelected
                ? BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            )
                : null,
            constraints: BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            child: Icon(
              _getCategoryIcon(category.id),
              size: 20,
              color: isSelected ? primaryColor : iconColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _getCategoryName(category),
            style: TextStyle(
              color: isSelected ? primaryColor : textColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReelsButton({
    required Category reelsCategory,
    required User user,
    required Color primaryColor,
  }) {
    if (!mounted) return Container();

    return GestureDetector(
      onTap: () => _onCategorySelected(reelsCategory.id, context, user),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.25),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              Color.lerp(primaryColor, Colors.black, 0.15) ?? primaryColor,
            ],
          ),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _selectedCategory == 7
                  ? Colors.white.withOpacity(0.8)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReelsLabel({
    required Category reelsCategory,
    required Color primaryColor,
    required Color textColor,
  }) {
    if (!mounted) return Container();

    return AnimatedOpacity(
      opacity: _selectedCategory == 7 ? 1.0 : 1.0,
      duration: Duration(milliseconds: 200),
      child: Text(
        _getCategoryName(reelsCategory),
        style: TextStyle(
          color: _selectedCategory == 7 ? primaryColor : textColor,
          fontSize: 12,
          fontWeight: _selectedCategory == 7 ? FontWeight.w600 : FontWeight.normal,
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
      ),
    );
  }
}