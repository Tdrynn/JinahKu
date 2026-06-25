import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  final Function(int) onItemTapped;

  const Navbar({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colors = isDark ? dark.darkColors : light.lightColors;

    return SizedBox(
      height: 125,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            bottom: 25,
            left: 55,
            right: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.35)
                        : const Color(0xFFE2E8F0).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      const double indicatorWidth = 90;
                      double centerX;

                      if (selectedIndex == 0) {
                        centerX = width * 0.166;
                      } else if (selectedIndex == 2) {
                        centerX = width * 0.5;
                      } else {
                        centerX = width * 0.834;
                      }

                      final pillLeft = centerX - (indicatorWidth / 2);

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOutCubic,
                            left: pillLeft,
                            top: 3,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                              width: indicatorWidth,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withOpacity(0.12)
                                    : Colors.black.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.08 : 0.15,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _NavItem(
                                activeIcons: CupertinoIcons.house_fill,
                                inactiveIcons: CupertinoIcons.house,
                                selected: selectedIndex == 0,
                                colors: colors,
                                onTap: () => onItemTapped(0),
                              ),
                              _NavItem(
                                activeImage: "assets/icons/plusA.webp",
                                inactiveImage: "assets/icons/plus.webp",
                                selected: selectedIndex == 2,
                                colors: colors,
                                onTap: () => onItemTapped(2),
                              ),
                              _NavItem(
                                activeIcons: Icons.history,
                                inactiveIcons: Icons.history_outlined,
                                selected: selectedIndex == 1,
                                colors: colors,
                                onTap: () => onItemTapped(1),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData? activeIcons;
  final IconData? inactiveIcons;
  final String? activeImage;
  final String? inactiveImage;
  final bool selected;
  final dynamic colors;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    this.activeIcons,
    this.inactiveIcons,
    this.activeImage,
    this.inactiveImage,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.06 : 0.94,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: TweenAnimationBuilder<Color?>(
                duration: const Duration(milliseconds: 300),
                tween: ColorTween(
                  begin: selected ? colors.blue : colors.textSecondary,
                  end: selected ? colors.blue : colors.textSecondary,
                ),
                builder: (context, color, child) {
                  if (activeIcons != null && inactiveIcons != null) {
                    return Icon(
                      selected ? activeIcons : inactiveIcons,
                      size: 32,
                      color: color,
                    );
                  }

                  return Image.asset(
                    selected ? activeImage! : inactiveImage!,
                    width: 28,
                    height: 28,
                    color: color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
