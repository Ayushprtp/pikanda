import 'package:Pikanda/frontend/devinfo_screen.dart';
import 'package:Pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:Pikanda/frontend/quote_widget.dart';
import 'package:Pikanda/frontend/song_widget.dart';
import 'package:flutter/material.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: CupertinoNavigationBarBackButton(onPressed: () {}),
      middle: Text(
        'Quotessss..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: 25,
          color: CupertinoColors.white,
        ),
      ),
      trailing: IconButton(
        iconSize: global.SizeConfig.screenHeight / 24,
        onPressed: () {},
        icon: const Icon(CupertinoIcons.person_solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Spacer(),
          Align(alignment: Alignment.center, child: QuoteWidget()),
          Dev(),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: SongWidget()),
        ],
      ),
    );
  }
}




//it will show 
    // -Quotesflipcard
    // -song plays
    // -reply leave your feeling 
    // - love ur unoved the quote