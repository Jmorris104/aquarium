import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aquarium_settings.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE settings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      fish_count INTEGER NOT NULL,
      fish_speed REAL NOT NULL,
      fish_color TEXT NOT NULL
    )
    ''');
  }

  Future<void> saveSettings(int fishCount, double fishSpeed, String fishColor) async {
    final db = await instance.database;
    await db.insert(
      'settings',
      {'fish_count': fishCount, 'fish_speed': fishSpeed, 'fish_color': fishColor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await instance.database;
    final maps = await db.query('settings');

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
