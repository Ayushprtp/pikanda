import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/frontend/quotes.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/test.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: null,
      middle: Text(
        'Home..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedAccountSetting03,
        color: CupertinoColors.systemGrey,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TestButton(),
          CheckButton(),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: Dev()),
        ],
      ),
    );
  }
}


class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: null,
        middle: Text(
        'ADMIN Home..!!',
        style: TextStyle(
        fontFamily: 'Ethnocentric',
        fontSize: global.SizeConfig.screenHeight * 0.025,
        color: CupertinoColors.white,
    ),
    ),
    trailing: HugeIcon(
    icon: HugeIcons.strokeRoundedAccountSetting03,
    color: CupertinoColors.systemGrey,
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flexible(child: MorphedContainer(child: Text('Recnt Quotes List View'))),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Flexible(child: MorphedContainer(child: Text('Recnt Quotes Having Reponse List View'))),
      ),

    Row(
      children: [
        CupertinoButton.filled(child: Row(children: [Text('Users'),HugeIcon(
          icon: HugeIcons.strokeRoundedPencilEdit02,
          color: CupertinoColors.systemPurple,
        )],), onPressed: (){}),
      ],
    ),
    Spacer(),
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
    child: CupertinoButton.tinted(
      color: CupertinoColors.white,
    child: HugeIcon(
    icon: HugeIcons.strokeRoundedAdd02,
    color: CupertinoColors.black
      ,
    ),
    // disabledColor: CupertinoColors.activeBlue,
    // focusColor: CupertinoColors.activeGreen,
    onPressed:
        () => Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (context) => QuoteInsertScreen())),
      ),)),),
    Align(alignment: Alignment.bottomCenter, child: Dev()),
    ],));
  }
}





















class QRscan extends StatelessWidget {
  const QRscan({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [ MorphedContainer(
          width: double.maxFinite,
          height: global.SizeConfig.screenHeight*0.08,
          child:
          Center(child: Container(
          height: global.SizeConfig.screenHeight*0.1,width: global.SizeConfig.screenHeight*0.1,decoration: BoxDecoration(shape: BoxShape.circle,color: CupertinoColors.black),child: HugeIcon(icon: HugeIcons.strokeRoundedQrCode, color: CupertinoColors.lightBackgroundGray,size: global.SizeConfig.screenHeight*0.06,))),

        ),]
      ),
    );
  }
}



