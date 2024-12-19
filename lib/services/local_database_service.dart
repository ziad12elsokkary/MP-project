import 'package:sqflite/sqflite.dart';
import 'package:hedieaty3/models/local_db.dart';

class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Users Table
  Future<int> insertUser(Map<String, dynamic> user) async {
    if (user['ID'] == null || user['ID'].isEmpty) {
      throw Exception("User ID cannot be null or empty.");
    }
    Database db = await _dbHelper.database;
    return await db.insert(
      'Users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await _dbHelper.database;
    return await db.query('Users');
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    if (user['ID'] == null || user['ID'].isEmpty) {
      throw Exception("Cannot update user without ID.");
    }
    Database db = await _dbHelper.database;
    print("Updating user: ${user['ID']}");
    int result = await db.update(
      'Users',
      user,
      where: 'ID = ?',
      whereArgs: [user['ID']],
    );
    print("Rows updated: $result");
    return result;
  }

  Future<int> deleteUser(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete('Users', where: 'ID = ?', whereArgs: [id]);
  }

  // Events Table
  Future<int> insertEvent(Map<String, dynamic> event) async {
    Database db = await _dbHelper.database;
    return await db.insert(
      'Events',
      event,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    Database db = await _dbHelper.database;
    return await db.query('Events');
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    if (event['ID'] == null || event['ID'].isEmpty) {
      throw Exception("Cannot update event without ID.");
    }
    Database db = await _dbHelper.database;
    return await db.update(
      'Events',
      event,
      where: 'ID = ?',
      whereArgs: [event['ID']],
    );
  }

  Future<int> deleteEvent(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete('Events', where: 'ID = ?', whereArgs: [id]);
  }

  // Gifts Table
  Future<int> insertGift(Map<String, dynamic> gift) async {
    Database db = await _dbHelper.database;
    return await db.insert(
      'Gifts',
      gift,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getGifts() async {
    Database db = await _dbHelper.database;
    return await db.query('Gifts');
  }

  Future<int> updateGift(Map<String, dynamic> gift) async {
    if (gift['ID'] == null || gift['ID'].isEmpty) {
      throw Exception("Cannot update gift without ID.");
    }
    Database db = await _dbHelper.database;
    return await db.update(
      'Gifts',
      gift,
      where: 'ID = ?',
      whereArgs: [gift['ID']],
    );
  }

  Future<int> deleteGift(String id) async {
    Database db = await _dbHelper.database;
    return await db.delete('Gifts', where: 'ID = ?', whereArgs: [id]);
  }

  // Friends Table
  Future<int> insertFriend(Map<String, dynamic> friend) async {
    Database db = await _dbHelper.database;
    return await db.insert(
      'Friends',
      friend,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getFriends() async {
    Database db = await _dbHelper.database;
    return await db.query('Friends');
  }

  Future<int> deleteFriend(String userID, String friendID) async {
    Database db = await _dbHelper.database;
    return await db.delete(
      'Friends',
      where: 'userID = ? AND friendID = ?',
      whereArgs: [userID, friendID],
    );
  }
}
