import 'package:flutter/material.dart';
import 'package:jinahku/pages/main_pages.dart';
import 'package:jinahku/pages/onboarding/onboardingPage.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
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
  bool isDark = false;
  String languageCode = 'id';

  /// TOGGLE THEME
  void toggleTheme(bool value) {
    setState(() {
      isDark = value;
    });
  }

  void changeLanguage(String lang) {
    setState(() {
      languageCode = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),

          darkTheme: ThemeData.dark(),

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(languageCode),

          supportedLocales: const [Locale('en'), Locale('id')],

          localizationsDelegates: AppLocalizations.localizationsDelegates,

          home: widget.isFirstTime
              ? onboardingPage(
                  isDark: isDark,
                  isEnglish: languageCode == 'en',
                  onToggleTheme: toggleTheme,
                  onChangeLanguage: changeLanguage,
                )
              : MainPage(
                  isDark: isDark,
                  isEnglish: languageCode == 'en',
                  onToggleTheme: toggleTheme,
                  onChangeLanguage: changeLanguage,
                ),
        );
      },
    );
  }
}
