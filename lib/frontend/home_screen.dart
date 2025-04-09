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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Hello..!!',
            style: TextStyle(fontFamily: 'Blanka', fontSize: 45),
          ),
          Text(
            'Hello..!!',
            style: TextStyle(fontFamily: 'Jasmine', fontSize: 45),
          ),
          Text(
            'Hello..!!',
            style: TextStyle(fontFamily: 'Ethnocentric', fontSize: 45),
          ),
          Text('Hello..!!', style: TextStyle(fontFamily: 'SF', fontSize: 45)),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: SongWidget()),
        ],
      ),
    );
  }
}
