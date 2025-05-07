import 'package:flutter_svg/flutter_svg.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/frontend/quote_widget.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:hugeicons/hugeicons.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: CupertinoNavigationBarBackButton(previousPageTitle: 'Home'),
      middle: Text(
        'Quotesss..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedEthereumRectangle,
        color: CupertinoColors.systemGrey,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Spacer(),
          MorphedContainer(
            height: 300,
            width: double.maxFinite,
            child: Text('data'),
          ),
          Align(alignment: Alignment.center, child: QuoteWidget()),
          Spacer(),
          Dev(),
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