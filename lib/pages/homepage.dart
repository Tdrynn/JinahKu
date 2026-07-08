import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:jinahku/pages/goal_detail.dart';
import 'dart:io';
import 'package:jinahku/services/notification_service.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:jinahku/pages/settings.dart';

import 'package:jinahku/pages/add_goal.dart';
import 'package:jinahku/services/home_widget_service.dart';

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
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
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

  Map<String, dynamic>? latestGoal;

  @override
  void initState() {
    super.initState();
    _initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkGoalReminder();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await DBHelper.autoAddMonthlyIncome();

    await loadUser();
    await loadExpenseChart();
    await loadFinancialSummary();
    await loadLatestGoal();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkGoalReminder();
    });
  }

  Future<void> loadUser() async {
    print("loadUser");
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
    print("loadExpenseChart");
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
    print("loadFinancialSummary");
    final summary = await DBHelper.getFinancialSummary();

    setState(() {
      totalIncome = summary['income']!;
      totalExpenseValue = summary['expense']!;
      currentBalance = summary['balance']!;
    });

    await HomeWidgetService.updateBalanceWidget(currentBalance);
  }

  Future<void> checkGoalReminder() async {
    print("checkGoalReminder");
    final goals = await DBHelper.getReminderGoals();

    if (!mounted) return;

    if (goals.isEmpty) return;

    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);

    for (final goal in goals) {
      final targetDate = DateTime.parse(goal['target_date']);

      final difference = targetDate.difference(todayOnly).inDays;

      String? reminderType;
      String? message;

      if (difference == 7) {
        reminderType = "H7";
        message = "Target tinggal 7 hari lagi.";
      } else if (difference == 3) {
        reminderType = "H3";
        message = "Target tinggal 3 hari lagi.";
      } else if (difference == 1) {
        reminderType = "H1";
        message = "Besok adalah batas waktu Goal.";
      } else if (difference == 0) {
        reminderType = "TODAY";
        message = "Hari ini adalah batas waktu Goal.";
      } else if (difference < 0) {
        reminderType = "OVERDUE";
        message = "Goal telah melewati target.";
      }

      if (reminderType == null || message == null) {
        continue;
      }

      if (goal['last_reminder'] == reminderType) {
        continue;
      }

      print("Kirim notif");
      print(message);

      await NotificationService.showNotification(
        title: "🎯 Goal Reminder",
        body: "\"${goal['goal_name']}\"\n\n$message",
      );

      await DBHelper.updateLastReminder(goal['id'], reminderType);

      break;
    }
  }

  Future<void> loadLatestGoal() async {
    print("loadLatestGoal");
    final data = await DBHelper.getLatestGoal();

    if (!mounted) return;

    setState(() {
      latestGoal = data;
    });
  }

  Future<void> refreshData() async {
    await loadUser();
    await loadExpenseChart();
    await loadFinancialSummary();
    await loadLatestGoal();
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.textPrimary),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Bulanan",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colors.textPrimary,
                                ),
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

                  latestGoal == null
                      ? _buildEmptyGoalCard(colors)
                      : _buildGoalCard(colors),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGoalCard(dynamic colors) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/goals.webp',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Goals ✨",
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  l10n.goalsDescription,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddGoalPage(isDark: widget.isDark),
                        ),
                      );

                      loadLatestGoal();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      l10n.createGoals,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(dynamic colors) {
    final l10n = AppLocalizations.of(context)!;
    final saved = (latestGoal!['saved_amount'] as num).toDouble();
    final target = (latestGoal!['target_amount'] as num).toDouble();
    final progress = target == 0 ? 0.0 : saved / target;

    final isCompleted = latestGoal!['status'] == 'completed';

    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime.parse(latestGoal!['target_date']);

    final targetOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final isOverdue = !isCompleted && targetOnly.isBefore(todayOnly);

    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.divider,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  latestGoal!['goal_name'],
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                splashRadius: 20,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: colors.textSecondary,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalDetailPage(
                        isDark: widget.isDark,
                        goalId: latestGoal!['id'],
                      ),
                    ),
                  );

                  await loadFinancialSummary();
                  await loadLatestGoal();
                  await checkGoalReminder();
                },
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              latestGoal!['image_path'] != null &&
                      File(latestGoal!['image_path']).existsSync()
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(latestGoal!['image_path']),
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.asset(
                        'assets/images/goals.webp',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${currencyFormatter.format(saved)} / ${currencyFormatter.format(target)}",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (!isCompleted) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade300,
                          color: isOverdue ? Colors.orange : colors.blue,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: isOverdue ? Colors.orange : colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "🎉 COMPLETED",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    if (!isCompleted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? Colors.orange.withOpacity(.15)
                              : colors.blue.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOverdue ? "Overdue" : "Active",
                          style: TextStyle(
                            color: isOverdue ? Colors.orange : colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      if (isOverdue)
                        const Text(
                          "⚠️ Goal is overdue.",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                    ],

                    const SizedBox(height: 12),

                    if (isCompleted)
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final newGoalId = await Navigator.push<int>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddGoalPage(
                                    isDark: widget.isDark,
                                    oldGoalId: latestGoal!['id'],
                                  ),
                                ),
                              );

                              await loadFinancialSummary();
                              await loadLatestGoal();

                              if (newGoalId != null && mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GoalDetailPage(
                                      isDark: widget.isDark,
                                      goalId: newGoalId,
                                    ),
                                  ),
                                );

                                await loadFinancialSummary();
                                await loadLatestGoal();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.createNewGoal),
                          ),
                        ],
                      )
                    else
                      Text(
                        "${l10n.target}: ${DateFormat('d MMMM yyyy', 'id_ID').format(DateTime.parse(latestGoal!['target_date']))}",
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenseCategory {
  final String category;
  final double total;

  ExpenseCategory({required this.category, required this.total});
}
