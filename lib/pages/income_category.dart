import 'package:flutter/material.dart';
import 'package:jinahku/database/db_helper.dart';

class IncomeCategoryPage extends StatefulWidget {
  const IncomeCategoryPage({super.key});

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

  // Fungsi untuk memuat ulang data pemasukan dari database
  void _refreshCategories() {
    setState(() {
      _incomeCategoriesFuture = DBHelper.getIncomeCategories();
    });
  }

  void _showCreateCategoryDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          title: const Text(
            "Buat Kategori",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nama Kategori",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              TextField(
                controller: nameController,
                cursorColor: Colors.red[700],
                autofocus: true, // Otomatis membuka keyboard saat pop-up muncul
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700]!, width: 2),
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
                "BATAL",
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final categoryName = nameController.text.trim();
                if (categoryName.isNotEmpty) {
                  // Langsung simpan sebagai kategori pemasukan ke database
                  await DBHelper.insertIncomeCategories(categoryName);
                  _refreshCategories(); // Memperbarui list di halaman utama
                  Navigator.pop(context);
                }
              },
              child: Text(
                "SIMPAN",
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

  void _showEditCategoryDialog(int id, String currentName) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          title: const Text(
            "Ubah Kategori",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Nama Kategori",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              TextField(
                controller: nameController,
                cursorColor: Colors.red[700],
                autofocus: true,
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red[700]!, width: 2),
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
                "BATAL",
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await DBHelper.updateIncomeSource(id, newName);
                  _refreshCategories();
                  Navigator.pop(context);
                }
              },
              child: Text(
                "SIMPAN",
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

  void _showDeleteConfirmationDialog(int id, String categoryName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          title: const Text(
            "Hapus Kategori",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus kategori \"$categoryName\"?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BATAL",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await DBHelper.deleteIncomeSource(id);
                _refreshCategories();
                Navigator.pop(context);
              },
              child: Text(
                "HAPUS",
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.red[700], // Warna merah AppBar tetap dipertahankan
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Kategori Pemasukan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              _showCreateCategoryDialog();
            },
          ),
        ],
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _incomeCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada data kategori pemasukan.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
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
    );
  }
}
