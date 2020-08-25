//import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
//import 'dart:convert' show json;
//
//class AppLocalization {
//  final Locale locale;
//
//  AppLocalization(this.locale);
//
//  static AppLocalization of(BuildContext context) {
//    return Localizations.of<AppLocalization>(context, AppLocalization);
//  }
//
//  static const LocalizationsDelegate<AppLocalization> delegate = AppLocalizationDelegate();
//
//  Map<String, String> _localizedStrings;
//
//  void loadNewLanguage(Locale _newLocale) async {
//    String jsonString =
//    await rootBundle.loadString('res/languages/${_newLocale.languageCode}.json');
//    Map<String, dynamic> jsonMap = json.decode(jsonString);
//
//    _localizedStrings = jsonMap.map((key, value) {
//      return MapEntry(key, value.toString());
//    });
//
//  }
//
//  Future<bool> load() async {
//    String jsonString =
//    await rootBundle.loadString('res/languages/${locale.languageCode}.json');
//    Map<String, dynamic> jsonMap = json.decode(jsonString);
//
//    _localizedStrings = jsonMap.map((key, value) {
//      return MapEntry(key, value.toString());
//    });
//
//    return true;
//  }
//
//  String translate(String key) {
//    return _localizedStrings[key];
//  }
//}
//
//
//class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
//  const AppLocalizationDelegate();
//
//  @override
//  bool isSupported(Locale locale) {
//    return ['en', 'ar'].contains(locale.languageCode);
//  }
//
//  @override
//  Future<AppLocalization> load(Locale locale) async {
//    AppLocalization localizations = new AppLocalization(locale);
//    await localizations.load();
//    return localizations;
//  }
//
//  @override
//  bool shouldReload(AppLocalizationDelegate old) => false;
//}