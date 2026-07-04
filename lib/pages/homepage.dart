import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/pages/settings.dart';


class HomePage extends StatefulWidget {
  final bool isDark;
  final bool isEnglish;
  final Function(bool) onToggleTheme;
  final Function(String) onChangeLanguage;
  final VoidCallback restartOnBoarding;
  const HomePage({
    super.key,
    required this.isDark,
    required this.isEnglish,
    required this.onToggleTheme,
    required this.onChangeLanguage,
    required this.restartOnBoarding,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = '';
  double income = 0;
  double totalIncome = 0;
  double totalExpenseValue = 0;
  double currentBalance = 0;
  bool showBalance = true;
  String avatar = '';
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  List<Map<String, dynamic>> expenseData = [];
  double totalExpense = 0;

  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    loadUser();
    loadExpenseChart();
    loadFinancialSummary();
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
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

  Future<void> loadExpenseChart() async {
    final data = await DBHelper.getExpenseByCategoryMonthly(
      selectedYear,
      selectedMonth,
    );
    double total = 0;
    for (var item in data) {
      total += (item['total'] as num).toDouble();
    }

    setState(() {
      expenseData = data;
      totalExpense = total;
    });
  }

  Future<void> loadFinancialSummary() async {
    final summary = await DBHelper.getFinancialSummary();

    setState(() {
      totalIncome = summary['income']!;
      totalExpenseValue = summary['expense']!;
      currentBalance = summary['balance']!;
    });
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return const Color(0xFF5AC18E);
      case 'hiburan':
        return const Color(0xFF4F7BFF);
      case 'transportasi':
        return const Color(0xFFF6B52C);
      case 'lainnya':
        return const Color(0xFFF2994A);
      default:
        return Colors.grey;
    }
  }

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  List<PieChartSectionData> getSections() {
    return expenseData.map((item) {
      final value = (item['total'] as num).toDouble();

      final percentage = totalExpense == 0 ? 0 : (value / totalExpense * 100);

      return PieChartSectionData(
        value: value,
        color: getCategoryColor(item['category']),
        title: "${percentage.toStringAsFixed(0)}%",
        radius: 40,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 320.h,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/background.webp',
                    fit: BoxFit.cover,
                  ),
                ),

                Container(
                  height: 320.h,
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
                                        fontSize: 19,
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
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Settings(
                                    isDark: widget.isDark,
                                    isEnglish: widget.isEnglish,
                                    onToggleTheme: widget.onToggleTheme,
                                    onChangeLanguage: widget.onChangeLanguage,
                                    restartOnBoarding: widget.restartOnBoarding,
                                  ),
                                ),
                              );
                              if (mounted) {
                                loadUser();
                                loadFinancialSummary();
                                loadExpenseChart();
                              }
                            },

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
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                30.w,
                                12.h,
                                30.w,
                                12.h,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.saldo,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 18,
                                            fontWeight: .w400,
                                          ),
                                        ),

                                        Text(
                                          showBalance
                                              ? currencyFormatter.format(
                                                  currentBalance,
                                                )
                                              : "Rp. ••••••••••",
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 23,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          showBalance = !showBalance;
                                        });
                                      },
                                      icon: Icon(
                                        showBalance
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: colors.textPrimary,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colors.divider,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                ),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.pemasukan,
                                            style: TextStyle(
                                              color: colors.textPrimary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              showBalance
                                                  ? currencyFormatter.format(
                                                      totalIncome,
                                                    )
                                                  : "Rp. ••••••••••",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    VerticalDivider(
                                      width: 30,
                                      thickness: 1.2,
                                      color: colors.textPrimary.withOpacity(
                                        0.2,
                                      ),
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            l10n.pengeluaran,
                                            style: TextStyle(
                                              color: colors.textPrimary,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              showBalance
                                                  ? currencyFormatter.format(
                                                      totalExpenseValue,
                                                    )
                                                  : "Rp. ••••••••••",
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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
              margin: const EdgeInsets.only(top: 315),
              width: double.infinity,
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: .only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),

              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.ringkasan,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.textPrimary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Bulanan",
                                style: TextStyle(color: colors.textPrimary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        expenseData.isEmpty
                            ? SizedBox(
                                height: 150.h,
                                child: Center(
                                  child: Text(
                                    "Belum ada data pengeluaran",
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150.w,
                                    height: 150.h,
                                    child: PieChart(
                                      PieChartData(
                                        centerSpaceRadius: 35,
                                        sectionsSpace: 3,
                                        borderData: FlBorderData(show: false),
                                        sections: getSections(),
                                      ),
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    ),
                                  ),

                                  const SizedBox(width: 20),

                                  Expanded(
                                    child: Column(
                                      children: expenseData.map((item) {
                                        final value = (item['total'] as num)
                                            .toDouble();

                                        final percentage = totalExpense == 0
                                            ? 0
                                            : (value / totalExpense * 100);

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 12.w,
                                                height: 12.h,
                                                decoration: BoxDecoration(
                                                  color: getCategoryColor(
                                                    item['category'],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),

                                              const SizedBox(width: 10),

                                              Expanded(
                                                child: Text(
                                                  item['category'],
                                                  style: TextStyle(
                                                    color: colors.textPrimary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),

                                              Text(
                                                "${percentage.toStringAsFixed(0)}%",
                                                style: TextStyle(
                                                  color: colors.textPrimary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: .circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.targerT,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.blue,
                                  colors.blue.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: .circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.blue.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                l10n.tambahkanT,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: .bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseCategory {
  final String category;
  final double total;

  ExpenseCategory({required this.category, required this.total});
}
