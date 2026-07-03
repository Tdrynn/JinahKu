import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // INIT
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

  //=========================================================================================================
  // CREATE ALL TABLE
  static Future<void> _createDB(Database db, int version) async {
    // Karena user_profile membutuhkan tabel income_source yang tidak dibuat di sini,
    // Kita buat dummy/table income_source terlebih dahulu agar FOREIGN KEY tidak error.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS income_source (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL
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
        FOREIGN KEY (income_source_id) REFERENCES income_source(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        code TEXT NOT NULL,
        UNIQUE(type, code)
      )
    ''');

    // Default Values untuk Income
    await db.insert('category', {'type': 'income', 'code': 'salary'});
    await db.insert('category', {'type': 'income', 'code': 'allowance'});
    await db.insert('category', {'type': 'income', 'code': 'freelance'});
    await db.insert('category', {'type': 'income', 'code': 'business'});
    await db.insert('category', {'type': 'income', 'code': 'other'});

    // Default Values untuk Expense
    await db.insert('category', {'type': 'expense', 'code': 'food'});
    await db.insert('category', {'type': 'expense', 'code': 'transport'});
    await db.insert('category', {'type': 'expense', 'code': 'bills'});
    await db.insert('category', {'type': 'expense', 'code': 'entertainment'});
    await db.insert('category', {'type': 'expense', 'code': 'other'});
  }

  static Future<void> _createTransactionTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      category_code TEXT NOT NULL,
      date TEXT NOT NULL,
      note TEXT,
      
      FOREIGN KEY (type, category_code) 
      REFERENCES category (type, code)
      ON DELETE RESTRICT ON UPDATE CASCADE
    )
  ''');
  }

  //=========================================================================================================

  // MENGAMBIL KATEGORI DARI DATABASE
  static Future<List<Map<String, dynamic>>> getCategories(String type) async {
    final db = await database;
    return await db.query('category', where: 'type = ?', whereArgs: [type]);
  }

  static Future<List<Map<String, dynamic>>> getIncomeCategories() async {
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

  // TRANSACTION METHODS (DIPERBAIKI: Kolom menggunakan category_code)
  static Future<int> insertTransaction({
    required String type,
    required double amount,
    required String categoryCode,
    required DateTime date,
    String? note,
  }) async {
    final db = await database;

    return await db.insert('transactions', {
      'type': type,
      'amount': amount,
      'category_code':
          categoryCode, // Menggunakan key category_code sesuai struktur tabel
      'date': date.toIso8601String(),
      'note': note,
    });
  }

  // DIPERBAIKI: Mengubah kolom query 'category' menjadi 'category_code'
  static Future<List<Map<String, dynamic>>> getExpenseByCategoryMonthly(
    int year,
    int month,
  ) async {
    final db = await database;
    final monthString = month.toString().padLeft(2, '0');

    return await db.rawQuery(
      '''
    SELECT
      category_code as category,
      SUM(amount) as total
    FROM transactions
    WHERE type = 'expense'
      AND strftime('%Y', date) = ?
      AND strftime('%m', date) = ?
    GROUP BY category_code
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

  static Future<int> updateUser(Map<String, dynamic> data) async {
    final db = await database;

    if (data.containsKey('income_date') && data['income_date'] is int) {
      final now = DateTime.now();
      final day = data['income_date'] as int;
      final targetDate = DateTime(now.year, now.month, day);
      data['income_date'] = targetDate.toIso8601String();
    }

    return await db.update(
      'user_profile',
      data,
      where: 'id = (SELECT id FROM user_profile ORDER BY id DESC LIMIT 1)',
    );
  }

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

      if (userMap['income_date'] != null) {
        try {
          final dateTime = DateTime.parse(userMap['income_date'].toString());
          userMap['income_date'] = dateTime.day;
        } catch (_) {
          userMap['income_date'] = 1;
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

  // Mengambil kategori unik untuk Pemasukan dari income_source
  static Future<List<Map<String, dynamic>>>
  getIncomeCategoriesFromTable() async {
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

  // DIPERBAIKI: Mengubah pencarian distrik kategori 'category' menjadi 'category_code'
  static Future<List<String>> getDistinctExpenseCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT category_code FROM transactions WHERE type = 'expense' ORDER BY category_code ASC
    ''');
    return List.generate(
      maps.length,
      (i) => maps[i]['category_code'] as String,
    );
  }
}
