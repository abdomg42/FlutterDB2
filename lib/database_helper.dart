import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'exams_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_name TEXT
      )
    ''');
  }

  Future<int> insertExam(String name) async {
    Database db = await database;
    return await db.insert('exams', {'exam_name': name});
  }

  Future<List<Map<String, dynamic>>> getExams() async {
    Database db = await database;
    return await db.query('exams');
  }

  Future<int> updateExam(int id, String name) async {
    Database db = await database;
    return await db.update(
      'exams',
      {'exam_name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteExam(int id) async {
    Database db = await database;
    return await db.delete(
      'exams',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
