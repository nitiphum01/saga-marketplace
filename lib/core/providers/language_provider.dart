import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  bool get isThai => _locale.languageCode == 'th';

  void toggleLanguage() {
    _locale = isThai ? const Locale('en') : const Locale('th');
    notifyListeners();
  }
}
