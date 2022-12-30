import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:my_album/model/database/media.dart';
import 'package:my_album/service/auto_media.dart';
import 'package:my_album/service/db.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:uuid/uuid.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  List<Media> _medias = [];
  late bool _showContent;
  late bool _permissionReady;
  late bool _saveInPublicStorage;
  late String _localPath;
  final ReceivePort _port = ReceivePort();
  late Directory _appDocDir;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((value) => _appDocDir = value);

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

      if (status != DownloadTaskStatus.complete) return;

      print('task ($taskId) finished!');
      int retry = 0;
      while (retry < 100) {
        retry++;
        final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query:
                "SELECT * FROM task WHERE task_id='$taskId' ORDER BY time_created DESC");
        if (tasks == null || tasks.isEmpty) {
          // Retry to query task, only happend in iOS(?)
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }

        final task = tasks[0];
        final saveRelativePath = task.savedDir.replaceAll(_appDocDir.path, '');
        final path = join(saveRelativePath, task.filename);
        print("$taskId=>update local path (try $retry times...)");
        Db.updateLocalMediaPath(task.taskId, path).then((value) async {
          final medias = await Db.medias();
          setState(() => _medias = medias);
        });
        _scrollDown();
        return;
      }
      print("$taskId=>update local path FAILED!!!!");
    });
  }

  void _unbindBackgroundIsolate() =>
      IsolateNameServer.removePortNameMapping('downloader_send_port');

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
    setState(() => _medias = medias);
  }

  Future<void> importMedia(AutoMediaMessageItem m) async {
    final name = const Uuid().v4();
    final previewPath = join(_appDocDir.path, "image");
    final originalPath = join(_appDocDir.path, m.type);
    await Directory(previewPath).create(recursive: true);
    await Directory(originalPath).create(recursive: true);

    final previewTask = await FlutterDownloader.enqueue(
      url: m.previewImageUrl,
      savedDir: previewPath,
      showNotification: false,
      openFileFromNotification: false,
      fileName: "$name-preview",
    );
    final originalTask = await FlutterDownloader.enqueue(
      url: m.originalContentUrl,
      savedDir: originalPath,
      showNotification: false,
      openFileFromNotification: false,
      fileName: "$name-original",
    );

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
            : Stack(
                children: [
                  buildGridView(context),
                  Positioned(
                    top: 0,
                    right: 25,
                    child: AnimSearchBar(
                      width: MediaQuery.of(context).size.width - 50,
                      textController: _textController,
                      onSuffixTap: () {
                        setState(() {
                          _textController.clear();
                        });
                      },
                      onSubmitted: (text) {
                        print(text);
                      },
                    ),
                  )
                ],
              ),
        onRefresh: () async => fetchMedias(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => onUrlPast(),
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(microseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  Widget buildGridView(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      controller: _scrollController,
      mainAxisSpacing: 1,
      crossAxisSpacing: 1,
      children: _medias.map((e) {
        if (e.previewImagePath == null) {
          return Container(
            padding: const EdgeInsets.all(8),
            alignment: AlignmentDirectional.bottomEnd,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(e.previewImageUrl),
              fit: BoxFit.cover,
            )),
            child: const LoadingIndicator(
              indicatorType: Indicator.ballBeat,
              colors: [Colors.white],
              strokeWidth: 2.0,
              pathBackgroundColor: Colors.black45,
            ),
          );
        }
        return InkWell(
          onTap: () => showDialog(
            context: context,
            builder: ((context) => Dialog(
                insetPadding: const EdgeInsets.all(0),
                child: PhotoViewGallery.builder(
                  pageController:
                      PageController(initialPage: _medias.indexOf(e)),
                  scrollPhysics: const BouncingScrollPhysics(),
                  builder: (BuildContext context, int index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: AssetImage(
                          '${_appDocDir.path}${_medias[index].previewImagePath!}'),
                      // initialScale: PhotoViewComputedScale.contained * 0.8,
                      heroAttributes:
                          PhotoViewHeroAttributes(tag: _medias[index]),
                    );
                  },
                  itemCount: _medias.length,
                  loadingBuilder: (context, event) => Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        value: event == null
                            ? 0
                            : event.cumulativeBytesLoaded /
                                event.expectedTotalBytes!,
                      ),
                    ),
                  ),
                ))),
          ),
          child: Image.file(
            // 不知道為什麼這裡用join合併路徑沒用...
            File('${_appDocDir.path}${e.previewImagePath!}'),
            fit: BoxFit.cover,
            cacheWidth: 180,
            gaplessPlayback: true,
          ),
        );
      }).toList(),
    );
  }
}
