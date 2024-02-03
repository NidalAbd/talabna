import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talbna/data/models/user.dart';
import 'package:talbna/provider/language.dart';
import 'package:talbna/screens/profile/change_email_screen.dart';
import 'package:talbna/screens/profile/change_password_screen.dart';

import '../interaction_widget/logout_list_tile.dart';
import '../interaction_widget/theme_toggle.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key, required this.userId, required this.user});
  final int userId;
  final User user;
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final Language _language = Language();
  final List<String> _languages = [
    'العربية',
    'English',
    'Español',
    '中文',
    'हिन्दी',
    'Português',
    'Русский',
    '日本語',
    'Français',
    'Deutsch',
  ];
  String selectedLanguage = '';
  Future<void> _showLanguageChangeConfirmationDialog() async {
    bool? confirmChange = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Language'),
          content: Text('Are you sure you want to change the language?'),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(
                Icons.cancel, // Replace 'Icons.cancel' with the icon you want
                // You can adjust the size and color of the icon as needed
              ),
              label: Text('Cancel'), // Replace 'Cancel' with your desired label
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton.icon(
              icon: const Icon(
                Icons.check, // Replace 'Icons.check' with the icon you want
                // You can adjust the size and color of the icon as needed
              ),
              label: Text('Confirm'), // Replace 'Confirm' with your desired label
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            )
          ],
        );
      },
    );

    if (confirmChange == true) {
      // User confirmed language change
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('language', selectedLanguage);
      // You can set the new language using your BLoC or method
      // _language.setLanguage(selectedLanguage);

      // Restart the app
      SystemNavigator.routeInformationUpdated();
    }
  }
  @override
  void initState() {
    super.initState();
    _language.getLanguage(); // No need to call setState here
  }
  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (String language in _languages)
                Card(
                  child: ListTile(
                    title: Text(language),
                    trailing: const Icon(Icons.arrow_circle_right),
                    onTap: () async {
                      SharedPreferences pref = await SharedPreferences.getInstance();
                      pref.setString('language', language);
                      _language.setLanguage(language);
                      language = language;
                      setState(() {
                        selectedLanguage = language;
                      });
                      _showLanguageChangeConfirmationDialog();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: ListView(
        children: [
           Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.settings_sharp,
                  size: 200,
                ),
              ),
              Text(_language.tSettingsText(), style: const TextStyle(fontSize: 30),),
            ],
          ),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.language),
                title:  Text(_language.tChangeLanguageText()),
                onTap: () {
                  _showLanguageBottomSheet(context);
                },
                trailing: Text(selectedLanguage),
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.email),
                title:  Text(_language.tChangeEmailText()),
                trailing: const Icon(Icons.arrow_forward_outlined),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangeEmailScreen(
                        userId: widget.user.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: const Icon(Icons.lock),
                title:  Text(_language.tChangePasswordText()),
                trailing: const Icon(Icons.arrow_forward_outlined),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChangePasswordScreen(
                        userId: widget.user.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ThemeToggleListTile(language: _language,),
          )),
          Card(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LogoutListTile(language: _language,),
          )),
        ],
      ),
    );
  }
}
