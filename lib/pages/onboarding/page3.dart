import 'package:flutter/material.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/pages/homepage.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page2.dart';

class page3 extends StatelessWidget {
  final OnboardingData data;

  final bool isDark;
  final bool isEnglish;

  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  const page3({
    super.key,
    required this.data,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF071739),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HERO IMAGE
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Image.asset(
                'assets/images/BG_PG2.webp',
                height: 350,
                fit: BoxFit.contain,
              ),
            ),

            /// CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: const BoxDecoration(
                color: Color(0xFF1B263B),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// USER INFO TITLE
                  const Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),

                      SizedBox(width: 10),

                      Text(
                        "Informasi Pengguna",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// USER CARD
                  Container(
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: const Color(0xFF243B55),

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(color: Colors.blue.shade400),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        /// USERNAME
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              l10n.namaP,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              data.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        /// AVATAR
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(data.avatar),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// DETAIL TITLE
                  const Row(
                    children: [
                      Icon(Icons.arrow_circle_up, color: Colors.white),

                      SizedBox(width: 10),

                      Text(
                        "Detail Pendapatan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// DETAIL CARD
                  Container(
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: const Color(0xFF243B55),

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(color: Colors.blue.shade400),
                    ),

                    child: Column(
                      children: [
                        buildRow(
                          "Jumlah Pemasukan",
                          "Rp. ${data.income.toStringAsFixed(0)}",
                          isGreen: true,
                        ),

                        const SizedBox(height: 14),

                        buildRow(
                          "Sumber Pemasukan",
                          data.sourceId == 1 ? "Gaji Bulanan" : "Lainnya",
                        ),

                        const SizedBox(height: 14),

                        buildRow(
                          "Tanggal",
                          data.date == null ? "-" : "${data.date!.day}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// BUTTON SAVE
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6BFF),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () async {
                        await DBHelper.insertUser(
                          username: data.username,

                          monthlyIncome: data.income,

                          incomeDate: data.date!,

                          avatar: data.avatar,

                          incomeSourceId: data.sourceId!,
                        );

                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (_) => homepage(
                              isDark: true,
                              isEnglish: false,
                              onToggleTheme: (val) {},
                              onChangeLanguage: (lang) {},
                            ),
                          ),
                        );
                      },

                      child: Text(
                        l10n.simpan,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// BACK BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue.shade200),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () {
                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (_) => page1(
                              data: data,

                              onNext: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) => page2(
                                      data: data,

                                      onNext: () {
                                        Navigator.push(
                                          context,

                                          MaterialPageRoute(
                                            builder: (_) => page3(
                                              data: data,
                                              isDark: isDark,
                                              isEnglish: isEnglish,
                                              onToggleTheme: onToggleTheme,
                                              onChangeLanguage:
                                                  onChangeLanguage,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },

                      child: const Text(
                        "Kembali & Ubah Data",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// INDICATOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      buildDot(false),
                      buildDot(false),
                      buildDot(true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String title, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),

        Text(
          value,
          style: TextStyle(
            color: isGreen ? Colors.greenAccent : Colors.white,

            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildDot(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),

      width: active ? 10 : 8,
      height: active ? 10 : 8,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        color: active ? Colors.blue : Colors.white54,
      ),
    );
  }
}
