import 'package:recargas_app/models/recharge_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

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
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE recargas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phoneNumber TEXT NOT NULL,
        provider TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertRecharge(Recharge recharge) async {
    final db = await database;
    return await db.insert('recargas', recharge.toMap());
  }

  Future<List<Recharge>> getAllRecharges() async {
    final db = await database;
    final result = await db.query('recargas', orderBy: 'date DESC');
    return result.map((map) => Recharge.fromMap(map)).toList();
  }

  Future<void> deleteAllRecharges() async {
    final db = await database;
    await db.delete('recargas');
  }

  Future<int> updateRecharge(Recharge recharge) async {
    final db = await database;
    return await db.update(
      'recargas',
      recharge.toMap(),
      where: 'id = ?',
      whereArgs: [recharge.id],
    );
  }

  Future<int> deleteRecharge(int id) async {
    final db = await database;
    return await db.delete(
      'recargas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
