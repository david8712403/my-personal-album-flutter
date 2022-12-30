import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:my_album/model/database/media.dart';
import 'package:my_album/service/auto_media.dart';
import 'package:my_album/service/db.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  List<Media> _medias = [];
  late bool _showContent;
  late bool _permissionReady;
  late bool _saveInPublicStorage;
  late String _localPath;
  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback, step: 1);

    _showContent = false;
    _permissionReady = false;
    _saveInPublicStorage = false;
    fetchMedias();
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      final taskId = (data as List<dynamic>)[0] as String;
      final status = data[1] as DownloadTaskStatus;
      final progress = data[2] as int;

      // print(
      //   'Callback on UI isolate: '
      //   'task ($taskId) is in status ($status) and process ($progress)',
      // );
      if (status == DownloadTaskStatus.complete) {
        print('task ($taskId) finished!');
        FlutterDownloader.loadTasksWithRawQuery(
                query: "SELECT * FROM task WHERE task_id='$taskId'")
            .then((value) {
          final task = value!.first;
          final path = join(task.savedDir, task.filename);
          print("$taskId=>update local image");
          Db.updateLocalMediaPath(task.taskId, path);
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static Future<void> downloadCallback(
    String id,
    DownloadTaskStatus status,
    int progress,
  ) async {
    IsolateNameServer.lookupPortByName('downloader_send_port')
        ?.send([id, status, progress]);
  }

  Future<void> fetchMedias() async {
    final medias = await Db.medias();
    setState(() {
      _medias = medias;
    });
  }

  Future<void> importMedia(AutoMediaMessageItem m) async {
    final appDocDir = await getApplicationDocumentsDirectory();

    final name = const Uuid().v4();
    final previewPath = join(appDocDir.path, "image");
    final originalPath = join(appDocDir.path, m.type);
    await Directory(previewPath).create(recursive: true);
    await Directory(originalPath).create(recursive: true);

    final previewTask = await FlutterDownloader.enqueue(
        url: m.previewImageUrl, savedDir: previewPath);
    final originalTask = await FlutterDownloader.enqueue(
        url: m.originalContentUrl, savedDir: originalPath);

    await Db.insertMedia(
      Media(
        created: DateTime.now().toIso8601String(),
        name: name,
        type: m.type,
        previewTaskId: previewTask!,
        previewImageUrl: m.previewImageUrl,
        originalTaskId: originalTask!,
        originalContentUrl: m.originalContentUrl,
      ),
    );
  }

  Future<void> onUrlPast() async {
    Clipboard.getData(Clipboard.kTextPlain).then((value) async {
      print(value?.text);
      if (value == null || value.text == null) return;
      final messages = await AutoMediaService.getMediaMessage(value.text!);
      // final url =
      //     "https://twitter.com/cat_auras/status/1608543984099680261/photo/1";
      // final messages = await AutoMediaService.getMediaMessage(url);
      for (final m in messages) {
        await importMedia(m);
      }
      fetchMedias();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: _medias.isEmpty
            ? const Center(child: Text("No data"))
            : GridView.count(
                crossAxisCount: 3,
                children: _medias.map((e) {
                  if (e.previewImagePath == null) {
                    return Image.network(e.previewImageUrl, fit: BoxFit.cover);
                  }
                  return Stack(
                    children: [
                      Image.file(File(e.previewImagePath!), fit: BoxFit.cover),
                      const Text("local file",
                          style: TextStyle(color: Colors.white))
                    ],
                  );
                }).toList(),
              ),
        onRefresh: () async => fetchMedias(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => onUrlPast(),
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
      // floatingActionButton:
    );
  }
}
