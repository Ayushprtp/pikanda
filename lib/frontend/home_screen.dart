import 'package:Pikanda/frontend/devinfo_screen.dart';
import 'package:Pikanda/frontend/quote_screen.dart';
import 'package:Pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Bg(
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.activeGreen,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('####'),
              Text('####'),
              CupertinoButton.filled(
                child: const Text("Quote Screen"),
                onPressed: () {
                  // Navigator.of(context).push(
                  //   CupertinoPageRoute(
                  //     builder: (context) => const QuoteScreen(),
                  //   ),
                  // );
                },
              ),
              Text('####'),
              Text('####'),
              Spacer(),
              Align(alignment: Alignment.bottomCenter, child: Dev()),
            ],
          ),
        ),
      ),
    );
  }
}

// homescreen will be deisged using super cupertinonaviagation baar
