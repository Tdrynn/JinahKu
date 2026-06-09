import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/pages/homepage.dart';
import 'package:jinahku/pages/main_pages.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page2.dart';

class Page3 extends StatefulWidget {
  final OnboardingData data;

  final bool isDark;
  final bool isEnglish;

  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;

  const Page3({
    super.key,
    required this.data,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
  });

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF000C2C),

      body: SingleChildScrollView(
        child: Stack(
          children: [

            SizedBox(
              height: 480,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Image.asset(
                  'assets/images/BG_PG3.webp',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: .topCenter,
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 360),
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
                              widget.data.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(widget.data.avatar),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

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
                          NumberFormat.currency(
                            locale: 'id',
                            symbol: 'Rp. ',
                            decimalDigits: 0,
                          ).format(widget.data.income),
                          isGreen: true,
                        ),

                        const SizedBox(height: 14),

                        buildRow(
                          "Sumber Pemasukan",
                          widget.data.sourceId == 1 ? "Gaji Bulanan" : "Lainnya",
                        ),

                        const SizedBox(height: 14),

                        buildRow(
                          "Tanggal",
                          widget.data.date == null ? "-" : "${widget.data.date!.day}",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
                          username: widget.data.username,
                          monthlyIncome: widget.data.income,
                          incomeDate: widget.data.date!,
                          avatar: widget.data.avatar,
                          incomeSourceId: widget.data.sourceId!,
                        );

                        Navigator.pushReplacement(
                          context,

                          MaterialPageRoute(
                            builder: (_) => MainPage(
                              isDark: widget.isDark,
                              isEnglish: widget.isEnglish,
                              onToggleTheme: widget.onToggleTheme,
                              onChangeLanguage: widget.onChangeLanguage,
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
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Page1(
                              data: widget.data,
                              onNext: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Page2(
                                      data: widget.data,
                                      onNext: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Page3(
                                              data: widget.data,
                                              isDark: widget.isDark,
                                              isEnglish: widget.isEnglish,
                                              onToggleTheme: widget.onToggleTheme,
                                              onChangeLanguage:
                                                  widget.onChangeLanguage,
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
                          (route) => false,
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