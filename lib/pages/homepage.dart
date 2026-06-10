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
  String avatar = '';

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final user = await DBHelper.getUser();
    if (user != null) {
      setState(() {
        username = user['username'] ?? '';
        income = user['monthly_income'] ?? 0;
        avatar = user['avatar'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 320,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/background.webp',
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: 320,
                  color: widget.isDark
                      ? Colors.black.withOpacity(0.35)
                      : const Color(0xFFE2E8F0).withOpacity(0.10),
                ),

                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: avatar.isNotEmpty
                                ? AssetImage(avatar)
                                : null,
                            child: avatar.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                Text(
                                  "${l10n.halo}, ${username} 👋",
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),

                                Text(
                                  l10n.keuangan,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontSize: 14,
                                        fontWeight: .w500,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () {},
                            iconSize: 34,
                            icon: Icon(
                              Icons.settings,
                              color: widget.isDark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2A44),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Saldo saat ini",
                              style: TextStyle(color: Colors.white70),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Rp. ${income.toStringAsFixed(0)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(top: 290),
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.black : Color(0xFFE2E8F0),
                borderRadius: .only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Column(
                crossAxisAlignment: .start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "${l10n.halo}, $username 👋",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
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
          ],
        ),
      ),
    );
  }
}
