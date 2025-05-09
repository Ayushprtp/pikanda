import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      leading: GestureDetector(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedCancelCircle,
          color: CupertinoColors.destructiveRed,
        ),
        onTap: () {
          if (Platform.isAndroid) {
            SystemNavigator.pop(); // For Android, returns to home screen
          } else if (Platform.isIOS) {
            exit(0); // For iOS, exits the app
          }
        },
      ),
      middle: Text(
        'Access..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      child: Column(
        children: [
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: MorphedContainer(
              height: global.SizeConfig.screenHeight * 0.5,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Select User Type...',
                      style: TextStyle(
                        color: CupertinoColors.systemRed,
                        fontSize: global.SizeConfig.screenHeight * 0.04,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Admin(),
                        SizedBox(width: global.SizeConfig.screenWidth * 0.05),
                        Test(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Pika(),
                        SizedBox(width: global.SizeConfig.screenWidth * 0.1),
                        Panda(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Align(alignment: Alignment.bottomCenter, child: Dev()),
        ],
      ),
    );
  }
}

class Admin extends StatefulWidget {
  Admin({Key? key}) : super(key: key);

  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: CupertinoColors.white,
            maxRadius: global.SizeConfig.screenHeight * 0.05,
            minRadius: global.SizeConfig.screenHeight * 0.04,
            foregroundImage: AssetImage('assets/images/avatar/Ayushprtp.png'),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              fontFamily: 'Blanka',
              color: CupertinoColors.black,
              fontSize: global.SizeConfig.screenHeight * 0.03,
            ),
          ),
        ],
      ),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Alert Dialog'),
              content: Text('This is a Cupertino Alert Dialog.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Pika extends StatefulWidget {
  Pika({Key? key}) : super(key: key);

  @override
  _PikaState createState() => _PikaState();
}

class _PikaState extends State<Pika> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: CupertinoColors.white,
            maxRadius: global.SizeConfig.screenHeight * 0.05,
            minRadius: global.SizeConfig.screenHeight * 0.04,
            foregroundImage: AssetImage('assets/images/avatar/Pika.png'),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              fontFamily: 'Blanka',
              color: CupertinoColors.black,
              fontSize: global.SizeConfig.screenHeight * 0.03,
            ),
          ),
        ],
      ),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Alert Dialog'),
              content: Text('This is a Cupertino Alert Dialog.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Panda extends StatefulWidget {
  Panda({Key? key}) : super(key: key);

  @override
  _PandaState createState() => _PandaState();
}

class _PandaState extends State<Panda> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: CupertinoColors.white,
            maxRadius: global.SizeConfig.screenHeight * 0.05,
            minRadius: global.SizeConfig.screenHeight * 0.04,
            foregroundImage: AssetImage('assets/images/avatar/Panda.png'),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              fontFamily: 'Blanka',
              color: CupertinoColors.black,
              fontSize: global.SizeConfig.screenHeight * 0.03,
            ),
          ),
        ],
      ),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Alert Dialog'),
              content: Text('This is a Cupertino Alert Dialog.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: CupertinoColors.white,
            maxRadius: global.SizeConfig.screenHeight * 0.05,
            minRadius: global.SizeConfig.screenHeight * 0.04,
            foregroundImage: AssetImage('assets/images/avatar/Test.png'),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              fontFamily: 'Blanka',
              color: CupertinoColors.black,
              fontSize: global.SizeConfig.screenHeight * 0.03,
            ),
          ),
        ],
      ),
      onPressed: () {
        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text('Alert Dialog'),
              content: Text('This is a Cupertino Alert Dialog.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
