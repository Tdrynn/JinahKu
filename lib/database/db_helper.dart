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
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },

      onCreate: _createDB,

      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
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

    return await db.insert(
      'user_profile',
      {
        'username': username,
        'monthly_income': monthlyIncome,
        'income_date': incomeDate.toIso8601String(),
        'avatar': avatar,
        'income_source_id': incomeSourceId,
      },
    );
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
        user_profile.monthly_income
      FROM user_profile
      LIMIT 1
    ''');

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}