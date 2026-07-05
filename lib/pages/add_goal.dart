import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:jinahku/l10n/app_localizations.dart';

import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'package:jinahku/utils/thousands_separator_input_formatter.dart';

class AddGoalPage extends StatefulWidget {
  final bool isDark;
  final int? goalId;
  final int? oldGoalId;

  const AddGoalPage({
    super.key,
    required this.isDark,
    this.goalId,
    this.oldGoalId,
  });

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool get isEdit => widget.goalId != null;

  File? _selectedImage;

  DateTime _selectedDate = DateTime.now();
  bool _isReminder = false;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      _loadGoal();
    }
  }

  Future<void> _loadGoal() async {
    final goal = await DBHelper.getGoalById(widget.goalId!);

    if (goal == null) return;

    setState(() {
      _goalController.text = goal['goal_name'];

      _amountController.text = goal['target_amount']
          .toStringAsFixed(0)
          .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

      _selectedDate = DateTime.parse(goal['target_date']);

      _noteController.text = goal['note'] ?? "";

      _isReminder = goal['reminder'] == 1;

      if (goal['image_path'] != null) {
        _selectedImage = File(goal['image_path']);
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Kompres
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (pickedImage == null) return;

    final imageFile = File(pickedImage.path);

    // DEBUG
    print("Ukuran gambar: ${await imageFile.length()} bytes");
    print("Ukuran MB: ${(await imageFile.length()) / (1024 * 1024)}");

    // Maksimal 5 MB
    const maxSize = 5 * 1024 * 1024;

    if (await imageFile.length() > maxSize) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ukuran foto maksimal adalah 5 MB.")),
      );
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();

    final fileName =
        "goal_${DateTime.now().millisecondsSinceEpoch}${p.extension(pickedImage.path)}";

    final savedImage = await imageFile.copy(p.join(appDir.path, fileName));

    if (!mounted) return;

    setState(() {
      _selectedImage = savedImage;
    });
  }

  @override
  void dispose() {
    _goalController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, dynamic colors) async {
    final today = DateTime.now();

    final todayOnly = DateTime(today.year, today.month, today.day);

    final initialDate = _selectedDate.isBefore(todayOnly)
        ? todayOnly
        : _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: todayOnly,
      lastDate: DateTime(2100),

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

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final pageBgColor = colors.background;
    final cardBgColor = colors.card;
    final primaryColor = colors.blue;

    return Scaffold(
      backgroundColor: pageBgColor,

      appBar: AppBar(
        backgroundColor: pageBgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          isEdit ? l10n.editGoals : l10n.createGoals,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// FOTO
              /// FOTO
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),

                child: Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: _selectedImage == null
                            ? Image.asset(
                                "assets/images/goals.webp",
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _selectedImage!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),

                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: OutlinedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.photo_camera_outlined, size: 16),
                        label: Text(l10n.changePhoto),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Center(
                child: Text(
                  l10n.goalPhotoHint,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              /// Nama Goals
              Text(
                l10n.goalName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _goalController,
                maxLength: 40,
                decoration: InputDecoration(
                  hintText: l10n.goalNameHint,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              /// Target Nominal
              Text(
                l10n.targetAmount,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),

              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: InputDecoration(
                  prefixText: "Rp ",
                  hintText: "0",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                l10n.targetAmountHint,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 10),

              /// Target Tanggal
              Text(
                l10n.targetDate,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () => _selectDate(context, colors),

                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: _formatDate(_selectedDate),
                    ),

                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.calendar_month_outlined),

                      suffixIcon: const Icon(Icons.keyboard_arrow_down),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Catatan
              Text(
                l10n.goalNote,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 6),

              Stack(
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 5,
                    maxLength: 100,

                    onChanged: (value) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: l10n.goalNoteHint,

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 90),
                        child: Icon(Icons.description_outlined),
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),

                      contentPadding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        34, // kasih ruang bawah buat counter
                      ),

                      counterText: "",
                    ),
                  ),

                  Positioned(
                    right: 16,
                    bottom: 12,

                    child: Text(
                      "${_noteController.text.length}/100",
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              /// Switch
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.notifications_none),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.enableGoalReminder,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 2),

                          Text(
                            l10n.goalReminderDescription,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    Switch(
                      value: _isReminder,
                      activeColor: colors.blue,
                      onChanged: (value) {
                        setState(() {
                          _isReminder = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_goalController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.goalNameRequired)),
                      );
                      return;
                    }

                    if (_amountController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.targetAmountRequired)),
                      );
                      return;
                    }
                    
                    final targetAmount = double.parse(
                      _amountController.text.replaceAll('.', ''),
                    );

                    // Validasi nominal target
                    if (targetAmount < 1000) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.minimumTarget)),
                      );
                      return;
                    }

                    if (targetAmount > 999999999) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.maximumTarget)),
                      );
                      return;
                    }

                    if (isEdit) {
                      await DBHelper.updateGoal(
                        id: widget.goalId!,
                        goalName: _goalController.text,
                        targetAmount: targetAmount,
                        targetDate: _selectedDate,
                        note: _noteController.text,
                        imagePath: _selectedImage?.path,
                        reminder: _isReminder,
                      );

                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l10n.goalUpdated)));

                      Navigator.pop(context);
                    } else {
                      final goalId = await DBHelper.insertGoal(
                        goalName: _goalController.text,
                        targetAmount: targetAmount,
                        targetDate: _selectedDate,
                        note: _noteController.text,
                        imagePath: _selectedImage?.path,
                        reminder: _isReminder,
                      );

                      // Hapus goal lama jika ada
                      if (widget.oldGoalId != null) {
                        await DBHelper.deleteGoal(widget.oldGoalId!);
                      }

                      if (!mounted) return;

                      // Kembali ke halaman sebelumnya sambil mengirim id goal baru
                      Navigator.pop(context, goalId);
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Text(
                    isEdit ? l10n.saveChanges : l10n.saveGoals,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
