import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';
import 'package:myapp/frontend/splash_screen.dart';

void main() {
  runApp(DevicePreview(builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(home: SplashScreen());
  }
}
