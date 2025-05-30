import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikanda/frontend/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'dart:convert'; // Import for jsonDecode

// Your home screens based on roles
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoAndCheckLogin();
  }

  Future<void> _initializeVideoAndCheckLogin() async {
    // Initialize video
    _controller = VideoPlayerController.asset('assets/videos/splash.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() {});
      })
      ..setVolume(0.1);

    // Play video
    _controller.play();

    // Wait for the video to play, or for a minimum duration
    await Future.delayed(const Duration(seconds: 3)); // 3-second splash screen

    if (!mounted) return;

    // Then proceed with login status check
    await _checkLoginStatus();
  }

  /// Checks if a user is persistently logged in and navigates accordingly.
  Future<void> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userDataJson = prefs.getString('currentUser'); // Retrieve the full user JSON

    if (userDataJson != null && userDataJson.isNotEmpty) {
      try {
        final Map<String, dynamic> userDataMap = jsonDecode(userDataJson);
        final user = global.User.fromJson(userDataMap); // Deserialize into User object
        global.Global.currentUser = user; // Update the global user object

        // Navigate based on the role stored in the User object
        _navigateToAppropriateScreen(user.role);

      } catch (e) {
        print("Error decoding stored user data or missing role: $e");
        // Clear invalid data and go to login
        await prefs.remove('currentUser');
        _navigateToLogin();
      }
    } else {
      // No stored user data, navigate to the login page
      _navigateToLogin();
    }
  }

  // Helper method to navigate based on role (can be shared or defined in LoginPrompt)
  void _navigateToAppropriateScreen(String role) {
    Widget targetScreen;
    if (role == "admin") {
      targetScreen = AdminHomeScreen();
    } else if (role == "pikanda") {
      targetScreen = PikandaHomeScreen();
    } else if (role == "test") {
      targetScreen = QuoteScreen();
    } else { // Default for "user" role or unknown roles
      targetScreen = HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => targetScreen),
    );
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            height: global.SizeConfig.screenHeight*0.2,
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : Container(),
          ),
        ),
      ),
    );
  }
}