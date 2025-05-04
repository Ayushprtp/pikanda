import 'package:flutter/cupertino.dart';
import 'package:Pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Dev extends StatelessWidget {
  const Dev({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      // disabledColor: CupertinoColors.activeBlue,
      // focusColor: CupertinoColors.activeGreen,
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            return CupertinoPopupSurface(
              // blurSigma: 5,
              isSurfacePainted: true,
              child: Container(
                height: global.SizeConfig.screenHeight * 0.4,

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: CupertinoColors.activeOrange,
                          maxRadius: global.SizeConfig.screenHeight * 0.05,
                          minRadius: global.SizeConfig.screenHeight * 0.04,
                          child: Image(
                            image: AssetImage('assets/images/icon.png'),
                          ),
                        ),
                        Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                text: ('${global.dev_name}'),
                                style: TextStyle(
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.025,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: ('${global.dev_nickname}'),
                                    style: TextStyle(fontFamily: 'Blanka'),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${global.song}',
                              style: TextStyle(
                                fontSize:
                                    global.SizeConfig.screenHeight * 0.0256,
                                color: CupertinoColors.systemGrey4,
                              ),
                            ),
                            // Text('${global.dev_username}'),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            const url =
                                'https://www.facebook.com/yourusername'; // Replace with actual URL
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              print('Could not launch $url');
                            }
                          },
                          icon: HugeIcon(
                            icon:
                                HugeIcons
                                    .strokeRoundedMailLove02, // Replace with Facebook icon
                            color: CupertinoColors.systemRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: RichText(
        text: TextSpan(
          text: 'Desinged By ',
          style: TextStyle(
            color: CupertinoColors.white,
            fontSize: global.SizeConfig.screenHeight * 0.025,
            fontFamily: 'Jasmine',
          ),
          children: <TextSpan>[
            TextSpan(text: ' AYU ', style: TextStyle(fontFamily: 'Blanka')),
            TextSpan(text: ' <3', style: TextStyle(fontFamily: 'SF')),
          ],
        ),
      ),
    );
  }
}
