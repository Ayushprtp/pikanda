import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikanda/backend/database.dart';
import 'package:pikanda/frontend/home_screen.dart';
import 'package:pikanda/frontend/login_screen.dart';
import 'package:pikanda/frontend/quote_screen.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';

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

class CheckButton extends StatefulWidget {
  const CheckButton({super.key});

  @override
  State<CheckButton> createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton.filled(

      // color: CupertinoColors.black,
      pressedOpacity: 0.4,
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedCompass01,
        color: CupertinoColors.activeOrange,
      ),
      onPressed:
        // / print(readData());

      () => Navigator.of(
        context,
      ).push(CupertinoPageRoute(builder: (context) => BgMaterial(child:MorphedContainer(child: ReactionContextMenuWidget(child: Text('data'))  ))))
    );
  }
}


class ReactionContextMenuWidget extends StatefulWidget {
  final Widget child;
  const ReactionContextMenuWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<ReactionContextMenuWidget> createState() => _ReactionContextMenuWidgetState();
}

class _ReactionContextMenuWidgetState extends State<ReactionContextMenuWidget> {
  bool _showReactions = false;
  Offset? _tapPosition;

  List<String> reactions = ["😭", "🔥", "❤️", "👍", "👎", "🥰", "👏"];

  void _onLongPress(BuildContext context, LongPressStartDetails details) {
    setState(() {
      _showReactions = true;
      _tapPosition = details.globalPosition;
    });
    // Optionally, you can add a timer to auto-hide after some seconds
  }

  void _onTap() {
    if (_showReactions) {
      setState(() {
        _showReactions = false;
      });
    }
  }

  void _onReactionTap(String reaction) {
    setState(() {
      _showReactions = false;
    });
    // Handle selected reaction here
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected: $reaction"))
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _onLongPress(context, details),
      onTap: _onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          CupertinoContextMenu(
            actions: [
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.reply), SizedBox(width: 10), Text("Reply")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.photo), SizedBox(width: 10), Text("Copy Image")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.link), SizedBox(width: 10), Text("Copy Message Link")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.download_circle), SizedBox(width: 10), Text("Download")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.forward), SizedBox(width: 10), Text("Forward")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                child: Row(
                  children: [Icon(CupertinoIcons.check_mark_circled), SizedBox(width: 10), Text("Select")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
              CupertinoContextMenuAction(
                isDestructiveAction: true,
                child: Row(
                  children: [Icon(CupertinoIcons.flag), SizedBox(width: 10), Text("Report")],
                ),
                onPressed: () { Navigator.pop(context); },
              ),
            ],
            child: widget.child,
          ),
          if (_showReactions && _tapPosition != null)
            Positioned(
              bottom: 70, // Adjust as needed
              left: 0,
              right: 0,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: reactions.map((e) => GestureDetector(
                        onTap: () => _onReactionTap(e),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0),
                          child: Text(
                            e,
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

