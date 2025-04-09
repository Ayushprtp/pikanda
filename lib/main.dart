import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';
import 'package:myapp/frontend/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://xyzcompany.supabase.co',
    anonKey: 'public-anon-key',
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(DevicePreview(builder: (context) => const MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: "SF", fontStyle: FontStyle.normal),
        ),
      ),
      title: 'Pikanda',
      home: Banner(
        message: 'Beta',
        textStyle: TextStyle(color: CupertinoColors.black),
        color: CupertinoColors.destructiveRed,
        location: BannerLocation.bottomEnd,
        child: HomeScreen(),
      ),
    );
  }
}
