import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// Removed unused imports: geolocator, database, test
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/frontend/version_screen.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:shared_preferences/shared_preferences.dart'; // Added for shared_preferences
import 'dart:convert';

import '../test.dart'; // Added for jsonEncode/jsonDecode

// Define your usernameToRole map (can be moved to global.dart if preferred)
final Map<String, String> usernameToRole = {
  "ayushprtp": "admin",
  "panda": "pikanda",
  "pika": "pikanda",
  "test": "test",
  "john": "user",
};

// --- LoginScreen remains largely the same, but _showLoginDailogue is removed ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Removed _showLoginDailogue as LoginPrompt will handle all login input

  @override
  Widget build(BuildContext context) {
    // Make sure SizeConfig is initialized somewhere, typically in main.dart or a wrapper
    // For this example, we assume it's initialized correctly before LoginScreen is built.
    // If not, you might get errors like "screenHeight not initialized".
    // Example: global.SizeConfig().init(context);

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
          const Spacer(),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: MorphedContainer(
                height: global.SizeConfig.screenHeight * 0.3,
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
                    SizedBox(
                      height: global.SizeConfig.screenHeight * 0.2,
                      child: GridView.count(
                        crossAxisCount: 2,
                        children: [
                          Admin(),
                          // Pika(),
                          // Panda(),
                          Test(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
           Spacer(),
           TestButton(), // Assuming TestButton and CheckButton are still relevant
           CheckButton(),
           Align(alignment: Alignment.bottomCenter, child: Ver()),
        ],
      ),
    );
  }
}

// --- MODIFIED LoginPrompt ---
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

  // MODIFIED _handleLogin to save user data and navigate
  Future<void> _handleLogin(BuildContext context) async {
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

    // --- Authentication Logic Here ---
    // For now, we assume successful authentication.
    // You would typically verify username and password against a backend or local database here.
    // Example: if (_passwordController.text != "correct_password") { /* set error */ return; }

    // 1. Create a User object with username AND role
    final user = global.User(username: username, role: role);

    // 2. Update global user object
    global.Global.currentUser = user;

    // 3. Save user data to SharedPreferences (includes role)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(user.toJson()));

    // Close the dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    // 4. Navigate to the appropriate screen based on role
    if (mounted) {
      _navigateToAppropriateScreen(role);
    }
  }

  // Helper method to navigate based on role (shared with SplashScreen)
  void _navigateToAppropriateScreen(String role) {
    Widget targetScreen;
    if (role == "admin") {
      targetScreen = AdminHomeScreen();
    } else if (role == "pikanda") {
      targetScreen = PikandaHomeScreen();
    } else if (role == "test") {
      targetScreen = QuoteScreen();
    } else {
      // Default for "user" role or unknown roles
      targetScreen = HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          'Welcome..!! ${_role ?? ''}..!!', // Display role if available
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
          if (widget.username == null) // Show username input only if not pre-filled
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: MorphedContainer(
                width: double.maxFinite,
                child: CupertinoTextField(
                  onChanged: _onUsernameChanged,
                  onTapOutside: (value) => FocusManager.instance.primaryFocus?.unfocus(),
                  style: const TextStyle(
                    fontFamily: 'SF',
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                  ),
                  autocorrect: true,
                  minLines: 1,
                  maxLength: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                style: const TextStyle(
                  fontFamily: 'SF',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
                controller: _passwordController,
                placeholder: 'Enter password',
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                minLines: 1,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                style: const TextStyle(
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
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedCancelCircle,
            color: CupertinoColors.destructiveRed,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            color: CupertinoColors.systemBlue,
          ),
          onPressed: () {
            _handleLogin(context);
          },
        ),
      ],
    );
  }
}

// --- Existing User Selector Widgets ---
class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

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
            height: global.SizeConfig.screenHeight * 0.1,
            width: global.SizeConfig.screenHeight * 0.1,
            decoration: const BoxDecoration(
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
          builder: (_) => const LoginPrompt(
            username: "ayushprtp", // Pre-fill username for this user
          ),
        );
      },
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
            height: global.SizeConfig.screenHeight * 0.1,
            width: global.SizeConfig.screenHeight * 0.1,
            decoration: const BoxDecoration(
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
          builder: (_) => const LoginPrompt(
            username: "pika", // Pre-fill username for this user
          ),
        );
      },
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
            height: global.SizeConfig.screenHeight * 0.1,
            width: global.SizeConfig.screenHeight * 0.1,
            decoration: const BoxDecoration(
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
          builder: (_) => const LoginPrompt(
            username: "panda", // Pre-fill username for this user
          ),
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
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: global.SizeConfig.screenHeight * 0.1,
            width: global.SizeConfig.screenHeight * 0.1,
            decoration: const BoxDecoration(
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
          builder: (_) => const LoginPrompt(
            // No username pre-filled here, user will type it
          ),
        );
      },
    );
  }
}