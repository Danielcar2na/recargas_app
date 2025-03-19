import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/recharge_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recargas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, 
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recharges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        phoneNumber TEXT NOT NULL,
        provider TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
  }


  Future<int> registerUser(String username, String password) async {
    final db = await database;
    try {
      return await db.insert('users', {'username': username, 'password': password});
    } catch (e) {
      return -1; 
    }
  }


  Future<Map<String, dynamic>?> authenticateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }


  Future<int> insertRecharge(Recharge recharge, int userId) async {
    final db = await database;
    return await db.insert('recharges', {
      'user_id': userId,
      'phoneNumber': recharge.phoneNumber,
      'provider': recharge.provider,
      'amount': recharge.amount,
      'date': recharge.date,
    });
  }

  Future<List<Recharge>> getRechargesByUser(int userId) async {
    final db = await database;
    final result = await db.query(
      'recharges',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((json) => Recharge.fromJson(json)).toList();
  }

Future<int> deleteRecharge(int rechargeId) async {
  final db = await database;
  return await db.delete('recharges', where: 'id = ?', whereArgs: [rechargeId]);
}


Future<int> updateRecharge(Recharge recharge) async {
  final db = await database;
  return await db.update(
    'recharges',
    recharge.toJson(),
    where: 'id = ?',
    whereArgs: [recharge.id],
  );
}

}
