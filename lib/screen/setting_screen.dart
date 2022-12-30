import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

import '../service/db.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void viewDatabase(BuildContext context) async {
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
            onPressed: () => viewDatabase(context),
            child: const Text("view database"),
          ),
          MaterialButton(
            onPressed: () => showAlertDialog(context),
            child: const Text("🚧 clear database 🚧"),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = MaterialButton(
      child: const Text("OK"),
      onPressed: () async {
        await Db.dropTables();
        final appDocDir = await getApplicationDocumentsDirectory();
        final imagePath = join(appDocDir.path, "image");
        final videoPath = join(appDocDir.path, "video");
        if (await Directory(imagePath).exists()) {
          print("delete $imagePath");
          await Directory(imagePath).delete(recursive: true);
        }
        if (await Directory(videoPath).exists()) {
          print("delete $videoPath");
          await Directory(videoPath).delete(recursive: true);
        }
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Clear database"),
      content: const Text("Will clear all data!!!"),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => alert,
    );
  }
}
