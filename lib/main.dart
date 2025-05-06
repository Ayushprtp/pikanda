import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/frontend/login_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;

Future<void> main() async {
  await Supabase.initialize(
    url: global.supabaseUrl,
    anonKey: global.supabaseUrl,
  );
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(DevicePreview(builder: (context) => const MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    global.SizeConfig.init(context);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,

      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: "SF", fontStyle: FontStyle.normal),
        ),
      ),
      // title: 'pikanda',
      home: Banner(
        message: 'Basic',
        textStyle: TextStyle(
          fontFamily: 'SF',
          fontWeight: FontWeight.w500,
          color: CupertinoColors.black,
        ),
        color: CupertinoColors.destructiveRed,
        location: BannerLocation.bottomStart,

        child: HomeScreen(),
      ),
    );
  }
}
