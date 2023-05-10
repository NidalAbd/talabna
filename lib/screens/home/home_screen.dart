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
import 'package:talbna/screens/home/notification_alert_widget.dart';
import 'package:talbna/screens/interaction_widget/logo_title.dart';
import 'package:talbna/screens/interaction_widget/logout_list_tile.dart';
import 'package:talbna/screens/interaction_widget/theme_toggle.dart';
import 'package:talbna/screens/profile/change_email_screen.dart';
import 'package:talbna/screens/profile/change_password_screen.dart';
import 'package:talbna/screens/service_post/favorite_post_screen.dart';
import 'package:talbna/screens/profile/profile_edit_screen.dart';
import 'package:talbna/screens/profile/profile_screen.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/service_post/service_post_category.dart';
import 'package:talbna/screens/service_post/create_service_post_form.dart';

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
    if(canToggle == true){
       showSubcategoryGridView = !showSubcategoryGridView ;
    }else{
      if(_selectedCategory == 6 || _selectedCategory == 0) showSubcategoryGridView = false;
    }
    await _saveShowSubcategoryGridView(showSubcategoryGridView);
    setState(() {});
  }
  final List<Category> _categories = [
    Category(id: 1, name: 'وظائف'),
    Category(id: 2, name: 'اجهزة'),
    Category(id: 3, name: 'عقارات'),
    Category(id: 0, name: ''),
    Category(id: 4, name: 'سيارات'),
    Category(id: 5, name: 'خدمات'),
    Category(id: 6, name: 'قريبا منك'),
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
      case 0:
        return const SizedBox(
          width: 80,
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
        final user = state.user;
        return SafeArea(
          child: Scaffold(
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
                        color: Colors.yellow),
                  ),
                ],
              ),
              actions: [
                NotificationsAlert(userID: widget.userId),
                IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 30,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return ListView(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.add_circle),
                              title: const Text('add post'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServicePostFormScreen(
                                        userId: widget.userId),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Profile'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      fromUser: widget.userId,
                                      toUser: widget.userId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.favorite),
                              title: const Text('Favorite'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FavoritePostScreen(userID: user.id),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.update),
                              title: const Text('Update Info'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UpdateUserProfile(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: const Text('Add Points'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PurchaseRequestScreen(
                                      userID: user.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Change Email'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChangeEmailScreen(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.lock),
                              title: const Text('Change Password'),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ChangePasswordScreen(
                                      userId: user.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ThemeToggleListTile(),
                            const LogoutListTile(),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            body: ServicePostScreen(
              key: ValueKey(_selectedCategory),
              category: _selectedCategory,
              userID: widget.userId,
              servicePostBloc: _servicePostBloc,
              showSubcategoryGridView:showSubcategoryGridView,
            ),
            bottomNavigationBar: BottomAppBar(
              height: 70,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _categories.map((category) =>
                    Column(
                      children: [
                        IconButton(
                          icon: _getCategoryIcon(category),
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category.id;
                              if(_selectedCategory == 6 || _selectedCategory == 0)_toggleSubcategoryGridView(canToggle: false);
                            });
                          },
                        ),
                        Text(category.name,style: const TextStyle(color: Colors.white,fontSize: 12),)
                      ],
                    ),
                ).toList(),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                 await _toggleSubcategoryGridView(canToggle: true);
              },
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor,
              child:  Icon(showSubcategoryGridView? Icons.list : Icons.grid_view_rounded,color: Colors.white,),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          ),
        );
      } else {
        return const Center(child: Text('No user home data found.'));
      }
    });
  }
}
