import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page3.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../category_icons.dart';
import '../transaction.dart';

class Page2 extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onNext;

  const Page2({super.key, required this.data, required this.onNext});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<Map<String, dynamic>> sources = [];
  String? selectedCode;
  DateTime? selectedDate;

  final incomeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadSources();
    incomeController.text = widget.data.income == 0
        ? ''
        : widget.data.income.toStringAsFixed(0);
    selectedCode = widget.data.sourceCode;
    selectedDate = widget.data.date;
  }

  void loadSources() async {
    final data = await DBHelper.getIncomeCategories();
    setState(() {
      sources = data;
    });
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _showCategoryPicker(BuildContext context, FormFieldState<String> fieldState) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B263B),
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.pilihs,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: sources.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: sources.length,
                        itemBuilder: (context, index) {
                          final item = sources[index];
                          final isSelected = selectedCode == item['code'];
                          return ListTile(
                            leading: Icon(
                              CategoryIcons.resolve(item['icon'] as String?),
                              color: isSelected ? Colors.blue : Colors.white70,
                            ),
                            title: Text(
                              CategoryUI.getName(l10n, item['code'] as String),
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.white,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.blue)
                                : null,
                            onTap: () {
                              setState(() {
                                selectedCode = item['code'] as String;
                              });
                              fieldState.didChange(item['code'] as String);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1B263B),
        body: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          child: Image.asset(
                            'assets/images/BG_PG2.webp',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Expanded(
                          child: Transform.translate(
                            offset: const Offset(0, -19),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
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
                                  Text(
                                    l10n.jumlah,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    l10n.angkaI,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: incomeController,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                      ThousandsSeparatorInputFormatter(),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return l10n.pemasukanWajib;
                                      }
                                      if (double.tryParse(value.replaceAll('.', '')) == null) {
                                        return l10n.jumlahT;
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      prefixText: "Rp. ",
                                      prefixStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      hintText: "0",
                                      hintStyle: const TextStyle(color: Colors.white70),
                                      filled: true,
                                      fillColor: const Color(0xFF243B55),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(color: Colors.blue.shade400),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    l10n.sumber,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  FormField<String>(
                                    initialValue: selectedCode,
                                    validator: (value) {
                                      if (selectedCode == null) {
                                        return l10n.pilih;
                                      }
                                      return null;
                                    },
                                    builder: (FormFieldState<String> state) {
                                      final selectedItem = sources.firstWhere(
                                        (element) => element['code'] == selectedCode,
                                        orElse: () => {},
                                      );
                                      final hasIcon = selectedItem.containsKey('icon') && selectedItem['icon'] != null;

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          GestureDetector(
                                            onTap: () => _showCategoryPicker(context, state),
                                            child: Container(
                                              height: 58,
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF243B55),
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: state.hasError ? Colors.red.shade400 : Colors.blue.shade400,
                                                  width: state.hasError ? 2 : 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  if (selectedCode != null && hasIcon) ...[
                                                    Icon(
                                                      CategoryIcons.resolve(selectedItem['icon'] as String?),
                                                      color: Colors.blue,
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      selectedCode == null
                                                          ? l10n.pilih
                                                          : CategoryUI.getName(l10n, selectedCode!),
                                                      style: TextStyle(
                                                        color: selectedCode == null ? Colors.white54 : Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (state.hasError)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8, left: 12),
                                              child: Text(
                                                state.errorText ?? '',
                                                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 18),
                                  Text(
                                    l10n.date,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: pickDate,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF243B55),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.blue.shade400),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            selectedDate == null
                                                ? " "
                                                : DateFormat('dd').format(selectedDate!),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.calendar_month,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                      onPressed: () {
                                        if (!_formKey.currentState!.validate()) {
                                          return;
                                        }
                                        if (selectedDate == null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(l10n.tanggalWajib)),
                                          );
                                          return;
                                        }
                                        widget.data.income = double.tryParse(
                                              incomeController.text.replaceAll('.', ''),
                                            ) ?? 0;
                                        widget.data.sourceCode = selectedCode;
                                        widget.data.date = selectedDate;
                                        widget.onNext();
                                      },
                                      child: Text(
                                        l10n.lanjutkan,
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      buildDot(false),
                                      buildDot(true),
                                      buildDot(false),
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
      ),
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

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;
    final cleanString = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (cleanString.isEmpty) {
      return const TextEditingValue(text: '', selection: TextSelection.collapsed(offset: 0));
    }
    final formatter = NumberFormat.decimalPattern('id');
    final newText = formatter.format(int.parse(cleanString));
    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}