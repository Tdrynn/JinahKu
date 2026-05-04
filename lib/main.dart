import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/database/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  // Bahasa
  Locale _locale = Locale('en');
  void _changeLanguage(String code) {
    setState(() {
      _locale = Locale(code);
    });
  }

  // Tema
  ThemeMode _themeMode = ThemeMode.light;
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: [Locale('en'), Locale('id')],

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      title: 'Flutter Demo',
      theme: ThemeData(brightness: Brightness.light, fontFamily: 'Inter'),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'JinahKu Home Page',
        isDark: _themeMode == ThemeMode.dark,
        isEnglish: _locale.languageCode == 'en',
        onToggle: _toggleTheme,
        onChangeLanguage: _changeLanguage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.isDark,
    required this.onToggle,
    required this.onChangeLanguage,
    required this.isEnglish,
  });

  final String title;
  final bool isDark;
  final bool isEnglish;
  final Function(String) onChangeLanguage;
  final Function(bool) onToggle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map<String, dynamic>> users = [];
  // This widget is the root of your application.

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await DBHelper.getUsers();
    setState(() {
      users = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Text(
            AppLocalizations.of(context)!.hello,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.keuangan,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SwitchListTile(
            title: Text(widget.isDark ? 'Dark Mode' : 'Light Mode'),
            value: widget.isDark,
            onChanged: widget.onToggle,
          ),
          SwitchListTile(
            title: Text(widget.isEnglish ? 'English' : 'Indonesia'),
            value: widget.isEnglish,
            onChanged: (value) {
              widget.onChangeLanguage(value ? 'en' : 'id');
            },
          ),
          ElevatedButton(
            onPressed: () async {
              await DBHelper.insertUser('Budi', 25);
              await loadUsers();
            },
            child: Text('Tambah Data'),
          ),

          const SizedBox(height: 20),
          //List data
          Expanded(
            child: users.isEmpty
                  ? const Center(child: Text('Belum ada data'))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return ListTile(
                          title: Text(user['name']),
                          subtitle: Text('Age: ${user['age']}'),
                        );
                      },
                    ),
          )
        ],
      ),
    );
  }
}
