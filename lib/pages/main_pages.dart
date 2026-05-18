import 'package:flutter/material.dart';
import 'package:jinahku/pages/transaction.dart';
import 'homepage.dart';
import 'history.dart';
import 'package:jinahku/widgets/navbar.dart';

class MainPage extends StatefulWidget {

  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  const MainPage({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    final pages = [

      homepage(
        isDark: widget.isDark,
        isEnglish: widget.isEnglish,
        onToggleTheme: widget.onToggleTheme,
        onChangeLanguage: widget.onChangeLanguage,
      ),

      const History(),
      const Transaction(),
    ];

    return Scaffold(

      body: pages[selectedIndex],

      bottomNavigationBar: navbar(
        selectedIndex: selectedIndex,
        isDark: widget.isDark,
        isEnglish: widget.isEnglish,
        onToggleTheme: widget.onToggleTheme,
        onChangeLanguage: widget.onChangeLanguage,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}