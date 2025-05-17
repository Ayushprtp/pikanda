import 'dart:io';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
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

  void _showLoginDailogue() {
    TextEditingController _username = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return

          CupertinoAlertDialog(
          title: Text('Fill Required Details'),
          content: Column(
            children: [
              Flexible(
                child: CupertinoTextField(
                  onTapOutside: (value) {
                    setState(() {});
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                  autocorrect: true,
                  minLines: 1,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  onChanged: (value) => setState(() {}),
                  placeholder: "Enter Username",
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray.withValues(
                      alpha: 0.5,
                    ),
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                    ), // Customize the border
                    borderRadius: BorderRadius.circular(
                      25,
                    ), // Customize the border radius
                  ),
                  controller: _username,
                  maxLines: 1,
                ),
              ),
              // CupertinoTextField(
              //   autocorrect: false,
              //   // suffix: HugeIcon(
              //   //   icon: HugeIcons.strokeRoundedCheckmarkCircle02,
              //   //   color: Colors.black,
              //   //   size: 24.0,
              //   // ),
              //   placeholder: "Enter Access Code",
              //   decoration: BoxDecoration(
              //     // color: CupertinoColors.activeGreen,
              //     border: Border.all(
              //       color: CupertinoColors.systemGrey,
              //     ), // Customize the border
              //     borderRadius: BorderRadius.circular(
              //       25,
              //     ), // Customize the border radius
              //   ),
              //   controller: _acceescode,
              //   obscureText: true,
              //   maxLines: 1,
              // ),
            ],
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
            // CupertinoDialogAction(
            //   isDefaultAction: true,
            //   child: HugeIcon(
            //     icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            //     color: CupertinoColors.systemBlue,
            //     // size: 24.0,
            //   ),
            //   onPressed: () {
            //     if (inputadminaccess.text == fetchadminaccess.toString()) {
            //       // ScaffoldMessenger.of(
            //       // context,
            //       // ).showSnackBar(const SnackBar(content: Text('Authorized..!!')));
            //       Navigator.of(context).pushReplacement(
            //         CupertinoPageRoute(builder: (context) => HomeScreen()),
            //       );
            //     } else if (inputadminaccess.text !=
            //         fetchadminaccess.toString()) {
            //       CupertinoPopupSurface(child: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge04, color: CupertinoColors.black));
            //
            //     } else
            //           () {};
            //   },
            // ),

          ],
        );
      },
    );
  }




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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MorphedContainer(
                height: global.SizeConfig.screenHeight * 0.48,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              // GridView.count(
              //   primary: false,
              //   padding: const EdgeInsets.all(20),
              //   crossAxisSpacing: 10,
              //   mainAxisSpacing: 10,
              //   crossAxisCount: 2,
              //   children: <Widget>[
              //     Pika(),
              //     Panda(),
              //     Admin(),
              //     Test(),
              //
              //   ]),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Pika(),
                          SizedBox(width: global.SizeConfig.screenWidth * 0.05),
                          Panda()
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Admin(),
                          SizedBox(width: global.SizeConfig.screenWidth * 0.05),
                          Test(),
                        ],
                      ),
                    ),
                  ],
                ),
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




class LoginPrompt extends StatefulWidget {
  final String? username;

  const LoginPrompt({
    Key? key,
    this.username,
  }) : super(key: key);

  @override
  State<LoginPrompt> createState() => _LoginPromptState();
}
class _LoginPromptState extends State<LoginPrompt> {
  late TextEditingController _usernameController;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username ?? "");
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          'Welcome..!!'+'${_usernameController.text}'+'..!!',
          style: TextStyle(
            fontFamily: 'Ethnocentric',
            fontSize: global.SizeConfig.screenHeight * 0.020,
            color: CupertinoColors.white,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.username == null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MorphedContainer(
                width: double.maxFinite,
                child: CupertinoTextField(
                  onChanged: (value) => setState(() {}),
                  onTapOutside: (value) {
                    setState(() {
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onEditingComplete: () {
                    setState(() {
                    });
                  },
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                  autocorrect: true,
                  minLines: 1,
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  placeholder: 'Enter Username',
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray.withValues(
                      alpha: 0.5,
                    ),
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                    ), // Customize the border
                    borderRadius: BorderRadius.circular(
                      25,
                    ), // Customize the border radius
                  ),
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  maxLines: 8,
                ),
              ),
            ),
          ],
          // Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: MorphedContainer(
              width: double.maxFinite,
              child: CupertinoTextField(
                onChanged: (value) => setState(() {}),
                onTapOutside: (value) {
                  setState(() {
                  });
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onEditingComplete: () {
                  setState(() {
                  });
                },
                style: TextStyle(
                  fontFamily: 'SF',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
                controller: _passwordController,
                placeholder: 'Enter password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                minLines: 1,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                // placeholder: 'Enter Username',
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray.withValues(
                    alpha: 0.5,
                  ),
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ), // Customize the border
                  borderRadius: BorderRadius.circular(
                    25,
                  ), // Customize the border radius
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],

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
            // if (inputadminaccess.text == fetchadminaccess.toString()) {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => HomeScreen()),
              );
            }
            // else if
            // (inputadminaccess.text !=
            //     fetchadminaccess.toString()) {
            //   CupertinoPopupSurface(child: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge04, color: CupertinoColors.black));
            //
            // } else
            //       () {};
          // },
        ),
      ],
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
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: global.SizeConfig.screenHeight*0.1,
            width: global.SizeConfig.screenHeight*0.1,
            decoration: BoxDecoration(
              // color:CupertinoColors.systemGrey,
              image: DecorationImage(
                image: AssetImage('assets/images/avatar/Ayushprtp.webp'),
              ),
              color: CupertinoColors.systemGrey4,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            'ADMIN',
            style: TextStyle(
              // backgroundColor: CupertinoColors.destructiveRed,
              fontFamily: 'Blanka',
              color: CupertinoColors.white,
              fontSize: global.SizeConfig.screenHeight * 0.03,
            ),
          ),
        ],
      ),
      onTap: () {
        showCupertinoDialog(
          context: context,
          builder: (_) => LoginPrompt(
            username: "ayushprtp"
          ),
        );
      }
    );
  }
}

class Pika extends StatefulWidget {
  const Pika({super.key});

  @override
  State<Pika> createState() => _PikaState();
}
class _PikaState extends State<Pika> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: global.SizeConfig.screenHeight*0.1,
              width: global.SizeConfig.screenHeight*0.1,
              decoration: BoxDecoration(
                // color:CupertinoColors.systemGrey,
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar/Pika.webp'),
                ),
                color: CupertinoColors.systemGrey4,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Pika',
              style: TextStyle(
                // backgroundColor: CupertinoColors.destructiveRed,
                fontFamily: 'Blanka',
                color: CupertinoColors.white,
                fontSize: global.SizeConfig.screenHeight * 0.03,
              ),
            ),
          ],
        ),
        onTap: () {
          showCupertinoDialog(
            context: context,
            builder: (_) => LoginPrompt(
                username: "pika"
            ),
          );
        }
    );
  }
}


class Panda extends StatefulWidget {
  const Panda({super.key});

  @override
  State<Panda> createState() => _PandaState();
}
class _PandaState extends State<Panda> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: global.SizeConfig.screenHeight*0.1,
              width: global.SizeConfig.screenHeight*0.1,
              decoration: BoxDecoration(
                // color:CupertinoColors.systemGrey,
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar/Panda.webp'),
                ),
                color: CupertinoColors.systemGrey4,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Panda',
              style: TextStyle(
                // backgroundColor: CupertinoColors.destructiveRed,
                fontFamily: 'Blanka',
                color: CupertinoColors.white,
                fontSize: global.SizeConfig.screenHeight * 0.03,
              ),
            ),
          ],
        ),
        onTap: () {
          showCupertinoDialog(
            context: context,
            builder: (_) => LoginPrompt(
                username: "panda"
            ),
          );
        }
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
    return GestureDetector(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: global.SizeConfig.screenHeight*0.1,
              width: global.SizeConfig.screenHeight*0.1,
              decoration: BoxDecoration(
                // color:CupertinoColors.systemGrey,
                image: DecorationImage(
                  image: AssetImage('assets/images/avatar/Test.webp'),
                ),
                color: CupertinoColors.systemGrey4,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              'Test',
              style: TextStyle(
                // backgroundColor: CupertinoColors.destructiveRed,
                fontFamily: 'Blanka',
                color: CupertinoColors.white,
                fontSize: global.SizeConfig.screenHeight * 0.03,
              ),
            ),
          ],
        ),
        onTap: () {
          showCupertinoDialog(
            context: context,
            builder: (_) => LoginPrompt(
            ),
          );
        }
    );
  }
}

