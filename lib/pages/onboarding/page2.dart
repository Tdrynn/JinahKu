import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/models/modelUser.dart';
import 'package:jinahku/pages/onboarding/page1.dart';
import 'package:jinahku/pages/onboarding/page3.dart';
import 'package:intl/intl.dart';

class Page2 extends StatefulWidget {
  final OnboardingData data;
  final VoidCallback onNext;

  const Page2({super.key, required this.data, required this.onNext});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<Map<String, dynamic>> sources = [];

  int? selectedId;
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
    selectedId = widget.data.sourceId;
    selectedDate = widget.data.date;
  }

  void loadSources() async {
    final data = await DBHelper.getIncomeSource();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF00041C),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              SizedBox(
                height: 460,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Image.asset(
                    'assets/images/BG_PG2.webp',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    alignment: .topCenter,
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 430),
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
                    const Text(
                      "Jumlah Pemasukan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Angka ini akan digunakan sebagai pendapatan bulanan",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: incomeController,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        ThousandsSeparatorInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Jumlah pemasukan wajib diisi';
                        }
                        if (double.tryParse(value.replaceAll('.', '')) == null) {
                          return 'Masukkan angka yang valid';
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
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF243B55),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(color: Colors.blue.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Sumber pemasukan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF243B55),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade400),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<int>(
                          validator: (value) {
                            if (value == null) {
                              return 'Pilih sumber pemasukan';
                            }
                            return null;
                          },
                          dropdownColor: const Color(0xFF243B55),
                          value: selectedId,
                          hint: Text(
                            l10n.pilih,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          items: sources.map((item) {
                            return DropdownMenuItem<int>(
                              value: item['id'] as int,
                              child: Text(item['name'] ?? item['code']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedId = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      "Tanggal",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
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
                                  ? "10"
                                  : "${selectedDate!.day}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
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
                      height: 58,
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
                              const SnackBar(
                                content: Text("Tanggal wajib dipilih"),
                              ),
                            );
                            return;
                          }
                          widget.data.income =
                              double.tryParse(incomeController.text.replaceAll('.', '')) ?? 0;
                          widget.data.sourceId = selectedId;
                          widget.data.date = selectedDate;
                          widget.onNext();
                        },

                        child: Text(
                          l10n.lanjutkan,
                          style: const TextStyle(
                            fontSize: 22,
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
            ],
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
  static const separator = '.';
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(
      int.parse(newValue.text.replaceAll(separator, '')),
    );

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
