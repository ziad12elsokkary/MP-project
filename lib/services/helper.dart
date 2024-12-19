import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseHelper {
  static final LocalDatabaseHelper _instance = LocalDatabaseHelper._internal();
  factory LocalDatabaseHelper() => _instance;

  LocalDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_users.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(uid TEXT PRIMARY KEY, name TEXT, email TEXT, phone TEXT, profilePictureUrl TEXT)',
        );
      },
    );
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    if (user['uid'] == null || user['uid'].isEmpty) {
      throw Exception("User UID cannot be null or empty.");
    }
    final db = await database;
    print("Inserting user into local DB: $user");
    await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<void> updateUser(String uid, Map<String, dynamic> user) async {
    if (uid.isEmpty) {
      throw Exception("Cannot update user without UID.");
    }
    final db = await database;
    await db.update(
      'users',
      user,
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
