import 'package:Pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';
import 'package:super_cupertino_navigation_bar/super_cupertino_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:Pikanda/frontend/quote_widget.dart';
import 'package:Pikanda/frontend/song_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Pikanda/test.dart';
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Test(),
          Spacer(),
          Align(alignment: Alignment.center, child: QuoteWidget()),
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