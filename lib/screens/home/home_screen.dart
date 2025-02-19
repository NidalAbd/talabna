import 'package:flutter/material.dart';
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
import 'package:talbna/main.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/home_screen_list_appBar_icon.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';
import 'package:talbna/data/repositories/categories_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late CategoriesRepository _categoryRepository;

  bool showSubcategoryGridView = false;
  int _selectedCategory = 1;
  late List<Category> _categories = [];
  bool isLoading = true;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }

  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (canToggle == true) {
      setState(() {
        showSubcategoryGridView = !showSubcategoryGridView;
      });
      await _saveShowSubcategoryGridView(showSubcategoryGridView);
    }
  }

  IconData _getCategoryIcon(Category category) {
    switch (category.id) {
      case 1:
        return Icons.work_outline_rounded;
      case 2:
        return Icons.devices_rounded;
      case 3:
        return Icons.home_rounded;
      case 7:
        return Icons.play_circle_rounded;
      case 4:
        return Icons.directions_car_rounded;
      case 5:
        return Icons.miscellaneous_services_rounded;
      case 6:
        return Icons.location_on_rounded;
      default:
        return Icons.work_outline_rounded;
    }
  }

  Future<bool> _loadShowSubcategoryGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showSubcategoryGridView') ?? false;
  }

  @override
  void initState() {
    super.initState();
    print('HomeScreen: initState started');

    // Initialize animation controller
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

    _animationController.forward();

    _loadShowSubcategoryGridView().then((value) {
      setState(() {
        showSubcategoryGridView = value;
      });
      print('Loaded showSubcategoryGridView: $showSubcategoryGridView');
    });

    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _categoryRepository = CategoriesRepository();

    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
    print('UserProfileRequested event dispatched with userId: ${widget.userId}');

    _fetchCategories();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      print('Fetching categories...');
      final categories = await _categoryRepository.getCategories();
      print('Categories fetched successfully: $categories');

      setState(() {
        _categories = categories;
        isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error fetching categories: $e');
      print('StackTrace: $stackTrace');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onCategorySelected(int categoryId, BuildContext context, User user) {
    setState(() {
      _selectedCategory = categoryId;
      if (_selectedCategory == 6 || _selectedCategory == 0) {
        _toggleSubcategoryGridView(canToggle: false);
      }

      if (_selectedCategory == 7) {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => ReelsHomeScreen(
              userId: widget.userId,
              user: user,
            ),
          ),
        )
            .then((value) {
          setState(() {
            _selectedCategory = 1;
          });
        });
      }
    });
  }

  Future<void> _saveDataToSharedPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.userName ?? '');
    prefs.setString('phones', user.phones ?? '');
    prefs.setString('watsNumber', user.watsNumber ?? '');
    prefs.setString(
        'country', user.country?.getName(language) ?? '');
    prefs.setString('city', user.city?.getName(language.toString()) ?? '');
    prefs.setString('gender', user.gender ?? '');
    prefs.setString('dob', user.dateOfBirth.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    // Initialize language at the start of the build method
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? Color(0xFF121212)
        : Color(0xFFF5F7FA);
    final cardColor = isDarkMode
        ? Color(0xFF1E1E1E)
        : Colors.white;
    final primaryColor = isDarkMode
        ? AppTheme.lightSecondaryColor
        : AppTheme.darkPrimaryColor;
    final navBarColor = isDarkMode
        ? Color(0xFF292929)
        : Colors.white;

    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (BuildContext context, UserProfileState state) {
        if (state is UserProfileInitial || state is UserProfileLoadInProgress) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                  ),
                ],
              ),
            ),
          );
        } else if (state is UserProfileLoadFailure) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    state.error,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _userProfileBloc.add(UserProfileRequested(id: widget.userId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is UserProfileLoadSuccess) {
          if (state.user.city == null ||
              state.user.locationLongitudes == null ||
              state.user.locationLatitudes == null ||
              state.user.phones == null ||
              state.user.watsNumber == null ||
              state.user.gender == null ||
              state.user.dateOfBirth == null) {
            // Handle incomplete profile later
          } else {
            _saveDataToSharedPreferences(state.user);
          }
          final user = state.user;
          if (isLoading) {
            return Scaffold(
              backgroundColor: backgroundColor,
              body: Center(child: CircularProgressIndicator(color: primaryColor)),
            );
          }
          if (_categories.isEmpty) {
            return Scaffold(
              backgroundColor: backgroundColor,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No categories available',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _fetchCategories,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Scaffold(
              backgroundColor: backgroundColor,
              appBar: AppBar(
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
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        'NA',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          color: isDarkMode ? Colors.white : Color(0xFF515C6F),
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
              ),
              body: _selectedCategory != 7
                  ? Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                ),
                child: MainMenuPostScreen(
                  key: ValueKey(_selectedCategory),
                  category: _selectedCategory,
                  userID: widget.userId,
                  servicePostBloc: _servicePostBloc,
                  showSubcategoryGridView: showSubcategoryGridView,
                  user: user,
                ),
              )
                  : Container(),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: navBarColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _categories.map((category) {
                        bool isSelected = _selectedCategory == category.id;
                        return GestureDetector(
                          onTap: () {
                            _onCategorySelected(category.id, context, user);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(isSelected ? 12 : 8),
                                decoration: isSelected
                                    ? BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                )
                                    : null,
                                child: Icon(
                                  _getCategoryIcon(category),
                                  size: isSelected ? 28 : 24,
                                  color: isSelected
                                      ? primaryColor
                                      : isDarkMode
                                      ? Colors.grey
                                      : Color(0xFF8F959E),
                                ),
                              ),
                              SizedBox(height: 4),

                              Text(
                                category.name[language.toString()] ?? category.name['en'] ?? 'Unknown',
                                style: TextStyle(
                                  color: isSelected
                                      ? primaryColor
                                      : isDarkMode
                                      ? Colors.grey
                                      : Color(0xFF8F959E),
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Center(child: Text('No user home data found.')),
          );
        }
      },
    );
  }
}