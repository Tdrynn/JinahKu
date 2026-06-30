import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/database/db_helper.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jinahku/services/notification_service.dart';
import 'package:jinahku/pages/income_category.dart';

class Settings extends StatefulWidget {
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  const Settings({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = '';
  String avatar = '';
  double income = 0;

  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    loadUser();
    loadReminder();
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

  Future<void> loadReminder() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      selectedTime = TimeOfDay(
        hour: prefs.getInt('hour') ?? 20,
        minute: prefs.getInt('minute') ?? 0,
      );
    });
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final iconColor = widget.isDark ? Colors.white : Colors.black87;

    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);

    final backgroundColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.85);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _themePopup(
    Color iconColor,
    Color borderColor,
    Color backgroundColor,
  ) {
    return PopupMenuButton<String>(
      tooltip: "Theme",
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: _glassCircleIcon(
        widget.isDark ? Icons.dark_mode : Icons.light_mode,
        iconColor,
        borderColor,
        backgroundColor,
      ),
      onSelected: (value) {
        widget.onToggleTheme(value == 'dark');
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "light",
          child: Row(
            children: [
              Icon(Icons.light_mode, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text("Light")),
              if (!widget.isDark)
                const Icon(Icons.check, color: Colors.green, size: 18),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "dark",
          child: Row(
            children: [
              const Icon(Icons.dark_mode, color: Colors.indigo, size: 20),
              const SizedBox(width: 10),
              const Expanded(child: Text("Dark")),
              if (widget.isDark)
                const Icon(Icons.check, color: Colors.green, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _languagePopup(
    Color iconColor,
    Color borderColor,
    Color backgroundColor,
  ) {
    return PopupMenuButton<String>(
      tooltip: "Language",
      color: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: _glassCircleIcon(
        Icons.language,
        iconColor,
        borderColor,
        backgroundColor,
      ),
      onSelected: (value) {
        widget.onChangeLanguage(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "id",
          child: Row(
            children: [
              const Text("🇮🇩"),
              const SizedBox(width: 10),
              const Expanded(child: Text("Indonesia")),
              if (!widget.isEnglish)
                const Icon(Icons.check, color: Colors.green, size: 18),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: "en",
          child: Row(
            children: [
              const Text("🇬🇧"),
              const SizedBox(width: 10),
              const Expanded(child: Text("English")),
              if (widget.isEnglish)
                const Icon(Icons.check, color: Colors.green, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCircleIcon(
    IconData icon,
    Color iconColor,
    Color borderColor,
    Color backgroundColor,
  ) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final iconColor = widget.isDark ? Colors.white : Colors.black87;

    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.08);

    final glassBackground = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.85);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: _glassIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _themePopup(iconColor, borderColor, glassBackground),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _languagePopup(iconColor, borderColor, glassBackground),
          ),
        ],
      ),
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: avatar.isNotEmpty
                            ? AssetImage(avatar)
                            : null,
                        child: avatar.isEmpty
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colors.card,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(7, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(l10n.namaP),
                          subtitle: Text(username),
                          trailing: const Icon(Icons.edit),
                          onTap: () {},
                        ),
                        Divider(height: 2, color: colors.background),
                        ListTile(
                          leading: const Icon(
                            Icons.account_balance_wallet_outlined,
                          ),
                          title: Text(l10n.pemasukan),
                          subtitle: Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(income),
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () {},
                        ),
                        Divider(height: 2, color: colors.background),
                        ListTile(
                          leading: const Icon(Icons.calendar_month),
                          title: Text(l10n.tanggalP),
                          subtitle: Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(income),
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () {},
                        ),
                        Divider(height: 2, color: colors.background),
                        ListTile(
                          leading: const Icon(Icons.arrow_upward_rounded),
                          title: const Text("Kategori Pemasukan"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const IncomeCategoryPage(),
                              ),
                            );
                          },
                        ),
                        Divider(height: 2, color: colors.background),
                        ListTile(
                          leading: const Icon(Icons.arrow_downward_rounded),
                          title: const Text("Kategori Pengeluaran"),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {},
                        ),
                        Divider(height: 2, color: colors.background),
                        ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: const Text("Jam Pengingat"),
                          subtitle: Text(
                            "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                          ),
                          trailing: const Icon(Icons.edit),
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );

                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });

                              await saveReminder();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.red, colors.red.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: colors.red.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Reset Aplikasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> saveReminder() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("hour", selectedTime.hour);
    await prefs.setInt("minute", selectedTime.minute);

    await NotificationService.notifications.cancel(0);

    await NotificationService.scheduleDailyNotification(
      hour: selectedTime.hour,
      minute: selectedTime.minute,
    );
  }
}
