import 'package:flutter/cupertino.dart';

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
        Text('Hello..!!', style: TextStyle(fontFamily: 'Blanka', fontSize: 45)),
        Text(
          'Hello..!!',
          style: TextStyle(fontFamily: 'Jasmine', fontSize: 45),
        ),
        Text(
          'Hello..!!',
          style: TextStyle(fontFamily: 'Ethnocentric', fontSize: 45),
        ),
        Text('Hello..!!', style: TextStyle(fontFamily: 'SF', fontSize: 45)),
      ],
    );
  }
}
