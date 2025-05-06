import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:hugeicons/hugeicons.dart';

class SongWidget extends StatefulWidget {
  SongWidget({super.key});

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: CupertinoColors.black),
                        borderRadius: BorderRadius.circular(25),
                        color: CupertinoColors.white,
                      ),

                      child: Image(
                        image: AssetImage('assets/images/icon.png'),
                        height: global.SizeConfig.screenHeight * 0.07,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${global.song}',
                          style: TextStyle(
                            fontSize: global.SizeConfig.screenHeight * 0.0256,
                            color: CupertinoColors.systemGrey4,
                          ),
                        ),
                        Text(
                          '${global.artist}',
                          style: TextStyle(
                            fontSize: global.SizeConfig.screenHeight * 0.022,
                            color: CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () {},
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPlay,
                            color: CupertinoColors.white,
                          ),
                        ),
                        //Yeha Colors ka abhi khel baki hai and funstions add krna
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: IconButton.filledTonal(
                            highlightColor: CupertinoColors.systemGrey,

                            onPressed: () {},
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedHeadsetOff,
                              color: CupertinoColors.systemRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: CupertinoColors.systemRed,
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
