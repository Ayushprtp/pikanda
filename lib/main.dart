
import 'package:flutter/services.dart';
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/frontend/login_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pikanda/frontend/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'backend/music_services.dart';
import 'firebase_options.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: global.supabaseUrl,
    anonKey: global.supabaseUrl);


  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Initialize your new YoutubeMusicApiService
  await YoutubeMusicApiService().init(prefs);

  runApp(const MyApp());
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {

  // 2. Define the constructor with 'musicServices' as a REQUIRED named parameter
  const MyApp({super.key});
  //                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ This part is key!

  @override
  Widget build(BuildContext context) {
    global.SizeConfig.init(context);
    return CupertinoApp(
      debugShowCheckedModeBanner: false,

      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: "SF", fontStyle: FontStyle.normal,color: CupertinoColors.white),
        ),
      ),
      // title: 'pikanda',
      home: SplashScreen()
      // Banner(
      //   message: 'Basic',
      //   textStyle: TextStyle(
      //     fontFamily: 'SF',
      //     fontWeight: FontWeight.w500,
      //     color: CupertinoColors.black,
      //   ),
      //   color: CupertinoColors.destructiveRed,
      //   location: BannerLocation.bottomStart,
      //
      //   child: SplashScreen(),
      // ),
    );
  }
}
