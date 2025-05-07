import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Hello..!!', style: TextStyle(fontFamily: 'Blanka', fontSize: 25)),
        Text(
          '${DeviceInfoPlugin().androidInfo}',
          style: TextStyle(fontFamily: 'Jasmine', fontSize: 25),
        ),
        Text(
          '${Geolocator.isLocationServiceEnabled()}',
          style: TextStyle(fontFamily: 'Ethnocentric', fontSize: 25),
        ),
        Text(
          '${global.SizeConfig.screenWidth}',
          style: TextStyle(fontFamily: 'SF', fontSize: 25),
        ),
        Text(
          '${global.SizeConfig.screenHeight}',
          style: TextStyle(fontFamily: 'SF', fontSize: 25),
        ),
      ],
    );
  }
}

class TestButton extends StatefulWidget {
  const TestButton({super.key});

  @override
  State<TestButton> createState() => TestButtonState();
}

class TestButtonState extends State<TestButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton.tinted(
      color: CupertinoColors.black,
      pressedOpacity: 0.4,
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedHugeicons,
        color: CupertinoColors.activeOrange,
      ),
      onPressed:
          () => Navigator.of(
            context,
          ).push(CupertinoPageRoute(builder: (context) => QuoteScreen())),
    );
  }
}
