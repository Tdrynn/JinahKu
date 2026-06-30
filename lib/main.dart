import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinahku/pages/main_pages.dart';
import 'package:jinahku/pages/onboarding/onboardingPage.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  String languageCode = 'id';
  late Future<bool> _isFirstTime;

  @override
  void initState() {
    super.initState();
    _isFirstTime = DBHelper.isFirstTime();
  }

  void finishOnboarding() {
    setState(() {
      _isFirstTime = DBHelper.isFirstTime();
    });
  }

  void restartOnboarding() {
    setState(() {
      _isFirstTime = DBHelper.isFirstTime();
    });
  }

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
        SystemChrome.setSystemUIOverlayStyle(
          isDark
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                )
              : const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(languageCode),
          supportedLocales: const [Locale('en'), Locale('id')],
          localizationsDelegates: AppLocalizations.localizationsDelegates,

          home: FutureBuilder<bool>(
            future: _isFirstTime,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.data!) {
                return onboardingPage(
                  isDark: isDark,
                  isEnglish: languageCode == 'en',
                  onToggleTheme: toggleTheme,
                  onChangeLanguage: changeLanguage,
                  finishOnboarding: finishOnboarding,
                );
              }

              return MainPage(
                isDark: isDark,
                isEnglish: languageCode == 'en',
                onToggleTheme: toggleTheme,
                onChangeLanguage: changeLanguage,
                restartOnBoarding: restartOnboarding,
              );
            },
          ),
        );
      },
    );
  }
}
