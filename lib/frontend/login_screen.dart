import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/backend/database.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/test.dart';
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
              height: global.SizeConfig.screenHeight * 0.48,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                      'Select User...',
                      style: TextStyle(
                        fontFamily: 'Ethnocentric',
                        color: CupertinoColors.systemGrey,
                        fontSize: global.SizeConfig.screenHeight * 0.03,
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
                        // Test(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Pika(),
                        SizedBox(width: global.SizeConfig.screenWidth * 0.1),
                        // Panda(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          CheckButton(),
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
  String fetchadminaccess = '12345';
  TextEditingController inputadminaccess = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      pressedOpacity: 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Image.asset(
              'assets/images/avatar/Ayushprtp.png',
              height: global.SizeConfig.screenHeight * 0.1,
              fit: BoxFit.cover,
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avatar/Ayushprtp.png'),
              ),
              color: CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              fontFamily: 'Blanka',
              color: CupertinoColors.white,
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
              title: Text('Access Code'),
              content: CupertinoTextField(
                autocorrect: false,
                // suffix: HugeIcon(
                //   icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                //   color: Colors.black,
                //   size: 24.0,
                // ),
                placeholder: "Enter Access Code",
                decoration: BoxDecoration(
                  // color: CupertinoColors.activeGreen,
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ), // Customize the border
                  borderRadius: BorderRadius.circular(
                    25,
                  ), // Customize the border radius
                ),
                controller: inputadminaccess,
                obscureText: true,
                maxLines: 1,
              ),
              actions: [
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancelCircle,
                    color: CupertinoColors.destructiveRed,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(context);
                  },
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                    color: CupertinoColors.systemBlue,
                    // size: 24.0,
                  ),
                  onPressed: () {
                    if (inputadminaccess.text == fetchadminaccess.toString()) {
                      // ScaffoldMessenger.of(
                      // context,
                      // ).showSnackBar(const SnackBar(content: Text('Authorized..!!')));
                      Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(builder: (context) => HomeScreen()),
                      );
                    } else if (inputadminaccess.text !=
                        fetchadminaccess.toString()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Incorrect Access Code..!!'),
                        ),
                      );
                    } else
                      () {};
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
