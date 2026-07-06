import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jinahku/pages/history.dart';
import 'package:jinahku/pages/main_pages.dart';
import 'package:jinahku/utils/thousands_separator_input_formatter.dart';
import 'package:jinahku/models/transaction_data.dart';

import '../database/db_helper.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:jinahku/l10n/app_localizations.dart';
import 'category_icons.dart';

class CategoryUI {
  static const defaultCodes = {
    'salary', 'allowance', 'freelance', 'business',
    'food', 'transport', 'shopping', 'bills', 'entertainment', 'other',
  };

  static String getName(AppLocalizations l10n, String code) {
    switch (code) {
      case 'salary': return l10n.salary;
      case 'allowance': return l10n.allowance;
      case 'freelance': return l10n.freelance;
      case 'business': return l10n.business;
      case 'food': return l10n.food;
      case 'transport': return l10n.transport;
      case 'shopping': return l10n.shopping;
      case 'bills': return l10n.bills;
      case 'entertainment': return l10n.entertainment;
      case 'other': return l10n.other;

      default:
        return code
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e.isEmpty ? '' : e[0].toUpperCase() + e.substring(1))
        .join(' ');
    }
  }
}

class Transaction extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTransactionSaved;
  final TransactionData? initialData;

  const Transaction({
    super.key,
    required this.isDark,
    required this.onTransactionSaved,
    this.initialData,
  });

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategoryCode = '';
  String _selectedCategoryIcon = 'category';
  DateTime _selectedDate = DateTime.now();

  List<Map<String, dynamic>> _loadedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategoriesFromDB();

    if (widget.initialData != null) {
      final formatter = NumberFormat.decimalPattern('id');
      _amountController.text = formatter.format(widget.initialData!.amount);
      isExpense = true;
      _selectedDate = widget.initialData!.date;
    }
  }

  Future<void> _loadCategoriesFromDB() async {
    final categories = isExpense
        ? await DBHelper.getExpenseCategories()
        : await DBHelper.getIncomeCategories();

    setState(() {
      _loadedCategories = categories;
    });
  }

  String _formatDate(DateTime date, BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return DateFormat(
      'd MMMM yyyy',
      locale,
    ).format(date);
  }

  @override
  void didUpdateWidget(covariant Transaction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialData != oldWidget.initialData &&
        widget.initialData != null) {
      final formatter = NumberFormat.decimalPattern('id');
      _amountController.text = formatter.format(widget.initialData!.amount);
      _selectedCategoryCode = "shopping";
      _selectedCategoryIcon = "shopping_bag";
      _noteController.text = widget.initialData!.note ?? '';
      _selectedDate = widget.initialData!.date;
      isExpense = widget.initialData!.type == 'expense';

      _loadCategoriesFromDB();
    }
  }

  void _showCategoryPicker(BuildContext context, dynamic colors) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isExpense ? l10n.pilihK : l10n.pilihs,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _loadedCategories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _loadedCategories.length,
                        itemBuilder: (context, index) {
                          final item = _loadedCategories[index];
                          final isSelected =
                              _selectedCategoryCode == item['code'];
                          return ListTile(
                            leading: Icon(
                              CategoryIcons.resolve(item['icon'] as String?),
                              color: isSelected
                                  ? colors.blue
                                  : colors.textSecondary,
                            ),
                            title: Text(
                              CategoryUI.getName(l10n, item['code']),
                              style: TextStyle(
                                color: isSelected
                                    ? colors.blue
                                    : colors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontFamily: 'Inter',
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: colors.blue)
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedCategoryCode = item['code'];
                                _selectedCategoryIcon =
                                    item['icon'] as String? ?? 'category';
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate(BuildContext context, dynamic colors) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: widget.isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: colors.blue,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E293B),
                    onSurface: Colors.white,
                  ),
                  dialogBackgroundColor: const Color(0xFF0F172A),
                )
              : ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: colors.blue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: colors.textPrimary,
                  ),
                  dialogBackgroundColor: Colors.white,
                ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction(dynamic colors, dynamic l10n) async {
    final rawAmount = _amountController.text.replaceAll('.', '');
    if (rawAmount.isEmpty) {
      Fluttertoast.showToast(
        msg: l10n.mohonT,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final double? amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: l10n.jumlahT,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_selectedCategoryCode.isEmpty) {
      Fluttertoast.showToast(
        msg: isExpense ? l10n.kategoriPN : l10n.kategoriPK,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: colors.red,
        textColor: Colors.white,
      );
      return;
    }

    await DBHelper.insertTransaction(
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      categoryCode: _selectedCategoryCode,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    if (isExpense) {
      await DBHelper.syncGoalWithBalance();
    }

    Fluttertoast.showToast(
      msg: l10n.disimpan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: colors.green,
      textColor: Colors.white,
    );

    widget.onTransactionSaved();

    setState(() {
      _amountController.clear();
      _noteController.clear();
      _selectedCategoryCode = '';
      _selectedCategoryIcon = 'category';
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final l10n = AppLocalizations.of(context)!;

    final pageBgColor = widget.isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final cardBgColor = widget.isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFEDF2F7);
    final inputBgColor = widget.isDark
        ? const Color(0xFF182030)
        : const Color(0xFFE2E8F0);
    const textCyan = Color(0xFF00AED6);

    return Scaffold(
      backgroundColor: pageBgColor,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          l10n.transaksi,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: pageBgColor,
        elevation: 0,
        foregroundColor: colors.textPrimary,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 160),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.fastOutSlowIn,
                      alignment: isExpense
                          ? const Alignment(1.0, 0.0)
                          : const Alignment(-1.0, 0.0),
                      child: FractionallySizedBox(
                        widthFactor: 0.5,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: textCyan,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: textCyan.withOpacity(0.35),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = false;
                                _selectedCategoryCode = '';
                                _selectedCategoryIcon = 'category';
                              });
                              _loadCategoriesFromDB();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  color: !isExpense
                                      ? Colors.white
                                      : colors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                                child: Text(l10n.pemasukan),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = true;
                                _selectedCategoryCode = '';
                                _selectedCategoryIcon = 'category';
                              });
                              _loadCategoriesFromDB();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: TextStyle(
                                  color: isExpense
                                      ? Colors.white
                                      : colors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                ),
                                child: Text(l10n.pengeluaran),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              l10n.jumlah,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: inputBgColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: textCyan.withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Rp. ',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Picker Kategori
            Text(
              l10n.kategori,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showCategoryPicker(context, colors),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    if (_selectedCategoryCode.isNotEmpty) ...[
                      Icon(
                        CategoryIcons.resolve(_selectedCategoryIcon),
                        color: colors.blue,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _selectedCategoryCode.isEmpty
                            ? (isExpense ? l10n.kategoriPN : l10n.kategoriPK)
                            : CategoryUI.getName(l10n, _selectedCategoryCode),
                        style: TextStyle(
                          color: _selectedCategoryCode.isEmpty
                              ? colors.textSecondary.withOpacity(0.7)
                              : colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Picker Tanggal
            Text(
              l10n.tanggal,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _selectDate(context, colors),
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(
                          _selectedDate,
                          context
                        ),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today_outlined,
                      color: colors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Catatan
            Text(
              l10n.catatan,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _noteController,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  hintText: l10n.tambahD,
                  hintStyle: TextStyle(
                    color: colors.textSecondary.withOpacity(0.5),
                    fontFamily: 'Inter',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Simpan
            GestureDetector(
              onTap: () => _saveTransaction(colors, l10n),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.blue, colors.blue.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: colors.blue.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    l10n.simpan,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
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

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
