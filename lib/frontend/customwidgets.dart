import 'package:flutter/cupertino.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/frontend/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utilities/globalvar.dart' as global;

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  // This function encapsulates the logout logic
  Future<void> _handleLogout(BuildContext context) async {
    // 1. Clear locally stored user data from SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Assuming you store the entire User object as a JSON string under the key 'currentUser'
    await prefs.remove('currentUser');
    // If you stored individual keys like 'username' or 'user_role' separately,
    // ensure you remove those as well:
    // await prefs.remove('username');
    // await prefs.remove('user_role');
    // await prefs.remove('is_logged_in'); // If you have a separate login status flag

    // 2. Clear the global user object in your Global class
    global.Global.currentUser = null;

    // 3. Navigate back to the SplashScreen and clear all previous routes
    // This effectively "restarts" the app's navigation flow from the beginning,
    // mimicking a fresh start, which will then hit the SplashScreen to check for login status.
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(builder: (context) => const SplashScreen()),
        // This predicate (route) => false means remove all routes until none are left.
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Option 1: Cupertino Button (ideal for iOS-style apps, matching your existing UI)
    return GestureDetector(child: HugeIcon(icon: HugeIcons.strokeRoundedLogoutSquare02, color: CupertinoColors.destructiveRed),onTap: () =>_handleLogout(context));

  }
}