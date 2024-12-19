import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Users (
        ID TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        phone TEXT,
        imageurl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Events (
        ID TEXT PRIMARY KEY,
        name TEXT,
        date TEXT,
        userID TEXT,
        FOREIGN KEY (userID) REFERENCES Users(ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        ID TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        eventID TEXT,
        FOREIGN KEY (eventID) REFERENCES Events(ID)
      )
    ''');

    await db.execute('''
      CREATE TABLE Friends (
        userID TEXT,
        friendID TEXT,
        PRIMARY KEY (userID, friendID),
        FOREIGN KEY (userID) REFERENCES Users(ID),
        FOREIGN KEY (friendID) REFERENCES Users(ID)
      )
    ''');
  }
}
