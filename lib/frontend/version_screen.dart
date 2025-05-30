import 'package:cached_network_image/cached_network_image.dart';
import 'package:pikanda/frontend/devinfo_screen.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilities/morphsimcontainer.dart';

class Ver extends StatelessWidget {
  const Ver({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // disabledColor: CupertinoColors.activeBlue,
      // focusColor: CupertinoColors.activeGreen,
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25.0,
                    vertical: 5,
                  ),
                  child: MorphedContainer(
                    height: global.SizeConfig.screenHeight * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(),
                              // image: DecorationImage(image: )
                              child: CachedNetworkImage(
                                imageUrl: global.Version().img,
                                height: global.SizeConfig.screenHeight * 0.06,
                                width: global.SizeConfig.screenHeight * 0.06,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '${global.Version().mame}',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: global.SizeConfig.screenHeight * 0.02,
                                      fontFamily: 'Ethnocentric',
                                      decorationStyle: TextDecorationStyle.double,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: '//',
                                        style: TextStyle(
                                          fontFamily: 'Ethnocentric',
                                          color: CupertinoColors.systemRed,
                                          fontSize: global.SizeConfig.screenHeight * 0.03,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${global.Version().number}',
                                        style: TextStyle(
                                          fontFamily: 'Ethnocentric',
                                          color: CupertinoColors.black,
                                          fontSize: global.SizeConfig.screenHeight * 0.02,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Text(
                                //   '${global.Version().mame}',
                                //   style: TextStyle(
                                //     color: CupertinoColors.white,
                                //     fontSize:
                                //         global.SizeConfig.screenHeight * 0.03,
                                //     fontFamily: 'Ethnocentric',
                                //   ),
                                // ),
                                // Text(
                                //   '${global.Version().number}',
                                //   style: TextStyle(
                                //     color: CupertinoColors.black,
                                //     fontSize:
                                //         global.SizeConfig.screenHeight * 0.03,
                                //     fontFamily: 'Ethnocentric',
                                //   ),
                                // ),
                                Text(
                                  'Patch: ${global.Version().patch}',
                                  style: TextStyle(
                                    color: CupertinoColors.destructiveRed,
                                    fontSize:
                                    global.SizeConfig.screenHeight * 0.015,
                                    fontFamily: 'Ethnocentric',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        MorphedContainer(
                          height: global.SizeConfig.screenHeight * 0.09,
                          width: double.maxFinite,
                          color: CupertinoColors.black.withAlpha(150),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text('${global.Version().desc}',style: TextStyle(fontSize: global.SizeConfig.screenHeight*0.02),),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  child:
                  Center(
                    child: Dev(),
                    // child: RichText(
                    //   text: TextSpan(
                    //     text: 'Desinged By ',
                    //     style: TextStyle(
                    //       color: CupertinoColors.white,
                    //       fontSize: global.SizeConfig.screenHeight * 0.025,
                    //       fontFamily: 'Jasmine',
                    //     ),
                    //     children: <TextSpan>[
                    //       TextSpan(text: ' AYU ', style: TextStyle(fontFamily: 'Blanka')),
                    //       TextSpan(text: ' <3', style: TextStyle(fontFamily: 'SF')),
                    //     ],
                    //   ),
                    // ),
                  ),
                  onTap: (
                    ){

                  // Navigator.of(context).pop();

                },)
              ],

              message: Text('Shows Current App Version'),
              title: Text('Version Info',style: TextStyle(fontSize: global.SizeConfig.screenHeight*0.02),),
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            );
          },
        );
      },
      child: RichText(
        text: TextSpan(
          text: '${global.Version().mame}',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: global.SizeConfig.screenHeight * 0.02,
            fontFamily: 'Ethnocentric',
            decorationStyle: TextDecorationStyle.double,
          ),
          children: <TextSpan>[
            TextSpan(
              text: '//',
              style: TextStyle(
                fontFamily: 'Ethnocentric',
                color: CupertinoColors.systemRed,
                fontSize: global.SizeConfig.screenHeight * 0.03,
              ),
            ),
            TextSpan(
              text: '${global.Version().number}',
              style: TextStyle(
                fontFamily: 'Ethnocentric',
                color: CupertinoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
