import 'package:flutter/material.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/widgets/navbar.dart';

class homepage extends StatelessWidget {
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;
  const homepage({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    print(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.halo,

              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              l10n.keuangan,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: Text(isDark ? 'Dark Mode' : 'Light Mode'),
              value: isDark,
              onChanged: onToggleTheme,
            ),
            SwitchListTile(
              title: Text(isEnglish ? 'English' : 'Indonesia'),
              value: isEnglish,
              onChanged: (value) {
                onChangeLanguage(value ? 'en' : 'id');
              },
            ),
          ],
        ),
      ),

      // ================= NAVBAR =================
      bottomNavigationBar: navbar(
        selectedIndex: 0,

        isDark: Theme.of(context).brightness == Brightness.dark,

        onItemTapped: (index) {
          print(index);
        },
      ),
    );
  }
}
