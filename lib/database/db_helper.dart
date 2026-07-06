import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:jinahku/services/home_widget_service.dart';

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
      version: 5,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: (db, version) async {
        await _createDB(db);
        await _createTransactionTable(db);
        await _createGoalTable(db);
        await _createGoalTransactionTable(db);
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

          await _backfillDefaultCategoryIcons(db);
        }

        if (oldVersion < 4) {
          await _createGoalTable(db);
        }

        if (oldVersion < 4) {
          await _createGoalTransactionTable(db);
        }

        if (oldVersion < 5) {
          await db.execute("ALTER TABLE goals ADD COLUMN last_reminder TEXT");
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

  static const Map<String, String> _defaultIncomeIcons = {
    'salary': 'work',
    'allowance': 'wallet',
    'freelance': 'laptop',
    'business': 'store',
    'other': 'category',
  };

  static const Map<String, String> _defaultExpenseIcons = {
    'food': 'restaurant',
    'transport': 'car',
    'shopping': 'shopping_bag',
    'bills': 'receipt',
    'entertainment': 'movie',
    'other': 'category',
  };

  static Future<void> _backfillDefaultCategoryIcons(Database db) async {
    for (final entry in _defaultIncomeIcons.entries) {
      await db.update(
        'category',
        {'icon': entry.value},
        where: 'type=? AND code=?',
        whereArgs: ['income', entry.key],
      );
    }

    for (final entry in _defaultExpenseIcons.entries) {
      await db.update(
        'category',
        {'icon': entry.value},
        where: 'type=? AND code=?',
        whereArgs: ['expense', entry.key],
      );
    }
  }

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

  static Future<void> _createGoalTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS goals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_name TEXT NOT NULL,
      target_amount REAL NOT NULL,
      saved_amount REAL DEFAULT 0,
      target_date TEXT NOT NULL,
      note TEXT,
      image_path TEXT,
      reminder INTEGER DEFAULT 0,
      last_reminder TEXT,
      status TEXT DEFAULT 'active'
    )
  ''');
  }

  static Future<void> _createGoalTransactionTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS goal_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      note TEXT,
      date TEXT NOT NULL,
      FOREIGN KEY(goal_id) REFERENCES goals(id) ON DELETE CASCADE
    )
  ''');
  }

  static Future<List<Map<String, dynamic>>> getIncomeSource() async {
    final db = await database;

    return await db.query(
      'category',
      where: 'type = ?',
      whereArgs: ['income'],
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

    final summary = await getFinancialSummary();
    await HomeWidgetService.updateBalanceWidget(summary['balance'] ?? 0);

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

  static Future<void> syncGoalWithBalance() async {
    final db = await database;

    final summary = await getFinancialSummary();
    final balance = summary['balance']!;

    final goal = await getActiveGoal();

    if (goal == null) return;

    final saved = (goal['saved_amount'] as num).toDouble();

    if (balance >= saved) return;

    final newSaved = balance < 0 ? 0.0 : balance;

    await db.update(
      'goals',
      {'saved_amount': newSaved, 'status': 'active'},
      where: 'id = ?',
      whereArgs: [goal['id']],
    );
  }

  // GOALS METHODS
  static Future<int> insertGoal({
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
    String? note,
    String? imagePath,
    required bool reminder,
  }) async {
    final db = await database;

    return await db.insert('goals', {
      'goal_name': goalName,
      'target_amount': targetAmount,
      'saved_amount': 0,
      'target_date': targetDate.toIso8601String(),
      'note': note,
      'image_path': imagePath,
      'reminder': reminder ? 1 : 0,
      'last_reminder': null,
      'status': 'active',
    });
  }

  static Future<int> updateGoal({
    required int id,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
    String? note,
    String? imagePath,
    required bool reminder,
  }) async {
    final db = await database;

    return await db.update(
      'goals',
      {
        'goal_name': goalName,
        'target_amount': targetAmount,
        'target_date': targetDate.toIso8601String(),
        'note': note,
        'image_path': imagePath,
        'reminder': reminder ? 1 : 0,

        'last_reminder': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<bool> addMoneyToGoal({
    required int goalId,
    required double amount,
    String? note,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      final result = await txn.query(
        'goals',
        where: 'id = ?',
        whereArgs: [goalId],
      );

      final goal = result.first;

      final saved = (goal['saved_amount'] as num).toDouble();
      final target = (goal['target_amount'] as num).toDouble();

      final remaining = target - saved;

      final actualAmount = amount > remaining ? remaining : amount;

      await txn.insert('transactions', {
        'type': 'income',
        'amount': actualAmount,
        'category_code': 'other',
        'date': DateTime.now().toIso8601String(),
        'note': note ?? 'Tambah dana Goals',
      });

      final newSaved = saved + actualAmount;

      await txn.update(
        'goals',
        {
          'saved_amount': newSaved,
          'status': newSaved >= target ? 'completed' : 'active',
        },
        where: 'id = ?',
        whereArgs: [goalId],
      );

      await txn.insert('goal_transactions', {
        'goal_id': goalId,
        'amount': actualAmount,
        'note': note,
        'date': DateTime.now().toIso8601String(),
      });
    });

    final summary = await getFinancialSummary();
    await HomeWidgetService.updateBalanceWidget(summary['balance'] ?? 0);

    return true;
  }

  static Future<Map<String, dynamic>?> getGoalById(int id) async {
    final db = await database;

    final result = await db.query('goals', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  static Future<int> deleteGoal(int id) async {
    final db = await database;

    return await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<Map<String, dynamic>?> getLatestGoal() async {
    final db = await database;

    final result = await db.query('goals', orderBy: 'id DESC', limit: 1);

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> getReminderGoals() async {
    final db = await database;

    return await db.query(
      'goals',
      where: 'status = ? AND reminder = ?',
      whereArgs: ['active', 1],
    );
  }

  static Future<void> updateLastReminder(
    int goalId,
    String reminderType,
  ) async {
    final db = await database;

    await db.update(
      'goals',
      {'last_reminder': reminderType},
      where: 'id = ?',
      whereArgs: [goalId],
    );
  }

  static Future<Map<String, dynamic>?> getActiveGoal() async {
    final db = await database;

    final result = await db.query(
      'goals',
      where: 'status = ?',
      whereArgs: ['active'],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;

    return result.first;
  }

  static Future<List<Map<String, dynamic>>> getGoalTransactions(
    int goalId,
  ) async {
    final db = await database;

    return await db.query(
      'goal_transactions',
      where: 'goal_id = ?',
      whereArgs: [goalId],
      orderBy: 'date DESC',
    );
  }

  // ==========================================================================
  // CATEGORY CRUD
  // ==========================================================================
  static Future<List<Map<String, dynamic>>> getIncomeCategoriesFromTable() =>
      getIncomeCategories();

  static Future<List<Map<String, dynamic>>> getExpenseCategoriesFromTable() =>
      getExpenseCategories();

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
    await db.delete('goal_transactions');
    await db.delete('goals');
    await db.delete('transactions');
    await db.delete('user_profile');

    await HomeWidgetService.updateBalanceWidget(0);
  }
}