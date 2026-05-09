import 'package:flutter/material.dart';

import '../theme/light_colors.dart' as light;
import 'package:jinahku/l10n/app_localizations.dart';
import '../theme/dark_colors.dart' as dark;

class navbar extends StatelessWidget {
  final int selectedIndex;
  final bool isDark;
  final Function(int) onItemTapped;

  const navbar({
    super.key,
    required this.selectedIndex,
    required this.isDark,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    // ================= THEME COLORS =================

    final colors = isDark ? dark.darkColors : light.lightColors;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 136,

      child: Stack(
        alignment: Alignment.topCenter,

        children: [
          // ================= NAVBAR =================
          Positioned(
            bottom: 0,

            child: Container(
              width: MediaQuery.of(context).size.width,

              height: 100,

              decoration: BoxDecoration(
                color: colors.card,

                border: Border.all(color: colors.divider),

                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  // ================= HOME =================
                  _NavItem(
                    activeImage: 'assets/icons/HomePageA.webp',
                    inactiveImage: 'assets/icons/HomePage.webp',
                    label: l10n.beranda,
                    selected: selectedIndex == 0,
                    colors: colors,
                    onTap: () => onItemTapped(0),
                  ),

                  const SizedBox(width: 100),

                  _NavItem(
                    activeImage: 'assets/icons/ChequeA.webp',
                    inactiveImage: 'assets/icons/Cheque.webp',
                    label: l10n.riwayat,
                    selected: selectedIndex == 1,
                    colors: colors,
                    onTap: () => onItemTapped(1),
                  ),
                ],
              ),
            ),
          ),

          // ================= CENTER BUTTON =================
          Positioned(
            top: 0,

            child: Column(
              children: [
                GestureDetector(
                  onTap: () => onItemTapped(2),

                  child: Container(
                    height: 72,
                    width: 115,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),

                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,

                        colors: isDark
                            ? [const Color(0xFF404A55), const Color(0xFF1A1D22)]
                            : [
                                const Color(0xFFF0F0F0),
                                const Color(0xFF404A55),
                              ],
                      ),
                    ),

                    child: Center(
                      child: Container(
                        height: 58,
                        width: 95,

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),

                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,

                            colors: [Color(0xFF1B8EC5), Color(0xFF46AADB)],
                          ),
                        ),

                        child: const Icon(
                          Icons.add,

                          color: Colors.white,

                          size: 42,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  l10n.transaksi,

                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= NAV ITEM =================

class _NavItem extends StatelessWidget {
  final String activeImage;
  final String inactiveImage;
  final String label;
  final bool selected;
  final dynamic colors;
  final VoidCallback onTap;

  const _NavItem({
    required this.activeImage,
    required this.inactiveImage,
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: 100,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),

              decoration: BoxDecoration(
                color: selected
                    ? colors.blue.withOpacity(0.15)
                    : Colors.transparent,

                borderRadius: BorderRadius.circular(40),
              ),

              child: Image.asset(
                selected ? activeImage : inactiveImage,

                width: 50,
                height: 50,
              ),
            ),

            const SizedBox(height: 0),

            Text(
              label,

              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
