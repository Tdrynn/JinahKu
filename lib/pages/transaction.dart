import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jinahku/pages/history.dart';
import 'package:jinahku/pages/main_pages.dart';

import '../database/db_helper.dart';
import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:jinahku/l10n/app_localizations.dart';

class Transaction extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTransactionSaved;

  const Transaction({
    super.key,
    required this.isDark,
    required this.onTransactionSaved
  });

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  bool isExpense = true;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  // Categories list with matching iOS icons
  final List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Makanan', 'icon': Icons.restaurant},
    {'name': 'Transportasi', 'icon': Icons.directions_car},
    {'name': 'Hiburan', 'icon': Icons.movie},
    {'name': 'Belanja', 'icon': Icons.shopping_bag},
    {'name': 'Tagihan', 'icon': Icons.receipt},
    {'name': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Gaji', 'icon': Icons.work},
    {'name': 'Freelance', 'icon': Icons.laptop},
    {'name': 'Bisnis', 'icon': Icons.store},
    {'name': 'Hibah', 'icon': Icons.card_giftcard},
    {'name': 'Investasi', 'icon': Icons.trending_up},
    {'name': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = '';
  }

  // Indonesian custom date formatting
  String _formatIndonesianDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return "${date.day}-${months[date.month - 1]}-${date.year}";
  }

  void _showCategoryPicker(BuildContext context, dynamic colors) {
    final categories = isExpense ? expenseCategories : incomeCategories;
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
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final item = categories[index];
                    final isSelected = _selectedCategory == item['name'];
                    return ListTile(
                      leading: Icon(
                        item['icon'],
                        color: isSelected ? colors.blue : colors.textSecondary,
                      ),
                      title: Text(
                        item['name'],
                        style: TextStyle(
                          color: isSelected ? colors.blue : colors.textPrimary,
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
                          _selectedCategory = item['name'];
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
        msg: "Mohon isi jumlah transaksi",
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
        msg: "Jumlah transaksi harus valid",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      Fluttertoast.showToast(
        msg: isExpense
            ? "Pilih kategori pengeluaran"
            : "Pilih sumber pemasukan",
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
      category: _selectedCategory,
      date: _selectedDate,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    Fluttertoast.showToast(
      msg: "Transaksi berhasil disimpan! 🎉",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: colors.green,
      textColor: Colors.white,
    );

    widget.onTransactionSaved();

    setState(() {
      _amountController.clear();
      _noteController.clear();
      _selectedCategory = '';
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
    final textCyan = const Color(0xFF00AED6);

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
                    // Smooth Sliding Liquid Glass Active Indicator Pill
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

                    // Label Buttons Layer
                    Row(
                      children: [
                        // Pemasukan Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = false;
                                _selectedCategory = '';
                              });
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
                        // Pengeluaran Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = true;
                                _selectedCategory = '';
                              });
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

            // Jumlah (Amount) Label and Styled Input
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

            // Kategori Dropdown Box
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
                    if (_selectedCategory.isNotEmpty) ...[
                      Icon(
                        (isExpense ? expenseCategories : incomeCategories)
                                .firstWhere(
                                  (c) => c['name'] == _selectedCategory,
                                )['icon']
                            as IconData,
                        color: colors.blue,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        _selectedCategory.isEmpty
                            ? (isExpense
                                  ? 'Pilih kategori pengeluaran'
                                  : 'Pilih sumber pemasukan')
                            : _selectedCategory,
                        style: TextStyle(
                          color: _selectedCategory.isEmpty
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

            // Tanggal Date Picker Box
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
                        _formatIndonesianDate(_selectedDate),
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
                  hintText: 'tambahkan deskripsi....',
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
