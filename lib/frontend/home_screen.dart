import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/customwidgets.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/frontend/quotes.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/frontend/version_screen.dart';
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
    return BgMaterial(
      leading: null,
      middle: Text(
        'Home..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: LogoutButton(),
        bottomWidget: QRscan(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(global.Global.currentUser!.username.toString()),
          Text(global.Global.currentUser!.role.toString()),
          Text(
            'Hello, ${global.Global.currentUser?.username ?? 'Guest'}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
          if (global.Global.currentUser?.role !=
              null) // Display role if available
            Text(
              'Your Role: ${global.Global.currentUser!.role}',
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.systemGrey,
              ),
            ),
          TestButton(),
          CheckButton(),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: Ver()),
        ],
      )
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
      // leading: CupertinoNavigationBarBackButton(),
      middle: Text(
        'ADMIN Home..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: LogoutButton(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MorphedContainer(child: Text('Recnt Quotes List View')),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MorphedContainer(
              child: Text('Recnt Quotes Having Reponse List View'),
            ),
          ),

          Row(
            children: [
              CupertinoButton.filled(
                child: Row(
                  children: [
                    Text('Users'),
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedPencilEdit02,
                      color: CupertinoColors.systemPurple,
                    ),
                  ],
                ),
                onPressed: () {},
              ),
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
                    color: CupertinoColors.black,
                  ),
                  // disabledColor: CupertinoColors.activeBlue,
                  // focusColor: CupertinoColors.activeGreen,
                  onPressed: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => QuoteInsertScreen(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: Ver()),
        ],
      ),
    );
  }
}

class TestHomeScreen extends StatefulWidget {
  const TestHomeScreen({super.key});

  @override
  State<TestHomeScreen> createState() => _TestHomeScreenState();
}

class _TestHomeScreenState extends State<TestHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      trailing: LogoutButton(),
      child: Column(
        children: [
          MorphedContainer(
            child: Center(
              child: Text(
                'Testing Closed..Wait Untill We Start Testing For Next Major Feature',
                style: TextStyle(color: CupertinoColors.destructiveRed),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PikandaHomeScreen extends StatefulWidget {
  const PikandaHomeScreen({super.key});

  @override
  State<PikandaHomeScreen> createState() => _PikandaHomeScreenState();
}

class _PikandaHomeScreenState extends State<PikandaHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BgMaterial(
      leading: null,
      middle: Text(
        'Home..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: LogoutButton(),
      bottomWidget: QRscan(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TestButton(),
          CheckButton(),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: global.SizeConfig.screenHeight*0.03),
            child: Align(alignment: Alignment.bottomCenter, child: Ver()),
          ),
        ],
      )
    );
  }
}

class QRscan extends StatefulWidget {
  const QRscan({super.key});

  @override
  State<QRscan> createState() => _QRscanState();
}

class _QRscanState extends State<QRscan> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: 0,
      animationDuration: Duration(milliseconds: 250),
      height: global.SizeConfig.screenHeight * 0.06,
      buttonBackgroundColor: CupertinoColors.systemPink,
      backgroundColor: CupertinoColors.transparent,
      onTap: (index)
      {print(index);},
      color: CupertinoColors.black,
      items: [
        GestureDetector(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedQrCode,
            color: CupertinoColors.black,
            size: global.SizeConfig.screenHeight * 0.05,
          ),
          onTap: (){print('Hello');},
        ),
      ],
    );
  }
}
