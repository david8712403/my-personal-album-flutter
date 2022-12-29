import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_album/model/database/media.dart';
import 'package:my_album/service/auto_media.dart';
import 'package:my_album/service/db.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(100, (index) {
          return Center(
            child: Text(
              'Item $index',
              style: Theme.of(context).textTheme.headline5,
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => {
          Clipboard.getData(Clipboard.kTextPlain).then((value) async {
            print(value?.text);
            if (value == null || value.text == null) return;
            final messages =
                await AutoMediaService.getMediaMessage(value.text!);
            for (final m in messages) {
              print(m.toString());
              Db.insertMedia(Media(
                  path: "",
                  name: "",
                  type: m.type,
                  previewImageUrl: m.previewImageUrl,
                  originalContentUrl: m.originalContentUrl));
            }
          })
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
