import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../service/db.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void viewDatabase() async {
    final path = await getDatabasesPath();
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => DatabaseList(dbPath: path)));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MaterialButton(
            onPressed: viewDatabase,
            child: const Text("view database"),
          ),
          MaterialButton(
            onPressed: () async => Db.dropTables(),
            child: const Text("🔥clear database"),
          ),
        ],
      ),
    );
  }
}
