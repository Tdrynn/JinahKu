import 'package:flutter/material.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';
import 'package:jinahku/pages/transaction.dart';

import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;
import 'category_icons.dart';

class IncomeCategoryPage extends StatefulWidget {
  final bool isDark;
  final bool isEnglish;
  const IncomeCategoryPage({
    super.key,
    required this.isDark,
    required this.isEnglish,
  });

  @override
  State<IncomeCategoryPage> createState() => _IncomeCategoryPageState();
}

class _IncomeCategoryPageState extends State<IncomeCategoryPage> {
  late Future<List<Map<String, dynamic>>> _incomeCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final iconColor = widget.isDark ? Colors.white : Colors.black87;
    final borderColor = widget.isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.blue.withOpacity(0.5);
    final backgroundColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.blue.withOpacity(0.3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
        ),
      ),
    );
  }

  void _refreshCategories() {
    setState(() {
      _incomeCategoriesFuture = DBHelper.getIncomeCategories();
    });
  }

  void _showCreateCategoryDialog() {
    final TextEditingController nameController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    String selectedIcon = 'category';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.divider,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                l10n.buatK,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.namaK,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      cursorColor: colors.blue,
                      autofocus: true,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colors.blue, width: 2),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.brown, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Ikon",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIconPicker(
                      colors: colors,
                      selectedIcon: selectedIcon,
                      onSelect: (key) {
                        setDialogState(() => selectedIcon = key);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.batal, style: TextStyle(color: colors.blue)),
                ),
                TextButton(
                  onPressed: () async {
                    final categoryName = nameController.text.trim();
                    if (categoryName.isNotEmpty) {
                      await DBHelper.insertIncomeCategory(
                        categoryName,
                        icon: selectedIcon,
                      );
                      Navigator.pop(context);
                      _refreshCategories();
                    }
                  },
                  child: Text(
                    l10n.simpan,
                    style: TextStyle(color: colors.blue),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildIconPicker({
    required dynamic colors,
    required String selectedIcon,
    required ValueChanged<String> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CategoryIcons.options.entries.map((entry) {
        final isSelected = entry.key == selectedIcon;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelect(entry.key),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.blue.withOpacity(0.15)
                  : colors.background.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? colors.blue : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Icon(
              entry.value,
              color: isSelected ? colors.blue : colors.textSecondary,
              size: 20,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showEditCategoryDialog(
    int id,
    String code,
    String currentIcon
  ) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = CategoryUI.getName(l10n, code);
    final TextEditingController nameController = TextEditingController(
      text: displayName,
    );
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    String selectedIcon = currentIcon;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.divider,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Text(
                l10n.editK,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.namaKB,
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    TextField(
                      controller: nameController,
                      cursorColor: colors.blue,
                      autofocus: true,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colors.blue, width: 2),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: colors.blue, width: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Ikon",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildIconPicker(
                      colors: colors,
                      selectedIcon: selectedIcon,
                      onSelect: (key) {
                        setDialogState(() => selectedIcon = key);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.batal,
                    style: TextStyle(
                      color: colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    if (newName.isNotEmpty) {
                      await DBHelper.updateIncomeCategory(
                        id,
                        newName,
                        icon: selectedIcon,
                      );
                      Navigator.pop(context);
                      _refreshCategories();
                    }
                  },
                  child: Text(
                    l10n.simpan,
                    style: TextStyle(
                      color: colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id, String categoryName) {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;
    final displayName = CategoryUI.getName(l10n, code);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: colors.divider,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.red.withOpacity(.12),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                  size: 38,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "${l10n.hapusK} $displayName?",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                l10n.yakinK,
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: BorderSide(color: colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.batal,
                        style: TextStyle(color: colors.blue),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                      label: Text(l10n.hapus),
                      onPressed: () async {
                        await DBHelper.deleteIncomeCategory(id);
                        Navigator.pop(context);
                        _refreshCategories();
                      },
                    ),
                  ),
                ],
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
    final colors = widget.isDark ? dark.darkColors : light.lightColors;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        backgroundColor: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: _glassIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          l10n.kpemasukan,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),

      backgroundColor: colors.background,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _incomeCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Belum ada data kategori pemasukan.",
                style: TextStyle(color: colors.textPrimary, fontSize: 16),
              ),
            );
          }

          final categories = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 10.0),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final id = categories[index]['id'] as int;
              final code = categories[index]['code'] as String;
              final iconKey =
                  categories[index]['icon'] as String? ?? 'category';
              final displayName = CategoryUI.getName(l10n, code);

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colors.divider),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.blue.withOpacity(0.12),
                    child: Icon(
                      CategoryIcons.resolve(iconKey),
                      color: colors.blue,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    l10n.kpemasukan,
                    style: TextStyle(color: colors.textSecondary, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.08),
                        ),
                        icon: Icon(Icons.edit, color: colors.blue),
                        onPressed: () =>
                            _showEditCategoryDialog(id, code, iconKey),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.08),
                        ),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _showDeleteConfirmationDialog(id, code),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 5),
        child: _glassIconButton(
          icon: Icons.add,
          onTap: () {
            _showCreateCategoryDialog();
          },
        ),
      ),
    );
  }
}
