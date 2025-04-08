import 'package:flutter/cupertino.dart';

String song = 'sdfgh';

double screenWidth = 0.0;
double screenHeight = 0.0;

void initScreenSize(BuildContext context) {
  screenWidth = MediaQuery.of(context).size.width;

  screenHeight = MediaQuery.of(context).size.height;
}
