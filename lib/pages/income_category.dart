import 'package:flutter/material.dart';
import 'package:jinahku/database/db_helper.dart';
import 'package:jinahku/l10n/app_localizations.dart';

import '../theme/light_colors.dart' as light;
import '../theme/dark_colors.dart' as dark;

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
        : Colors.black.withOpacity(0.08);
    final backgroundColor = widget.isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.3);

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.divider,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            l10n.buatK,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.namaK,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.batal,
                style: TextStyle(
                  color: colors.blue
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final categoryName = nameController.text.trim();
                if (categoryName.isNotEmpty) {
                  await DBHelper.insertIncomeCategory(categoryName);
                  _refreshCategories(); // Memperbarui list di halaman utama
                  Navigator.pop(context);
                }
              },
              child: Text(
                l10n.simpan,
                style: TextStyle(
                  color: colors.blue
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(int id, String currentName) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.divider,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            l10n.editK,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.namaKB,
                style: TextStyle(fontSize: 16, color: colors.textSecondary),
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
            ],
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
                  await DBHelper.updateIncomeCategory(id, newName);
                  _refreshCategories();
                  Navigator.pop(context);
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
  }

  void _showDeleteConfirmationDialog(int id, String categoryName) {
    final l10n = AppLocalizations.of(context)!;
    final colors = widget.isDark ? dark.darkColors : light.lightColors;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.divider,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            l10n.hapusK,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          content: Text(
            "${l10n.yakinK}, \"$categoryName\" ${l10n.ya}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                l10n.batal,
                style: TextStyle(
                  color: colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await DBHelper.deleteIncomeCategory(id);
                _refreshCategories();
                Navigator.pop(context);
              },
              child: Text(
                l10n.hapus,
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
            padding: const EdgeInsets.only(top: 8.0),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final id = categories[index]['id'] as int;
              final name = categories[index]['code'] as String;

              return ListTile(
                title: Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _showEditCategoryDialog(id, name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _showDeleteConfirmationDialog(id, name),
                    ),
                  ],
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
