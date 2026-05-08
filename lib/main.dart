import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/pages/homepage.dart';
import 'package:jinahku/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale _locale = const Locale('en');
  bool get isEnglish => _locale.languageCode == 'en';
  void changeLanguage(String code) {
    setState(() {
      _locale = Locale(code);
    });
  }

  ThemeMode _themeMode = ThemeMode.dark;
  bool get isDark => _themeMode == ThemeMode.dark;
  void toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JinahKu',

      locale: _locale,
      supportedLocales: [
        Locale('en'),
        Locale('id')
      ],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      home: homepage(
        isDark: isDark,
        isEnglish: isEnglish,
        onToggleTheme: toggleTheme,
        onChangeLanguage: changeLanguage,
      ),
    );
  }
}