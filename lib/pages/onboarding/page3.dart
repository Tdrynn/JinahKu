import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Page3 extends StatefulWidget {
  final OnboardingData data;
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;
  final VoidCallback finishOnboarding;
  final VoidCallback? onBack;

  const Page3({
    super.key,
    required this.data,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
    required this.finishOnboarding,
    this.onBack,
  });

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  // Fungsi helper untuk menerjemahkan sourceCode ke teks yang user-friendly
  String _getSourceName(String? sourceCode) {
    switch (sourceCode) {
      case 'salary':
        return 'Gaji';

      case 'allowance':
        return 'Tunjangan';

      case 'freelance':
        return 'Freelance';

      case 'business':
        return 'Bisnis';

      case 'other':
        return 'Lainnya';

      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final paddingTop = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1B263B),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            color: const Color(0xFF000C2C),
                            width: double.infinity,
                            padding: EdgeInsets.only(top: paddingTop + 70),
                            child: Image.asset(
                              'assets/images/BG_PG3.webp',
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          if (widget.onBack != null)
                            Positioned(
                              top: paddingTop + 10,
                              left: 16,
                              child: ClipOval(
                                child: Material(
                                  color: Colors.black26,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back_ios_new,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: widget.onBack,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Expanded(
                        child: Transform.translate(
                          offset: const Offset(0, -15),
                          child: Container(
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
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Informasi Pengguna",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF243B55),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.blue.shade400,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.namaP,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.data.username.isEmpty
                                                ? "-"
                                                : widget.data.username,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 22.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            widget.data.avatar.isNotEmpty
                                            ? AssetImage(widget.data.avatar)
                                            : const AssetImage(
                                                'assets/images/default_avatar.png',
                                              ), // Fallback jika avatar kosong
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.arrow_circle_up,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Detail Pendapatan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF243B55),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Colors.blue.shade400,
                                    ),
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
                                        _getSourceName(
                                          widget.data.sourceCode,
                                        ), // Menggunakan helper String sourceCode
                                      ),
                                      const SizedBox(height: 14),
                                      buildRow(
                                        "Tanggal Terpilih",
                                        widget.data.date == null
                                            ? "-"
                                            : DateFormat(
                                                'dd MMMM yyyy',
                                                'id',
                                              ).format(
                                                widget.data.date!,
                                              ), // Format tanggal lebih rapi
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(height: 32),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.h,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2F6BFF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        await DBHelper.insertUser(
                                          username: widget.data.username,
                                          monthlyIncome: widget.data.income,
                                          incomeDate:
                                              widget.data.date ??
                                              DateTime.now(),
                                          avatar: widget.data.avatar,
                                          incomeCategoryCode:
                                              widget.data.sourceCode ??
                                              'salary',
                                        );

                                        widget.finishOnboarding();
                                      } catch (e) {
                                        debugPrint(
                                          "Gagal menyimpan data user: ${e.toString()}",
                                        );

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Gagal menyimpan data: $e",
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      l10n.simpan,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
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
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
        Flexible(
          // Menghindari overflow jika teks value terlalu panjang
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isGreen ? Colors.greenAccent : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
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
