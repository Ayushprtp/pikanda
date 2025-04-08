import 'package:flutter/cupertino.dart';
import 'package:myapp/frontend/song_widget.dart';
import 'package:myapp/utilities/globalvar.dart' as global;

var ht = global.screenHeight;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey,
      child: Align(alignment: Alignment.bottomCenter, child: SongWidget()),
    );
  }
}
