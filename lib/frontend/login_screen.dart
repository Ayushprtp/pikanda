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
                height: global.SizeConfig.screenHeight * 0.3,
                width: double.infinity,
                child:
                Column(
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
                    SizedBox(
                      height: global.SizeConfig.screenHeight * 0.2,
                      child: GridView.count(crossAxisCount: 2,

                        children: [
                          // Pika(),
                          // Panda(),
                          Admin(),
                          Test(),
                        ],

                      ),
                    )
                        ],
                      // ),
                    // ),
                  // ],
                ),
              ),
            ),
          ),
          Spacer(),
          TestButton(),
          CheckButton(),
          Align(alignment: Alignment.bottomCenter, child: Dev()),
        ],
      ),
    );
  }
}


final Map<String, String> usernameToRole = {
  "ayushprtp": "admin",
  "panda": "pikanda",
  "pika": "pikanda",
  "test": "test",
  "john": "user",
};

class LoginPrompt extends StatefulWidget {
  final String? username;

  const LoginPrompt({
    super.key,
    this.username,
  });

  @override
  State<LoginPrompt> createState() => _LoginPromptState();
}
class _LoginPromptState extends State<LoginPrompt> {
  late TextEditingController _usernameController;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _role;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username ?? "");
    if (widget.username != null) {
      _role = usernameToRole[widget.username!];
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    setState(() {
      _role = usernameToRole[value.trim()];
      _errorText = null;
    });
  }

  void _handleLogin(BuildContext context) {
    final username = (widget.username ?? _usernameController.text).trim();
    final role = _role ?? usernameToRole[username];

    if (username.isEmpty) {
      setState(() => _errorText = "Username required!");
      return;
    }
    if (role == null) {
      setState(() => _errorText = "Username not found!");
      return;
    }

    Navigator.of(context).pop(); // Close dialog

    if (role == "admin") {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => AdminHomeScreen()),
      );
    } else if (role == "pikanda") {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => PikandaHomeScreen()),
      );
    } else if (role == "test") {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => TestHomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          'Welcome..!! ${_role}..!!',
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
          if (widget.username == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MorphedContainer(
                width: double.maxFinite,
                child: CupertinoTextField(
                  onChanged: _onUsernameChanged,
                  onTapOutside: (value) => FocusManager.instance.primaryFocus?.unfocus(),
                  style: TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                  autocorrect: true,
                  minLines: 1,
                  maxLength: 16,
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  placeholder: 'Enter Username',
                  decoration: BoxDecoration(
                    color: CupertinoColors.darkBackgroundGray.withAlpha(127),
                    border: Border.all(
                      color: CupertinoColors.systemGrey,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: MorphedContainer(
              width: double.maxFinite,
              child: CupertinoTextField(
                suffixMode: OverlayVisibilityMode.editing,
                suffix: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    child: HugeIcon(
                        icon: _obscurePassword ? HugeIcons.strokeRoundedView : HugeIcons.strokeRoundedViewOff,
                        color: CupertinoColors.white),
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onTapOutside: (value) => FocusManager.instance.primaryFocus?.unfocus(),
                style: TextStyle(
                  fontFamily: 'SF',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
                controller: _passwordController,
                placeholder: 'Enter password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                minLines: 1,
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray.withAlpha(127),
                  border: Border.all(
                    color: CupertinoColors.systemGrey,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                maxLines: 1,
              ),
            ),
          ),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                _errorText!,
                style: TextStyle(
                  color: CupertinoColors.destructiveRed,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
          ),
          onPressed: () {
            _handleLogin(context);},
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





