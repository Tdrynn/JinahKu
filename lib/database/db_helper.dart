import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // ==========================================================================
  // INIT DATABASE
  // ==========================================================================

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jinahku.db');

    return await openDatabase(
      path,
      version: 4,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await _createDB(db);
        await _createTransactionTable(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS transactions');
          await db.execute('DROP TABLE IF EXISTS user_profile');
          await db.execute('DROP TABLE IF EXISTS category');

          await _createDB(db);
          await _createTransactionTable(db);
          return;
        }

        if (oldVersion < 4) {
          await db.execute(
            "ALTER TABLE category ADD COLUMN icon TEXT NOT NULL DEFAULT 'category'",
          );
        }
      },

      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ==========================================================================
  // CREATE TABLES
  // ==========================================================================

  static Future<void> _createDB(Database db) async {
    await db.execute('''
      CREATE TABLE category (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        code TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT 'category',
        UNIQUE(type, code)
      )
    ''');

    // Income Categories
    await db.insert('category', {
      'type': 'income',
      'code': 'salary',
      'icon': 'work',
    });

    await db.insert('category', {
      'type': 'income',
      'code': 'allowance',
      'icon': 'wallet',
    });

    await db.insert('category', {
      'type': 'income',
      'code': 'freelance',
      'icon': 'laptop',
    });

    await db.insert('category', {
      'type': 'income',
      'code': 'business',
      'icon': 'store',
    });

    await db.insert('category', {
      'type': 'income',
      'code': 'other',
      'icon': 'category',
    });

    // Expense Categories
    await db.insert('category', {
      'type': 'expense',
      'code': 'food',
      'icon': 'restaurant',
    });

    await db.insert('category', {
      'type': 'expense',
      'code': 'transport',
      'icon': 'car',
    });

    await db.insert('category', {
      'type': 'expense',
      'code': 'shopping',
      'icon': 'shopping_bag',
    });

    await db.insert('category', {
      'type': 'expense',
      'code': 'bills',
      'icon': 'receipt',
    });

    await db.insert('category', {
      'type': 'expense',
      'code': 'entertainment',
      'icon': 'movie',
    });

    await db.insert('category', {
      'type': 'expense',
      'code': 'other',
      'icon': 'category',
    });

    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        monthly_income REAL NOT NULL,
        income_date TEXT NOT NULL,
        avatar TEXT NOT NULL,

        income_type TEXT NOT NULL DEFAULT 'income',
        income_category_code TEXT NOT NULL,

        FOREIGN KEY (income_type, income_category_code)
        REFERENCES category(type, code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
      )
    ''');
  }

  static Future<void> _createTransactionTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category_code TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,

        FOREIGN KEY (type, category_code)
        REFERENCES category(type, code)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
      )
    ''');
  }

  // ==========================================================================
  // CATEGORY METHODS
  // ==========================================================================

  static Future<List<Map<String, dynamic>>> getCategories(String type) async {
    final db = await database;

    return await db.query(
      'category',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'code ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> getIncomeCategories() async {
    final db = await database;

    return await db.query(
      'category',
      where: 'type = ?',
      whereArgs: ['income'],
      orderBy: 'code ASC',
    );
  }

  static Future<List<Map<String, dynamic>>> getExpenseCategories() async {
    final db = await database;

    return await db.query(
      'category',
      where: 'type = ?',
      whereArgs: ['expense'],
      orderBy: 'code ASC',
    );
  }

  // ==========================================================================
  // USER PROFILE
  // ==========================================================================

  static Future<int> insertUser({
    required String username,
    required double monthlyIncome,
    required DateTime incomeDate,
    required String avatar,
    required String incomeCategoryCode,
  }) async {
    final db = await database;

    return await db.insert('user_profile', {
      'username': username,
      'monthly_income': monthlyIncome,
      'income_date': incomeDate.toIso8601String(),
      'avatar': avatar,
      'income_type': 'income',
      'income_category_code': incomeCategoryCode,
    });
  }

  static Future<bool> isFirstTime() async {
    final db = await database;

    final result = await db.query('user_profile', limit: 1);

    return result.isEmpty;
  }

  static Future<List<Map<String, dynamic>>> getUserProfile() async {
    final db = await database;

    return await db.rawQuery('''
      SELECT
        u.id,
        u.username,
        u.monthly_income,
        u.income_date,
        u.avatar,
        c.code AS income_source

      FROM user_profile u

      JOIN category c
      ON c.type = u.income_type
      AND c.code = u.income_category_code
    ''');
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT
        username,
        monthly_income,
        avatar
      FROM user_profile
      ORDER BY id DESC
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
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

      try {
        final date = DateTime.parse(userMap['income_date'].toString());

        userMap['income_date'] = date.day;
      } catch (_) {
        userMap['income_date'] = 1;
      }

      return userMap;
    }

    return null;
  }
  // ==========================================================================
  // UPDATE USER
  // ==========================================================================

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

  // ==========================================================================
  // TRANSACTION
  // ==========================================================================

  static Future<int> insertTransaction({
    required String type,
    required double amount,
    required String categoryCode,
    required DateTime date,
    String? note,
  }) async {
    final db = await database;

    final id = await db.insert('transactions', {
      'type': type,
      'amount': amount,
      'category_code': categoryCode,
      'date': date.toIso8601String(),
      'note': note,
    });

    print("INSERT ID = $id");

    final result = await db.query('transactions');
    print(result);

    return id;
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    final result = await db.query('transactions');

    print("GET TRANSACTION");
    print(result);

    return result;
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
        category_code AS category,
        SUM(amount) AS total
      FROM transactions
      WHERE type='expense'
      AND strftime('%Y', date)=?
      AND strftime('%m', date)=?
      GROUP BY category_code
    ''',
      [year.toString(), monthString],
    );
  }

  static Future<Map<String, double>> getFinancialSummary() async {
    final db = await database;

    final income = await db.rawQuery('''
      SELECT COALESCE(SUM(amount),0) total
      FROM transactions
      WHERE type='income'
    ''');

    final expense = await db.rawQuery('''
      SELECT COALESCE(SUM(amount),0) total
      FROM transactions
      WHERE type='expense'
    ''');

    final totalIncome = (income.first['total'] as num).toDouble();

    final totalExpense = (expense.first['total'] as num).toDouble();

    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }

  // ==========================================================================
  // CATEGORY CRUD
  // ==========================================================================

  // Alias -- identik dengan getIncomeCategories/getExpenseCategories di atas.
  static Future<List<Map<String, dynamic>>>
  getIncomeCategoriesFromTable() => getIncomeCategories();

  static Future<List<Map<String, dynamic>>>
  getExpenseCategoriesFromTable() => getExpenseCategories();

  static Future<int> insertIncomeCategory(
    String code, {
    String icon = 'category',
  }) async {
    final db = await database;

    try {
      return await db.insert('category', {
        'type': 'income',
        'code': code,
        'icon': icon,
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Kategori "$code" sudah ada.');
      }
      rethrow;
    }
  }

  static Future<int> insertExpenseCategory(
    String code, {
    String icon = 'category',
  }) async {
    final db = await database;

    try {
      return await db.insert('category', {
        'type': 'expense',
        'code': code,
        'icon': icon,
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Kategori "$code" sudah ada.');
      }
      rethrow;
    }
  }

  static Future<int> updateIncomeCategory(
    int id,
    String newCode, {
    String? icon,
  }) async {
    final db = await database;

    final data = <String, dynamic>{'code': newCode};
    if (icon != null) data['icon'] = icon;

    try {
      return await db.update(
        'category',
        data,
        where: 'id=? AND type=?',
        whereArgs: [id, 'income'],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Kategori "$newCode" sudah ada.');
      }
      rethrow;
    }
  }

  static Future<int> updateExpenseCategory(
    int id,
    String newCode, {
    String? icon,
  }) async {
    final db = await database;

    final data = <String, dynamic>{'code': newCode};
    if (icon != null) data['icon'] = icon;

    try {
      return await db.update(
        'category',
        data,
        where: 'id=? AND type=?',
        whereArgs: [id, 'expense'],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception('Kategori "$newCode" sudah ada.');
      }
      rethrow;
    }
  }

  static Future<int> deleteIncomeCategory(int id) async {
    final db = await database;

    try {
      return await db.delete(
        'category',
        where: 'id=? AND type=?',
        whereArgs: [id, 'income'],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception(
          'Kategori ini masih digunakan pada transaksi atau profil, tidak bisa dihapus.',
        );
      }
      rethrow;
    }
  }

  static Future<int> deleteExpenseCategory(int id) async {
    final db = await database;

    try {
      return await db.delete(
        'category',
        where: 'id=? AND type=?',
        whereArgs: [id, 'expense'],
      );
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw Exception(
          'Kategori ini masih digunakan pada transaksi atau profil, tidak bisa dihapus.',
        );
      }
      rethrow;
    }
  }

  // ==========================================================================
  // EXPENSE CATEGORY
  // ==========================================================================

  static Future<List<String>> getDistinctExpenseCategories() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT DISTINCT category_code
      FROM transactions
      WHERE type='expense'
      ORDER BY category_code ASC
    ''');

    return List.generate(
      result.length,
      (i) => result[i]['category_code'] as String,
    );
  }

  // ==========================================================================
  // CLEAR DATA
  // ==========================================================================

  static Future<void> clearAllData() async {
    final db = await database;

    await db.delete('transactions');
    await db.delete('user_profile');
  }
}