import 'dart:io';
import 'package:my_album/model/database/media.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static const dbName = 'my_album.db';
  static Database? _db;
  static Future<Database> db() async {
    if (_db != null) {
      return _db!;
    }

    final database = openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        return db.execute("""CREATE TABLE media(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          path TEXT,
          name TEXT,
          type TEXT,
          previewImageUrl TEXT,
          originalContentUrl TEXT)""");
      },
      version: 1,
    );
    _db = await database;
    return database;
  }

  static Future<void> dropTables() async {
    for (var t in tables) {
      _db?.execute('DROP TABLE IF EXISTS $t');
      print('drop $t');
    }
    _db?.close();
    _db = null;
    await File(join(await getDatabasesPath(), dbName)).delete();
    db();
  }

  // Tables
  static const TableMedia = 'media';
  static const tables = [TableMedia];

  // Media
  static Future<void> insertMedia(Media media) async {
    await _db!.insert(
      TableMedia,
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
