import 'dart:io';
import 'package:my_album/model/database/media.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Db {
  static const dbName = 'my_album.db';
  static Database? _db;
  static Future<Database> getInstance() async {
    if (_db != null) {
      return _db!;
    }

    final database = await openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) {
        print("init tables");
        return db.execute('CREATE TABLE media('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'created TEXT NOT NULL,'
            'name TEXT,'
            'description TEXT,'
            'type TEXT NOT NULL,'
            'previewImageUrl TEXT NOT NULL,'
            'previewImagePath TEXT,'
            'previewTaskId TEXT NOT NULL,'
            'originalContentUrl TEXT NOT NULL,'
            'originalContentPath TEXT,'
            'originalTaskId TEXT NOT NULL)');
      },
      version: 1,
    );
    _db = database;
    return database;
  }

  static Future<void> dropTables() async {
    for (var t in tables) {
      _db?.execute('DROP TABLE IF EXISTS $t');
      print('drop $t');
    }
    await _db?.close();
    _db = null;
    await File(join(await getDatabasesPath(), dbName)).delete();
    await getInstance();
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

  static Future<List<Media>> medias() async {
    final List<Map<String, dynamic>> maps = await _db!.query(TableMedia);
    return List.generate(maps.length, (i) {
      return Media.fromMap(maps[i]);
    });
  }

  static Future<void> updateLocalMediaPath(String taskId, String path) async {
    await _db!.update(
      TableMedia,
      {"previewImagePath": path},
      where: "previewTaskId = ?",
      whereArgs: [taskId],
    );
    await _db!.update(
      TableMedia,
      {"originalContentPath": path},
      where: "originalTaskId = ?",
      whereArgs: [taskId],
    );
  }
}
