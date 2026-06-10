import 'package:flutter/material.dart';
import 'package:jinahku/database/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kategori App',
      theme: ThemeData(
        primaryColor: const Color(0xFF334155),
        scaffoldBackgroundColor: Colors.white,
      ),
      debugShowCheckedModeBanner: false,
      home: const KategoriScreen(),
    );
  }
}

class KategoriScreen extends StatefulWidget {
  const KategoriScreen({Key? key}) : super(key: key);

  @override
  State<KategoriScreen> createState() => _KategoriScreenState();
}

class _KategoriScreenState extends State<KategoriScreen> {
  bool isPengeluaran = true;

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedTypeInDialog = 'Pengeluaran';

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() async {
    setState(() {
      _isLoading = true;
    });

    String typeString = isPengeluaran ? 'pengeluaran' : 'pemasukan';
    final data = await DBHelper.getCategoriesByType(typeString);

    setState(() {
      _categories = data;
      _isLoading = false;
    });
  }

  void _addCategory(String name, String type) async {
    String dbType = type == 'Pemasukan' ? 'pemasukan' : 'pengeluaran';
    await DBHelper.insertCategory(name, dbType);
    _refreshCategories();
  }

  void _deleteCategory(int id) async {
    await DBHelper.deleteCategory(id);
    _refreshCategories();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Kategori berhasil dihapus')));
  }

  void _editCategoryDialog(int id, String currentName) {
    _categoryNameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Edit Category',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _categoryNameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              if (_categoryNameController.text.trim().isNotEmpty) {
                await DBHelper.updateCategory(
                  id,
                  _categoryNameController.text.trim(),
                );
                _refreshCategories();
                Navigator.pop(context);
              }
            },
            child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog() {
    _categoryNameController.clear();
    _selectedTypeInDialog = isPengeluaran ? 'Pengeluaran' : 'Pemasukan';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              title: const Text(
                'Buat Kategori',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Kategori',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  TextField(
                    controller: _categoryNameController,
                    cursorColor: const Color(0xFFFFFFFF),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Jenis Kategori',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Pengeluaran',
                            groupValue: _selectedTypeInDialog,
                            activeColor: const Color(0xFF02AFD8),
                            onChanged: (value) => setStateDialog(
                              () => _selectedTypeInDialog = value!,
                            ),
                          ),
                          const Text(
                            'Pengeluaran',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: 'Pemasukan',
                            groupValue: _selectedTypeInDialog,
                            activeColor: const Color(0xFF02AFD8),
                            onChanged: (value) => setStateDialog(
                              () => _selectedTypeInDialog = value!,
                            ),
                          ),
                          const Text(
                            'Pemasukan',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'BATAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final newCategory = _categoryNameController.text.trim();
                    if (newCategory.isNotEmpty) {
                      _addCategory(newCategory, _selectedTypeInDialog);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'SIMPAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF334155),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Aksi tombol kembali
          },
        ),
        title: const Text(
          'Kategori',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _showCreateCategoryDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: const Color(0xFFFFFFFF)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isPengeluaran) {
                          setState(() {
                            isPengeluaran = true;
                          });
                          _refreshCategories();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isPengeluaran
                              ? const Color(0xFF02AFD8)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Color(0xFFFFFFFF)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pengeluaran',
                          style: TextStyle(
                            color: isPengeluaran ? Colors.white : Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isPengeluaran) {
                          setState(() {
                            isPengeluaran = false;
                          });
                          _refreshCategories();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !isPengeluaran
                              ? const Color(0xFF02AFD8)
                              : Colors.transparent, // Hijau saat aktif
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Pemasukan',
                          style: TextStyle(
                            color: !isPengeluaran ? Colors.white : Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Kategori (List View)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF02AFD8)),
                  )
                : _categories.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada kategori',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Color(0xFF334155), height: 1),
                    itemBuilder: (context, index) {
                      final item = _categories[index];
                      final idCategory = item['id_category'] as int;
                      final nameCategory = item['name'] as String;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        title: Text(
                          nameCategory,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () =>
                                  _editCategoryDialog(idCategory, nameCategory),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => _deleteCategory(idCategory),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
