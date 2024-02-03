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
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/home_screen_list_appBar_icon.dart';
import 'package:talbna/screens/reel/reels_screen.dart';
import 'package:talbna/screens/service_post/main_post_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;
  bool showSubcategoryGridView = false;
  int _selectedCategory = 1;
  final Language language = Language();

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
        return Icons.work_outline_outlined;
      case 2:
        return Icons.devices;
      case 3:
        return Icons.home_outlined;
      case 7:
        return Icons.play_circle_sharp;
      case 4:
        return Icons.directions_car_sharp;
      case 5:
        return Icons.room_service_outlined;
      case 6:
        return Icons.my_location;
      default:
        return Icons.work_outline_outlined;
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
        language.getLanguage();
        showSubcategoryGridView = value;
      });
    });
    _userProfileBloc = BlocProvider.of<UserProfileBloc>(context);
    _servicePostBloc = BlocProvider.of<ServicePostBloc>(context);
    _userProfileBloc.add(UserProfileRequested(id: widget.userId));
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

  final List<Category> _categories = [
    Category(id: 1, name: ''),
    Category(id: 2, name: ''),
    Category(id: 3, name: ''),
    Category(id: 7, name: ''),
    Category(id: 4, name: ''),
    Category(id: 5, name: ''),
    Category(id: 6, name: ''),
  ];

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
    language.getLanguage();

    _categories[0].name = language.tJobTextHome();
    _categories[1].name = language.tDeviceTextHome();
    _categories[2].name = language.tRealEstateTextHome();
    _categories[3].name = language.tVideoTextHome();
    _categories[4].name = language.tCarsTextHome();
    _categories[5].name = language.tServicesTextHome();
    _categories[6].name = language.tNearYouText();

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
              title: Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 0, 0),
                child: Row(
                  children: [
                    Text(
                      'TALAB',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: GoogleFonts.bungee().fontFamily,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightSecondaryColor
                            : AppTheme.darkPrimaryColor,
                      ),
                    ),
                    Text(
                      'NA',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: GoogleFonts.bungee().fontFamily,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppTheme.lightBackgroundColor
                            : AppTheme.lightBackgroundColor,
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
                ? MainMenuPostScreen(
              key: ValueKey(_selectedCategory),
              category: _selectedCategory,
              userID: widget.userId,
              servicePostBloc: _servicePostBloc,
              showSubcategoryGridView: showSubcategoryGridView,
              user: user,
            )
                : Container(),
            bottomNavigationBar: BottomAppBar(
              elevation: 0,
              height: 55,
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
                          child: Icon(
                            _getCategoryIcon(category),
                            size: isSelected ? 30 : 25,
                            color: isSelected ? Theme.of(context).brightness == Brightness.dark ? AppTheme.lightSecondaryColor : AppTheme.darkPrimaryColor : Colors.white70,
                          ),
                        ),
                        // Text(
                        //   category.name,
                        //   style: TextStyle(
                        //     color: isSelected
                        //         ? Theme.of(context).brightness == Brightness.dark
                        //         ? AppTheme.lightPrimaryColor
                        //         : AppTheme.darkPrimaryColor
                        //         : Colors.grey,
                        //     fontSize: 7,
                        //     overflow: TextOverflow.ellipsis,
                        //   ),
                        // )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return const Center(child: Text('No user home data found.'));
        }
      },
    );
  }
}