import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../provider/language.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  _LanguageSelectionScreenState createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final Language _language = Language();
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
  String selectedLanguage = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedLanguage = prefs.getString('language');

    // If no language is selected, set a default language (e.g., 'ar')
    setState(() {
      this.selectedLanguage = selectedLanguage ?? 'ar';
    });
  }
  Future<void> _showLanguageChangeConfirmationDialog() async {
    bool? confirmChange = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Language'),
          content: const Text('Are you sure you want to change the language?'),
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

      // Restart the app
      SystemNavigator.pop();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Language'),
      ),
      body: ListView(
        children: [
          for (String language in _languages)
            Padding(
              padding: const EdgeInsets.all(0),
              child: Card(
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
            ),
        ],
      ),
    );
  }
}
