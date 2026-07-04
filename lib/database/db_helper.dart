import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jinahku.db');

    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await _createDB(db, version);
        await _createTransactionTable(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTransactionTable(db);
        }
      },

      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        await _createTransactionTable(db);
      },
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS income_source (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        monthly_income REAL NOT NULL,
        income_date TEXT NOT NULL,
        avatar TEXT NOT NULL,
        income_source_id INTEGER NOT NULL,
        FOREIGN KEY (income_source_id)
        REFERENCES income_source(id)
      )
    ''');

    await db.insert('income_source', {'code': 'salary'});
    await db.insert('income_source', {'code': 'allowance'});
    await db.insert('income_source', {'code': 'freelance'});
    await db.insert('income_source', {'code': 'business'});
    await db.insert('income_source', {'code': 'other'});
  }

  static Future<void> _createTransactionTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  static Future<List<Map<String, dynamic>>> getIncomeSource() async {
    final db = await database;

    return await db.query('income_source');
  }

  static Future<int> insertUser({
    required String username,
    required double monthlyIncome,
    required DateTime incomeDate,
    required String avatar,
    required int incomeSourceId,
  }) async {
    final db = await database;

    return await db.insert('user_profile', {
      'username': username,
      'monthly_income': monthlyIncome,
      'income_date': incomeDate.toIso8601String(),
      'avatar': avatar,
      'income_source_id': incomeSourceId,
    });
  }

  static Future<bool> isFirstTime() async {
    final db = await database;

    final result = await db.query('user_profile');

    return result.isEmpty;
  }

  static Future<List<Map<String, dynamic>>> getUserProfile() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT
        user_profile.id,
        user_profile.username,
        user_profile.monthly_income,
        user_profile.income_date,
        user_profile.avatar,
        income_source.code as income_source
      FROM user_profile
      JOIN income_source
      ON user_profile.income_source_id = income_source.id
    ''');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        user_profile.username,
        user_profile.monthly_income,
        user_profile.avatar
      FROM user_profile
      ORDER BY id DESC
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // TRANSACTION METHODS
  static Future<int> insertTransaction({
    required String type,
    required double amount,
    required String category,
    required DateTime date,
    String? note,
  }) async {
    final db = await database;

    return await db.insert('transactions', {
      'type': type,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'note': note,
    });
  }

  static Future<List<Map<String, dynamic>>> getExpenseByCategoryMonthly(
    int year,
    int month,
  ) async {
    final db = await database;

    final monthString = month.toString().padLeft(2, '0');

    return await db.rawQuery(
      '''
    SELECT
      category,
      SUM(amount) as total
    FROM transactions
    WHERE type = 'expense'
      AND strftime('%Y', date) = ?
      AND strftime('%m', date) = ?
    GROUP BY category
  ''',
      [year.toString(), monthString],
    );
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return await db.query('transactions', orderBy: 'date DESC');
  }

  static Future<Map<String, double>> getFinancialSummary() async {
    final db = await database;

    final incomeResult = await db.rawQuery('''
    SELECT COALESCE(SUM(amount), 0) as total
    FROM transactions
    WHERE type = 'income'
  ''');

    final expenseResult = await db.rawQuery('''
    SELECT COALESCE(SUM(amount), 0) as total
    FROM transactions
    WHERE type = 'expense'
  ''');

    final totalIncome = (incomeResult.first['total'] as num).toDouble();

    final totalExpense = (expenseResult.first['total'] as num).toDouble();

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // =========================================================================
  // METODE TAMBAHAN UNTUK SETTINGS (EDIT & RESET)
  // =========================================================================

  /// Memperbarui data profil pengguna secara dinamis berdasarkan map key-value.
  /// Digunakan oleh fitur Edit Username, Pemasukan, dan Tanggal Pemasukan.
  static Future<int> updateUser(Map<String, dynamic> data) async {
    final db = await database;

    // Jika ada pembaruan pada income_date (berupa angka hari int 1-31),
    // kita konversi ke format ISO8601String agar konsisten dengan insertUser.
    if (data.containsKey('income_date') && data['income_date'] is int) {
      final now = DateTime.now();
      final day = data['income_date'] as int;
      // Membuat DateTime dengan tanggal yang dipilih di bulan & tahun saat ini
      final targetDate = DateTime(now.year, now.month, day);
      data['income_date'] = targetDate.toIso8601String();
    }

    // Mengupdate baris pertama pada tabel user_profile
    return await db.update(
      'user_profile',
      data,
      where: 'id = (SELECT id FROM user_profile ORDER BY id DESC LIMIT 1)',
    );
  }

  /// Mengambil data user spesifik beserta ekstraksi angka tanggal gajian.
  /// Menggantikan atau melengkapi fungsi `getUser()` sebelumnya agar menyertakan data tanggal.
  static Future<Map<String, dynamic>?> getUserWithDate() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        username,
        monthly_income,
        avatar,
        income_date
      FROM user_profile
      ORDER BY id DESC
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      final userMap = Map<String, dynamic>.from(result.first);

      // Mengambil substring angka hari dari ISO8601 String (misal: "2026-06-28..." diambil 28)
      if (userMap['income_date'] != null) {
        try {
          final dateTime = DateTime.parse(userMap['income_date'].toString());
          userMap['income_date'] =
              dateTime.day; // Mengubah nilainya menjadi int (1-31)
        } catch (_) {
          userMap['income_date'] = 1; // Default jika gagal parsing
        }
      } else {
        userMap['income_date'] = 1;
      }

      return userMap;
    }
    return null;
  }

  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('user_profile');
  }
  // Mengambil kategori unik untuk Pemasukan
  static Future<List<Map<String, dynamic>>> getIncomeCategories() async {
    final db = await database;
    return await db.query('income_source', orderBy: 'code ASC');
  }

  static Future<int> insertIncomeCategories(String code) async {
    final db = await database;
    return await db.insert('income_source', {'code': code});
  }

  static Future<int> updateIncomeSource(int id, String newCode) async {
    final db = await database;
    return await db.update(
      'income_source',
      {'code': newCode},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteIncomeSource(int id) async {
    final db = await database;
    return await db.delete('income_source', where: 'id = ?', whereArgs: [id]);
  }

  // Mengambil kategori unik untuk Pengeluaran
  static Future<List<String>> getExpenseCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT category FROM transactions WHERE type = 'expense' ORDER BY category ASC
    ''');
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }
}
