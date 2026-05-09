import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class firstload extends StatefulWidget {
  final bool isEnglish;
  final Function(String) onChangeLanguage;
  const firstload({
    super.key,
    required this.isEnglish,
    required this.onChangeLanguage,
  });

  @override
  State<firstload> createState() => _firstloadState();
}

class _firstloadState extends State<firstload> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController incomeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String selectedIncomeSources = "";

  Future<void> pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickDate != null) {
      setState(() {
        dateController.text = "${pickDate.day}/${pickDate.month}/${pickDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> incomeSources = [
      l10n.gaji,
      l10n.freelance,
      l10n.bisnis,
      l10n.investasi,
      l10n.lainnya,
    ];

    if (selectedIncomeSources.isEmpty) {
      selectedIncomeSources = incomeSources.first;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/wallet.webp',

                      width: 140,
                      height: 140,
                    ),

                    Text(
                      l10n.masukan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),

                    Text(
                      l10n.total,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                l10n.namaP,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: l10n.kamu,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Image.asset('assets/icons/person.webp'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18)
                  )
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.pemasukan,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                keyboardType: TextInputType.number,
                controller: incomeController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: "1.000.000",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Image.asset('assets/icons/Rp.webp'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                l10n.sumber,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: selectedIncomeSources,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                items: incomeSources.map((source) {
                  return DropdownMenuItem(
                    value: source,
                    child: Text(source),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selectedIncomeSources = value!;
                  });
                },
              ),

              const SizedBox(height: 24),

              Text(
                l10n.tanggal,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: dateController,
                readOnly: true,
                onTap: pickDate,

                decoration: InputDecoration(
                  hintText: l10n.pilih,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),

                    child: Image.asset('assets/icons/Calendar.webp'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    print(nameController.text);
                    print(incomeController.text.replaceAll('.', ''));
                    print(selectedIncomeSources);
                    print(dateController.text);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0C6592),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    l10n.lanjutkan,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        )
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
    String newText = formatter.format(int.parse(newValue.text.replaceAll(separator, '')));

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
