import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/test.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: HugeIcon(
        icon: HugeIcons.strokeRoundedRefresh,
        color: CupertinoColors.activeBlue,
      ),
      middle: Text(
        'Home..!!',
        style: TextStyle(
          fontFamily: 'Blanka',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: HugeIcon(
        icon: HugeIcons.strokeRoundedRefresh,
        color: CupertinoColors.activeBlue,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('####'),
          Text('####'),
          TestButton(),
          Text('####'),
          Text('####'),
          CheckButton(),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: Dev()),
        ],
      ),
    );
  }
}
