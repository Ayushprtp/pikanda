import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

import '../frontend/login_screen.dart';

String supabaseUrl = 'https://irdehhbanfycpfdcfddv.supabase.co';
String supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyZGVoaGJhbmZ5Y3BmZGNmZGR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5OTUxMjMsImV4cCI6MjA2MDU3MTEyM30.sfLux1N00zMt9hqr6XvijRgz2ZX3vCuqcJHFxIuzzGw';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }
}

class Quote {
  late int qid;
  // late String quote;
}
// class User {
//   static String username ='Not Logged In';
// }
class User {
  String username;
  String role; // Add role here
  // Add other user properties here if needed, e.g., String userId, String email;

  User({required this.username, required this.role});

  // Method to convert User object to a Map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role, // Include role in toJson
      // Add other properties here if you add them to the User class
    };
  }

  // Factory constructor to create a User object from a Map (JSON deserialization)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      role: json['role'] as String, // Include role in fromJson
      // Add other properties here if you add them to the User class
    );
  }
}

// Global class to hold the static User instance
class Global {
  static User? currentUser; // This will hold the entire User object
// static SizeConfig sizeConfig = SizeConfig(); // Assuming you have this
}


class Version {
  // var ver ='$';
  String mame ='Anaconda';
  double number=2025.5;
  double patch=4;
  String desc='Soon To Be Published';
  String img='https://cdn-icons-png.flaticon.com/512/3196/3196026.png';

}





String song = 'Song Name';
String artist = 'Artist';
String thumbnail = '';

String dev_name = 'Ayush Pratap';
String dev_nickname = 'AYU';
String dev_image = 'assets/images/icon.png';
String dev_username = 'ayushprtp';
String dev_mail = 'ayushprtp@outlook.com';
String dev_phone = '+910126126126';
String dev_github = 'github.com/ayushprtp';
String dev_discord = 'discord.com/ayushprtp';
String dev_facebook = 'www.facebook.com/ayushprtp';
String dev_instagram = 'instagram.com/ayushprtp';
String dev_snapchat = 'snapchat.com/add/ayushprtp';
String dev_threads = 'threads.com/ayushprtp';
String dev_x = 'x.com/ayushprtp';
String dev_youtube = 'youtube.com/@ayushprtp';
