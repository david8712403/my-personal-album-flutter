import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:my_album/screen/album_screen.dart';
import 'package:my_album/screen/setting_screen.dart';
import 'package:my_album/screen/media_screen.dart';
import 'package:my_album/service/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Db.getInstance();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 25;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [MediaScreen(), AlbumScreen(), SettingScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_album),
            label: 'Album',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
