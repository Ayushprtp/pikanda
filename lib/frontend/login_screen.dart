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

                        CupertinoButton(
                          onPressed: () => _showAlertDialog,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: CupertinoColors.white,
                                maxRadius:
                                    global.SizeConfig.screenHeight * 0.05,
                                minRadius:
                                    global.SizeConfig.screenHeight * 0.04,
                                foregroundImage: AssetImage(
                                  'assets/images/avatar/Test.png',
                                ),
                              ),
                              Text(
                                'Test',
                                style: TextStyle(
                                  fontFamily: 'Blanka',
                                  color: CupertinoColors.black,
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed:
                              () => Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => HomeScreen(),
                                ),
                              ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: CupertinoColors.white,
                                maxRadius:
                                    global.SizeConfig.screenHeight * 0.05,
                                minRadius:
                                    global.SizeConfig.screenHeight * 0.04,
                                foregroundImage: AssetImage(
                                  'assets/images/avatar/Pika.png',
                                ),
                              ),
                              Text(
                                'Pika',
                                style: TextStyle(
                                  fontFamily: 'Blanka',
                                  color: CupertinoColors.black,
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: global.SizeConfig.screenWidth * 0.1),

                        CupertinoButton(
                          onPressed: () {
                            // Suggested code may be subject to a license. Learn more: ~LicenseLog:2531664692.
                            print(
                              Geolocator.getCurrentPosition(
                                locationSettings: LocationSettings(
                                  accuracy: LocationAccuracy.high,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: CupertinoColors.white,
                                maxRadius:
                                    global.SizeConfig.screenHeight * 0.05,
                                minRadius:
                                    global.SizeConfig.screenHeight * 0.04,
                                foregroundImage: AssetImage(
                                  'assets/images/avatar/Panda.png',
                                ),
                              ),
                              Text(
                                'Panda',
                                style: TextStyle(
                                  fontFamily: 'Blanka',
                                  color: CupertinoColors.black,
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.03,
                                ),
                              ),
                            ],
                          ),
                        ),
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
        CupertinoAlertDialog(
          title: Text('Alert Title'),
          content: Text('This is the content of the alert.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

void _showAlertDialog(BuildContext context) {
  showCupertinoDialog<void>(
    context: context,
    builder:
        (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content: const Text('Proceed with destructive action?'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              /// This parameter indicates this action is the default,
              /// and turns the action's text to bold text.
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              /// This parameter indicates the action would perform
              /// a destructive action such as deletion, and turns
              /// the action's text color to red.
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        ),
  );
}
