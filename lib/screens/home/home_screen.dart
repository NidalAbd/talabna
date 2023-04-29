import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/blocs/service_post/service_post_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_bloc.dart';
import 'package:talbna/blocs/user_profile/user_profile_event.dart';
import 'package:talbna/blocs/user_profile/user_profile_state.dart';
import 'package:talbna/data/models/categories.dart';
import 'package:talbna/data/repositories/service_post_repository.dart';
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
import 'package:talbna/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late UserProfileBloc _userProfileBloc;
  late ServicePostBloc _servicePostBloc;

  int _selectedCategory = 1;

  final List<Category> _categories = [
    Category(id: 1, name: 'وظائف'),
    Category(id: 2, name: 'اجهزة'),
    Category(id: 3, name: 'عقارات'),
    Category(id: 4, name: 'سيارات'),
    Category(id: 5, name: 'خدمات'),
  ];
  // Define a function to get the icon for a category
  Widget _getCategoryIcon(Category category) {
    switch (category.id) {
      case 1:
        return const Icon(Icons.work , color: Colors.white,);
      case 2:
        return const Icon(Icons.devices , color: Colors.white,);
      case 3:
        return const Icon(Icons.home , color: Colors.white,);
      case 4:
        return const Icon(Icons.car_rental , color: Colors.white,);
      case 5:
        return const Icon(Icons.cleaning_services ,color: Colors.white,);
      default:
        return const Icon(Icons.category , color: Colors.white,);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        return Scaffold(
          appBar: AppBar(
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                LogoTitle(fontSize: 25, playAnimation: false, logoSize: 33,),

              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  backgroundColor: const Color.fromARGB(238, 249, 230, 248),
                  radius: 18,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                        '${Constants.apiBaseUrl}/storage/${user.photos?.first.src}'),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 30,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add_circle),
                            title: const Text('add post'),
                            onTap: () {
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
                            leading: const Icon(Icons.favorite),
                            title: const Text('Favorite'),
                            onTap: () {
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
          body: Center(
            child: ServicePostScreen(
              key: ValueKey(_selectedCategory),
              category: _selectedCategory,
              userID: widget.userId,
              servicePostBloc: _servicePostBloc,
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedCategory - 1,
            onTap: (int index) {
              setState(() {
                _selectedCategory = index + 1;
              });
            },
            items: _categories
                .map(
                  (category) => BottomNavigationBarItem(
                    icon: _getCategoryIcon(
                        category),
                    // Set the icon for the category
                    label: category.name, // Set the name for the category

                    backgroundColor: AppTheme.primaryColor,
                  ),
                )
                .toList(),
          ),
        );
      } else {
        return const Center(child: Text('No user home data found.'));
      }
    });
  }
}
