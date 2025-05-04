import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;
import 'package:geolocator/geolocator.dart';

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
