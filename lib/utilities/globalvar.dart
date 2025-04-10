import 'package:flutter/cupertino.dart';

String song = 'Song Name';
String artist = 'Artist';

double screenWidth = 0.0;
double screenHeight = 0.0;

void initScreenSize(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width;

  screenHeight = MediaQuery.of(context).size.height;
}
