import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/utilities/globalvar.dart' as global;

class SongWidget extends StatefulWidget {
  const SongWidget({super.key});

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.black,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CupertinoColors.destructiveRed,
                    ),

                    child: Image(
                      image: AssetImage('assets/images/icon.png'),
                      height: 50,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${global.song}',
                          style: TextStyle(
                            fontSize: 20,
                            color: CupertinoColors.systemGrey5,
                          ),
                        ),
                        Text(
                          '${global.artist}',
                          style: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: IconButton.filled(
                    onPressed: null,
                    icon: Icon(
                      CupertinoIcons.pause,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: IconButton.filled(
                    onPressed: null,
                    icon: Icon(
                      CupertinoIcons.headphones,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
