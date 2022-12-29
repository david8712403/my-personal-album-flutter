import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        onPressed: () => {
          Clipboard.getData(Clipboard.kTextPlain).then((value) {
            print(value?.text); //value is clipbarod data
          })
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
