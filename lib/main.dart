import 'package:flutter/material.dart';
import 'package:jinahku/pages/homepage.dart';
import 'package:jinahku/pages/onboarding/onboardingPage.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/pages/category.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isFirstTime = await DBHelper.isFirstTime();

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatefulWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode themeMode = ThemeMode.system;
  Locale? locale;

  void toggleTheme(bool isDark) {
    setState(() {
      themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void changeLanguage(String lang) {
    setState(() {
      locale = Locale(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ================= THEME =================
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode,

      // ================= L10N =================
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('id')],
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // ================= ROUTING =================
      // home: widget.isFirstTime
      //     ? onboardingPage(
      //         isDark: themeMode == ThemeMode.dark,
      //         isEnglish: locale?.languageCode == 'en',
      //         onToggleTheme: toggleTheme,
      //         onChangeLanguage: changeLanguage,
      //       )
      //     : homepage(
      //         isDark: themeMode == ThemeMode.dark,
      //         isEnglish: locale?.languageCode == 'en',
      //         onToggleTheme: toggleTheme,
      //         onChangeLanguage: changeLanguage,
      //       ),
      // home: const KategoriScreen(),
    );
  }
}
