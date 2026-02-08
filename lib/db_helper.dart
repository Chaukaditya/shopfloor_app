import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'shopfloor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            line TEXT,
            document TEXT,
            value TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertEntry(
      String line, String document, String value) async {
    final db = await database;
    await db.insert(
      'entries',
      {
        'line': line,
        'document': document,
        'value': value,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }
}
