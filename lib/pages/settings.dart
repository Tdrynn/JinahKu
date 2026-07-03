import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/main.dart';
import 'package:jinahku/services/notification_service.dart';
import 'package:jinahku/pages/onboarding/onboardingPage.dart';

import 'package:jinahku/database/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final VoidCallback restartOnBoarding;
  const Settings({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
    required this.restartOnBoarding,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String username = '';
  String avatar = '';
  double income = 0;
  int incomeDate = 1;

  int selectedAvatarIndex = 0;
  final avatars = [
    'assets/images/Male.webp',
    'assets/images/Female.webp',
    'assets/images/Male1.webp',
    'assets/images/Female1.webp',
    'assets/images/User1.webp',
  ];

  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    loadUser();
    loadReminder();
  }

  void loadUser() async {
    final user = await DBHelper.getUserWithDate();
    if (user != null) {
      setState(() {
        username = user['username'] ?? '';
        income = (user['monthly_income'] as num?)?.toDouble() ?? 0;
        avatar = user['avatar'] ?? '';
        incomeDate = user['income_date'] ?? 1;

        final index = avatars.indexOf(avatar);
        if (index != -1) {
          selectedAvatarIndex = index;
        }
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

  Future<void> _updateUserData(String key, dynamic value) async {
    await DBHelper.updateUser({key: value});
    loadUser();
  }

  void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF15803D),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showEditAvatarDialog(AppLocalizations l10n) {
    int tempIndex = selectedAvatarIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Text(
                    "Edit Avatar",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  CircleAvatar(
                    radius: 66,
                    backgroundImage: AssetImage(avatars[tempIndex]),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(avatars.length, (index) {
                      final selected = tempIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            tempIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: AssetImage(avatars[index]),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 35),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.batal,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              await _updateUserData(
                                'avatar',
                                avatars[tempIndex],
                              );
                              setState(() {
                                avatar = avatars[tempIndex];
                                selectedAvatarIndex = tempIndex;
                              });
                              showSuccessToast(l10n.dsimpan);
                              if (mounted) Navigator.pop(context);
                            },
                            child: Text(
                              l10n.simpanp,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(AppLocalizations l10n) {
    final controller = TextEditingController(text: username);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF3B82F6),
                    size: 55,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.namaP,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Masukkan nama baru",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.batal,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            if (controller.text.trim().isNotEmpty) {
                              await _updateUserData(
                                'username',
                                controller.text.trim(),
                              );
                              showSuccessToast(l10n.dsimpan);
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          child: Text(
                            l10n.simpanp,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditIncomeDialog(AppLocalizations l10n) {
    final controller = TextEditingController(text: income.toInt().toString());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A).withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF3B82F6),
                    size: 55,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.pemasukan,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsSeparatorInputFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    filled: true,
                    prefixText: "Rp. ",
                    prefixStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB91C1C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            l10n.batal,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF15803D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            final newIncome =
                                double.tryParse(controller.text) ?? 0;
                            await _updateUserData('monthly_income', newIncome);
                            showSuccessToast(l10n.dsimpan);
                            if (mounted) Navigator.pop(context);
                          },
                          child: Text(
                            l10n.simpanp,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDateDialog(AppLocalizations l10n) {
    int tempSelectedDate = incomeDate ?? 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF3B82F6),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.tanggalP,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: 31,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.white.withOpacity(0.03),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final date = index + 1;
                          final isSelected = tempSelectedDate == date;

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B82F6).withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              title: Text(
                                "${l10n.tanggal} $date",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue.shade300
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF22C55E),
                                    )
                                  : null,
                              onTap: () {
                                setModalState(() {
                                  tempSelectedDate = date;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB91C1C),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              l10n.batal,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF15803D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              await _updateUserData(
                                'income_date',
                                tempSelectedDate,
                              );
                              setState(() {
                                incomeDate = tempSelectedDate;
                              });
                              showSuccessToast(l10n.dsimpan);
                              if (mounted) Navigator.pop(context);
                            },
                            child: Text(
                              l10n.simpanp,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showResetConfirmation(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: widget.isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/icons/reset.webp',
                  width: 120,
                  fit: BoxFit.cover,
                  alignment: .center,
                ),
              ),
              const SizedBox(height: 15),

              Text(
                l10n.mulai,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                l10n.yakin,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await DBHelper.clearAllData();

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    await NotificationService.notifications.cancelAll();

                    if (!mounted) return;

                    await DBHelper.clearAllData();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MyApp()),
                      (_) => false,
                    );
                  },
                  child: Text(
                    l10n.riset,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF15803D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.batal,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 25),
            ],
          ),
        );
      },
    );
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
    BuildContext context,
    Color iconColor,
    Color borderColor,
    Color backgroundColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
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
      onSelected: (value) => widget.onToggleTheme(value == 'dark'),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: "light",
          child: Row(
            children: [
              const Icon(Icons.light_mode, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(l10n.terang)),
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
              Expanded(child: Text(l10n.gelap)),
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
      onSelected: widget.onChangeLanguage,
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
        backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: _glassIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          l10n.pengaturan,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _themePopup(
              context,
              iconColor,
              borderColor,
              glassBackground,
            ),
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
              child: Stack(
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
                    onTap: () => _showEditAvatarDialog(l10n),
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
            ),
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
                  mainAxisSize: MainAxisSize.min,
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
                      onTap: () => _showEditIncomeDialog(l10n),
                    ),
                    Divider(height: 2, color: colors.background),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: Text(l10n.tanggalP),
                      subtitle: Text("${l10n.stanggal} $incomeDate${l10n.stl}"),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _showEditDateDialog(l10n),
                    ),
                    Divider(height: 2, color: colors.background),
                    ListTile(
                      leading: const Icon(Icons.arrow_upward_rounded),
                      title: Text(l10n.kpemasukan),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const IncomeCategoryPage(),
                          ),
                        );
                      },
                    ),
                    Divider(height: 2, color: colors.background),
                    ListTile(
                      leading: const Icon(Icons.arrow_downward_rounded),
                      title: Text(l10n.kpengeluaran),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/manage_expense_category',
                        );
                      },
                    ),
                    Divider(height: 2, color: colors.background),
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: Text(l10n.jam),
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
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _showResetConfirmation(l10n),
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
                      Text(
                        l10n.reset,
                        style: const TextStyle(
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("hour", selectedTime.hour);
      await prefs.setInt("minute", selectedTime.minute);

      await NotificationService.notifications.cancel(0);
      await NotificationService.scheduleDailyNotification(
        hour: selectedTime.hour,
        minute: selectedTime.minute,
      );
    } catch (e) {
      debugPrint("Error saving reminder: $e");
    }
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cleanString = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanString.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final formatter = NumberFormat.decimalPattern('id');
    final newText = formatter.format(int.parse(cleanString));

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
