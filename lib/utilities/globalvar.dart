import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

String supabaseUrl = 'https://irdehhbanfycpfdcfddv.supabase.co';
String supabaseKey = String.fromEnvironment(
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlyZGVoaGJhbmZ5Y3BmZGNmZGR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQ5OTUxMjMsImV4cCI6MjA2MDU3MTEyM30.sfLux1N00zMt9hqr6XvijRgz2ZX3vCuqcJHFxIuzzGw',
);

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

// class QuoteId {
//   final int qid;
//   late String quote;

//   QuoteId({required this.qid});
// }

String song = 'Song Name';
String artist = 'Artist';
String thumbnail = '';

String dev_name = 'Ayush Pratap';
String dev_nickname = 'AYU';
String dev_image = 'assets/images/icon.png';
String dev_username = 'ayushprtp';
String dev_instagram = 'instagram.com/ayushprtp';
String dev_threads = 'threads.com/ayushprtp';
String dev_facebook = 'facebook.com/ayushprtp';
String dev_youtube = 'youtube.com/@ayushprtp';
String dev_x = 'x.com/ayushprtp';
String dev_discord = 'discord.com/ayushprtp';
String dev_mail = 'ayushprtp@outlook.com';
