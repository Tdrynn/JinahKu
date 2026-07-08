import 'package:flutter/material.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page2.dart';
import 'package:jinahku/pages/onboarding/page3.dart';
import 'package:jinahku/models/modelUser.dart';

class OnboardingPage extends StatefulWidget {
  final bool isDark;
  final Function(bool) onToggleTheme;
  final VoidCallback finishOnboarding;

  const OnboardingPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
    required this.finishOnboarding,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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

  void goToPage(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
        children: [
          Page1(data: data, onNext: nextPage),
          Page2(data: data, onNext: nextPage),
          Page3(
            data: data,
            isDark: widget.isDark,
            onToggleTheme: widget.onToggleTheme,
            finishOnboarding: widget.finishOnboarding,
            onBack: () => goToPage(0),
          ),
        ],
      ),
    );
  }
}
