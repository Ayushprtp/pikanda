import 'package:Pikanda/utilities/bg.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:Pikanda/frontend/quote_widget.dart';
import 'package:Pikanda/frontend/song_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Pikanda/test.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.activeGreen,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text('####'), Text('####'), Text('####'), Text('####')],
          ),
        ),
      ),
    );
  }
}

// homescreen will be deisged using super cupertinonaviagation baar
