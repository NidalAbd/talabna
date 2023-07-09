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
import 'package:talbna/screens/home/home_screen_list_appBar_icon.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  late bool showSubcategoryGridView = false;
  int _selectedCategory = 1;

  Future<void> _saveShowSubcategoryGridView(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSubcategoryGridView', value);
  }

  Future<void> _toggleSubcategoryGridView({required bool canToggle}) async {
    if (canToggle == true) {
      showSubcategoryGridView = !showSubcategoryGridView;
    } else {
      if (_selectedCategory == 6 || _selectedCategory == 0) {
        showSubcategoryGridView = false;
      }


    }
    await _saveShowSubcategoryGridView(showSubcategoryGridView);
    setState(() {});
  }
  void _onCategorySelected(int categoryId, BuildContext context) {
    setState(() {
      _selectedCategory = categoryId;
      if (_selectedCategory == 6 || _selectedCategory == 0) {
        _toggleSubcategoryGridView(canToggle: false);
      }

      // Navigate to ReelsHomeScreen if category 7 is selected
      if (_selectedCategory == 7) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReelsHomeScreen(
              userId: widget.userId,
            ),
          ),
        ).then((value) {
          // When you navigate back from the ReelsHomeScreen, select category 1
          setState(() {
            _selectedCategory = 1;
          });
        });
      }
    });
  }
  final List<Category> _categories = [
    Category(id: 1, name: 'وظائف'),
    Category(id: 2, name: 'اجهزة'),
    Category(id: 3, name: 'عقارات'),
    Category(id: 7, name: 'فيديو'),
    Category(id: 4, name: 'سيارات'),
    Category(id: 5, name: 'خدمات'),
    Category(id: 6, name: 'بقربك'),
  ];
  // Define a function to get the icon for a category
  Widget _getCategoryIcon(Category category) {
    switch (category.id) {
      case 1:
        return const Icon(
          Icons.work,
          color: Colors.white,
        );
      case 2:
        return const Icon(
          Icons.devices,
          color: Colors.white,
        );
      case 3:
        return const Icon(
          Icons.home,
          color: Colors.white,
        );
      case 7:
        return const Icon(
          Icons.play_circle,
          color: Colors.white,
        );

      case 4:
        return const Icon(
          Icons.car_rental,
          color: Colors.white,
        );
      case 5:
        return const Icon(
          Icons.cleaning_services,
          color: Colors.white,
        );
      case 6:
        return const Icon(
          Icons.my_location,
          color: Colors.white,
        );
      default:
        return const Icon(
          Icons.category,
          color: Colors.white,
        );
    }
  }

  Future<bool> _loadShowSubcategoryGridView() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showSubcategoryGridView') ?? false;
  }

  @override
  void initState() {
    super.initState();
    _loadShowSubcategoryGridView().then((value) {
      setState(() {
        showSubcategoryGridView = value;
      });
    });
    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc.add(UserProfileRequested(id: widget.userId)); // Added line
  }

  Future<void> _saveDataToSharedPreferences(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userName', user.userName!);
    prefs.setString('phones', user.phones!);
    prefs.setString('watsNumber', user.watsNumber!);
    prefs.setString('country', user.country!.name);
    prefs.setString('city', user.city!.name);
    prefs.setString('gender', user.email);
    prefs.setString('dob', user.email);
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (BuildContext context, UserProfileState state) {
          if (state is UserProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoadFailure) {
            return Center(child: Text(state.error));
          } else if (state is UserProfileLoadSuccess) {
            if (state.user.city == null ||
                state.user.locationLongitudes == null ||
                state.user.locationLatitudes == null ||
                state.user.phones == null ||
                state.user.watsNumber == null ||
                state.user.gender == null ||
                state.user.dateOfBirth == null) {
            } else {
              _saveDataToSharedPreferences(state.user);
            }
            final user = state.user;

            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Row(
                  children: [
                    Text(
                      'TALB',
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: GoogleFonts.bungee().fontFamily,
                          color: Colors.white),
                    ),
                    Text(
                      'NA',
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: GoogleFonts.bungee().fontFamily,
                          color: AppTheme.accentColor
                      ),
                    ),
                  ],
                ),
                actions: [
                VertIconAppBar(userId: widget.userId, user: user)
                ],
              ),
              body: _selectedCategory != 7
                  ? MainMenuPostScreen(
                key: ValueKey(_selectedCategory),
                category: _selectedCategory,
                userID: widget.userId,
                servicePostBloc: _servicePostBloc,
                showSubcategoryGridView: showSubcategoryGridView,
              )
                  : Container(),
              bottomNavigationBar: BottomAppBar(
                height: 70,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor,
                shape: const CircularNotchedRectangle(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _categories
                      .map(
                        (category) => Column(
                      children: [
                        IconButton(
                          icon: _getCategoryIcon(category),
                          onPressed: () {
                            _onCategorySelected(category.id, context);
                          },
                        ),
                        Text(
                          category.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                heroTag: "unique_tag_2",
                onPressed: () async {
                  await _toggleSubcategoryGridView(canToggle: true);
                },
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor,
                child: Icon(
                  showSubcategoryGridView ? Icons.list : Icons.grid_view_rounded,
                  color: Colors.white,
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            );
          } else {
            return const Center(child: Text('No user home data found.'));
          }
        });
  }
}
