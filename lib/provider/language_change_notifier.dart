import 'package:flutter/material.dart';

// A language change notifier that can be used to rebuild the entire app
class LanguageChangeNotifier extends ChangeNotifier {
  static final LanguageChangeNotifier _instance = LanguageChangeNotifier._internal();

  factory LanguageChangeNotifier() {
    return _instance;
  }

  LanguageChangeNotifier._internal();

  void notifyLanguageChanged() {
    notifyListeners();
  }
}

// Widget that rebuilds when language changes
class LanguageChangeBuilder extends StatefulWidget {
  final Widget Function(BuildContext context) builder;

  const LanguageChangeBuilder({
    super.key,
    required this.builder,
  });

  @override
  State<LanguageChangeBuilder> createState() => _LanguageChangeBuilderState();
}

class _LanguageChangeBuilderState extends State<LanguageChangeBuilder> {
  final LanguageChangeNotifier _notifier = LanguageChangeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_handleLanguageChange);
  }

  @override
  void dispose() {
    _notifier.removeListener(_handleLanguageChange);
    super.dispose();
  }

  void _handleLanguageChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}