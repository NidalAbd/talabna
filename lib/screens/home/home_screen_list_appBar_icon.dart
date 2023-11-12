import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/app_theme.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/main.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/home/search_screen.dart';
import 'package:talbna/screens/home/setting_screen.dart';
import 'package:talbna/screens/interaction_widget/logout_list_tile.dart';
import 'package:talbna/screens/interaction_widget/theme_toggle.dart';
import 'package:talbna/screens/profile/change_email_screen.dart';
import 'package:talbna/screens/profile/change_password_screen.dart';
import 'package:talbna/screens/profile/profile_edit_screen.dart';
import 'package:talbna/screens/profile/profile_screen.dart';
import 'package:talbna/screens/profile/purchase_request_screen.dart';
import 'package:talbna/screens/service_post/create_service_post_form.dart';
import 'package:talbna/screens/service_post/favorite_post_screen.dart';

import 'notification_alert_widget.dart';

class VertIconAppBar extends StatefulWidget {
  const VertIconAppBar({super.key, required this.userId, required this.user});
  final int userId;
  final User user;
  @override
  State<VertIconAppBar> createState() => _VertIconAppBarState();
}

class _VertIconAppBarState extends State<VertIconAppBar> {
  final Language language = Language();

  @override
  void initState() {
    super.initState();
    setState(() {
      language.getLanguage();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: () async {
            bool loadedUser = await _checkDataCompletion();
            if (loadedUser) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServicePostFormScreen(userId: widget.userId),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Builder(
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Incomplete Information'),
                        content: const Text('Please complete your information.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UpdateUserProfile(
                                    userId: widget.user.id, user: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.search_rounded,size: 30,),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen( userID: widget.userId, user: widget.user,),
              ),
            );
          },
        ),
        NotificationsAlert(userID: widget.userId),
        IconButton(
          icon: const Icon(
            Icons.more_vert,
            size: 30,
          ),
          onPressed: () async {
            bool loadedUser = await _checkDataCompletion();
            if (loadedUser) {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 325,
                    child: ListView(
                        children: [
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.person),
                              title:  Text(language.tProfileText()),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      fromUser: widget.userId,
                                      toUser: widget.userId, user: widget.user,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.favorite),
                              title:  Text(language.tFavoriteText()),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FavoritePostScreen(userID: widget.user.id, user: widget.user,),
                                  ),
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.update),
                              title:  Text(language.tUpdateInfoText()),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => UpdateUserProfile(
                                      userId: widget.user.id, user: widget.user,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.attach_money),
                              title:  Text(language.tPurchasePointsText()),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PurchaseRequestScreen(
                                          userID: widget.user.id,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.settings),
                              title:  Text(language.tSettingsText()),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SettingScreen(userId: widget.userId, user: widget.user,
                                        )
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                  );
                },
              );
            } else {
              // User data is not available, display a message or take appropriate action
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:  Text(language.incompleteInformationText()),
                    content:
                     Text(language.completeInformationText()),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => UpdateUserProfile(
                                userId: widget.user.id, user: widget.user,
                              ),
                            ),
                          );
                        },
                        child:  Text(language.okText()),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }


  Future<bool> _checkDataCompletion() async {
    print('_checkDataCompletion');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    String? phones = prefs.getString('phones');
    String? watsNumber = prefs.getString('watsNumber');
    String? gender = prefs.getString('gender');
    String? dobString = prefs.getString('dob');
    return userName != null &&
        phones != null &&
        watsNumber != null &&
        gender != null &&
        dobString != null;
  }
}
