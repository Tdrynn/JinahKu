import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

  void _handleDragUpdate(DragUpdateDetails details, double totalWidth) {
    double localX = details.localPosition.dx;

    double sectionWidth = totalWidth / 3;

    int newIndex;
    if (localX < sectionWidth) {
      newIndex = 0;
    } else if (localX < sectionWidth * 2) {
      newIndex = 2;
    } else {
      newIndex = 1;
    }

    if (newIndex != selectedIndex) {
      onItemTapped(newIndex);
    }
  }

  void _handleDrag(Offset localPosition, double totalWidth) {
    double localX = localPosition.dx;
    double sectionWidth = totalWidth / 3;

    int newIndex;
    if (localX < sectionWidth) {
      newIndex = 0;
    } else if (localX < sectionWidth * 2) {
      newIndex = 2;
    } else {
      newIndex = 1;
    }

    if (newIndex != selectedIndex) {
      onItemTapped(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark
        ? Colors.black.withOpacity(0.20)
        : const Color(0xFFE2E8F0).withOpacity(0.45);

    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    final activeColor = const Color(0xFF2F80ED);
    final inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    const double navWidth = 340;
    const double navHeight = 70;
    const double activeWidth = 79;
    const double activeHeight = 54;

    double activeLeftPosition;
    if (selectedIndex == 0) {
      activeLeftPosition = (navWidth / 3) / 2 - (activeWidth / 2);
    } else if (selectedIndex == 2) {
      activeLeftPosition = (navWidth * 0.5) - (activeWidth / 2);
    } else {
      activeLeftPosition = (navWidth * 5 / 6) - (activeWidth / 2);
    }

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: GestureDetector(
                  onHorizontalDragStart: (details) =>
                      _handleDrag(details.localPosition, navWidth),
                  onHorizontalDragUpdate: (details) =>
                      _handleDrag(details.localPosition, navWidth),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: navWidth,
                    height: navHeight,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: borderColor, width: 1.0),
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOutCubic,
                          left: activeLeftPosition,
                          top: (navHeight - activeHeight) / 2,
                          child: Container(
                            width: activeWidth,
                            height: activeHeight,
                            decoration: BoxDecoration(
                              color: activeColor.withOpacity(
                                isDark ? 0.15 : 0.22,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: activeColor.withOpacity(
                                  isDark ? 0.4 : 0.6,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: _NavItem(
                                icon: selectedIndex == 0
                                    ? CupertinoIcons.house_fill
                                    : CupertinoIcons.house,
                                selected: selectedIndex == 0,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor,
                                onTap: () => onItemTapped(0),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => onItemTapped(2),
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  height: 70,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedScale(
                                        scale: selectedIndex == 2 ? 1.15 : 1.0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: Image.asset(
                                          selectedIndex == 2
                                              ? "assets/icons/plusA.webp"
                                              : "assets/icons/plus.webp",
                                          width: 28,
                                          height: 28,
                                          color: selectedIndex == 2
                                              ? activeColor
                                              : inactiveColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _NavItem(
                                icon: selectedIndex == 1
                                    ? Icons.history
                                    : Icons.history_outlined,
                                selected: selectedIndex == 1,
                                activeColor: activeColor,
                                inactiveColor: inactiveColor,
                                onTap: () => onItemTapped(1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
  final IconData icon;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 28,
                color: selected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
