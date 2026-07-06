import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_goal.dart';
import 'package:jinahku/l10n/app_localizations.dart';

import '../database/db_helper.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:flutter/services.dart';
import 'package:jinahku/utils/thousands_separator_input_formatter.dart';


class GoalDetailPage extends StatefulWidget {
  final bool isDark;
  final int goalId;

  const GoalDetailPage({super.key, required this.isDark, required this.goalId});

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  Map<String, dynamic>? goal;
  bool isLoading = true;

  List<Map<String, dynamic>> goalHistory = [];

  final TextEditingController _moneyController = TextEditingController();

  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  Future<void> _loadGoal() async {
    final data = await DBHelper.getGoalById(widget.goalId);

    if (mounted) {
      setState(() {
        goal = data;
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGoal();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await DBHelper.getGoalTransactions(widget.goalId);

    print("GOAL HISTORY = $data");

    if (!mounted) return;

    setState(() {
      goalHistory = data;
    });
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final displayHistory = goalHistory.take(3).toList();

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Goals tidak ditemukan")),
      );
    }

    final saved = (goal!['saved_amount'] as num).toDouble();
    final target = (goal!['target_amount'] as num).toDouble();

    final progress = target == 0 ? 0.0 : saved / target;

    final remaining = target - saved;

    final isCompleted = goal!['status'] == 'completed';

    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);

    final targetDate = DateTime.parse(goal!['target_date']);

    final targetOnly = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    final isOverdue = !isCompleted && targetOnly.isBefore(todayOnly);

    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),

        title: Text(
          l10n.goalDetail,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: isCompleted
                ? l10n.completedGoalCannotBeEdited
                : l10n.editGoals,

            onPressed: isCompleted
                ? null
                : () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddGoalPage(
                          isDark: widget.isDark,
                          goalId: widget.goalId,
                        ),
                      ),
                    );

                    await _loadGoal();
                    await _loadHistory();
                  },

            icon: Icon(
              Icons.edit_outlined,
              color: isCompleted ? Colors.grey : colors.textPrimary,
            ),
          ),
        ],
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// FOTO
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child:
                    goal!['image_path'] != null &&
                        File(goal!['image_path']).existsSync()
                    ? Image.file(
                        File(goal!['image_path']),
                        width: 170,
                        height: 170,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/images/goals.webp",
                        width: 170,
                        height: 170,
                        fit: BoxFit.contain,
                      ),
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: Text(
                goal!['goal_name'],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(.15)
                      : isOverdue
                      ? Colors.red.withOpacity(.15)
                      : colors.blue.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: isCompleted
                          ? Colors.green
                          : isOverdue
                          ? Colors.orange
                          : colors.blue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isCompleted
                          ? "Completed"
                          : isOverdue
                          ? "Overdue"
                          : "Active",
                      style: TextStyle(
                        color: isCompleted
                            ? Colors.green
                            : isOverdue
                            ? Colors.orange
                            : colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isOverdue) ...[
              const SizedBox(height: 10),

              Center(
                child: Text(
                  l10n.goalOverdue,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],

            const SizedBox(height: 24),

            /// CARD PROGRESS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    l10n.savingProgress,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            l10n.collected,
                            style: TextStyle(color: colors.textSecondary),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            currencyFormatter.format(saved),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,

                        children: [
                          Text(
                            l10n.target,
                            style: TextStyle(color: colors.textSecondary),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            currencyFormatter.format(target),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade300,
                      color: isOverdue ? Colors.orange : colors.blue,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(
                        color: isOverdue ? Colors.orange : colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// INFORMASI GOAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  _buildInfoRow(
                    colors,
                    l10n.targetDate,
                    DateFormat(
                      "d MMMM yyyy",
                      "id_ID",
                    ).format(DateTime.parse(goal!['target_date'])),
                  ),

                  Divider(
                    color: colors.textSecondary.withOpacity(0.35),
                    thickness: 1,
                  ),

                  _buildInfoRow(
                    colors,
                    l10n.remainingTarget,
                    currencyFormatter.format(remaining),
                  ),

                  Divider(
                    color: colors.textSecondary.withOpacity(0.35),
                    thickness: 1,
                  ),

                  _buildInfoRow(
                    colors,
                    l10n.note,
                    goal!['note'] == null || goal!['note'].toString().isEmpty
                        ? "-"
                        : goal!['note'],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// RIWAYAT TABUNGAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.savingHistory,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  goalHistory.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                size: 48,
                                color: colors.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noSavingHistory,
                                style: TextStyle(color: colors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: displayHistory.map((item) {
                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.green.withOpacity(
                                        .15,
                                      ),
                                      child: const Icon(
                                        Icons.savings,
                                        color: Colors.green,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                           Text(
                                            l10n.addMoney,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),

                                          const SizedBox(height: 4),

                                          Text(
                                            DateFormat(
                                              "dd MMMM yyyy",
                                              "id_ID",
                                            ).format(
                                              DateTime.parse(item['date']),
                                            ),
                                            style: TextStyle(
                                              color: colors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: 'Rp ',
                                        decimalDigits: 0,
                                      ).format(item['amount']),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                  goalHistory.length > 3
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              l10n.showLatestTransactions,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// TOMBOL
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _deleteGoal();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(l10n.deleteGoals),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isCompleted) {
                        final newGoalId = await Navigator.push<int>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddGoalPage(
                              isDark: widget.isDark,
                              oldGoalId: goal!['id'],
                            ),
                          ),
                        );

                        if (newGoalId != null && mounted) {
                          Navigator.pop(context, newGoalId);
                        }
                      } else {
                        _showAddMoneySheet();
                      }
                    },
                    icon: Icon(
                      isCompleted ? Icons.add_circle_outline : Icons.savings,
                    ),
                    label: Text(isCompleted ? l10n.createGoals : l10n.addMoney),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddMoneySheet() {
    final l10n = AppLocalizations.of(context)!;
    _moneyController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (_) {
        final colors = widget.isDark ? dark.darkColors : light.lightColors;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: Container(
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.addMoney,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    l10n.addMoneyDescription,
                    style: TextStyle(color: colors.textSecondary),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(.15),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentSavedMoney,
                          style: TextStyle(color: Colors.green),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          currencyFormatter.format(
                            (goal!['saved_amount'] as num).toDouble(),
                          ),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.amount,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _moneyController,
                    keyboardType: TextInputType.number,

                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      ThousandsSeparatorInputFormatter(),
                    ],

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      prefixText: "Rp ",

                      suffixIcon: _moneyController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _moneyController.clear();
                                setState(() {});
                              },
                            )
                          : null,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text("+ Rp50.000"),
                        onPressed: () => _addAmount(50000),
                      ),

                      ActionChip(
                        label: const Text("+ Rp100.000"),
                        onPressed: () => _addAmount(100000),
                      ),

                      ActionChip(
                        label: const Text("+ Rp200.000"),
                        onPressed: () => _addAmount(200000),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    l10n.date,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Text(
                      DateFormat("d MMMM yyyy", "id_ID").format(DateTime.now()),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(
                      onPressed: () async {
                        if (_moneyController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.enterAmountFirst),
                            ),
                          );
                          return;
                        }

                        final amount = double.parse(
                          _moneyController.text.replaceAll('.', ''),
                        );

                        await DBHelper.addMoneyToGoal(
                          goalId: widget.goalId,
                          amount: amount,
                          note: "Tambah Dana",
                        );

                        if (!mounted) return;

                        await _loadGoal();
                        await _loadHistory();

                        if (!mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.moneyAdded),
                          ),
                        );
                      },

                      child: Text(
                        l10n.simpan,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _addAmount(int amount) {
    final current =
        int.tryParse(_moneyController.text.replaceAll('.', '')) ?? 0;

    final total = current + amount;

    _moneyController.text = NumberFormat.decimalPattern('id_ID').format(total);

    _moneyController.selection = TextSelection.fromPosition(
      TextPosition(offset: _moneyController.text.length),
    );
  }

  Future<void> _deleteGoal() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (_) {
        final colors = widget.isDark ? dark.darkColors : light.lightColors;

        return AlertDialog(
          backgroundColor: colors.background,
          title: Text(
            l10n.deleteGoalTitle,
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            l10n.deleteGoalConfirmation,
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await DBHelper.deleteGoal(widget.goalId);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.goalDeleted)));

      Navigator.pop(context, true);
    }
  }

  Widget _buildInfoRow(dynamic colors, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(title, style: TextStyle(color: colors.textSecondary)),
          ),

          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
