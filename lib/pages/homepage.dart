import 'package:flutter/material.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/database/db_helper.dart';

class homepage extends StatefulWidget {
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
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {

  String username = '';
  double income = 0;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user = await DBHelper.getUser();
    if (user != null) {
      setState(() {
        username = user['username'];
        income = user['monthly_income'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${l10n.halo}, ${username} 👋",

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
              title: Text(widget.isDark ? 'Dark Mode' : 'Light Mode'),
              value: widget.isDark,
              onChanged: widget.onToggleTheme,
            ),
            SwitchListTile(
              title: Text(widget.isEnglish ? 'English' : 'Indonesia'),
              value: widget.isEnglish,
              onChanged: (value) {
                widget.onChangeLanguage(value ? 'en' : 'id');
              },
            ),
            const SizedBox(height: 10),

            Text("${l10n.pemasukan}: Rp.${income.toStringAsFixed(0)}"),
          ],
        ),
      ),
    );
  }
}
