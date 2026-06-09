import 'package:flutter/material.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page2.dart';
import 'package:jinahku/pages/onboarding/page3.dart';
import 'package:jinahku/models/modelUser.dart';

class onboardingPage extends StatefulWidget {
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  const onboardingPage ({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<onboardingPage> createState() => _onboardingPageState();
}

class _onboardingPageState extends State<onboardingPage> {
  final PageController _controller = PageController();
  final OnboardingData data = OnboardingData();

  int currentIndex = 0;

  void nextPage() {
    if (currentIndex < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: onPageChanged,
              children: [
                Page1(data: data, onNext: nextPage),
                Page2(data: data, onNext: nextPage),
                Page3(data: data, isDark: widget.isDark, isEnglish: widget.isEnglish, onToggleTheme: widget.onToggleTheme, onChangeLanguage: widget.onChangeLanguage,
              ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}