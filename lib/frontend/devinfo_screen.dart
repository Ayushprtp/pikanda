import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/test.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';

class Dev extends StatefulWidget {
  const Dev({super.key});

  @override
  State<Dev> createState() => _DevState();
}

class _DevState extends State<Dev> {
  void _DevPopUP(){

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoPopupSurface(
          blurSigma: 5,
          isSurfacePainted: true,
          child: Container(
            height: global.SizeConfig.screenHeight * 0.4,

            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: CupertinoColors.white,
                        maxRadius: global.SizeConfig.screenHeight * 0.05,
                        minRadius: global.SizeConfig.screenHeight * 0.04,
                        child: Image(
                          image: AssetImage('assets/images/icon.png'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: ('${global.dev_name}'),
                                style: TextStyle(
                                  fontSize:
                                  global.SizeConfig.screenHeight * 0.03,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: (' ( ${global.dev_nickname} )'),
                                    style: TextStyle(fontFamily: 'Blanka'),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '@${global.dev_username}',
                              style: TextStyle(
                                fontSize:
                                global.SizeConfig.screenHeight * 0.025,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  CupertinoActivityIndicator(
                    animating: true,
                    radius: global.SizeConfig.screenHeight * 0.02,
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            highlightColor: CupertinoColors.systemGrey,
                            onPressed: () async {
                              // try {
                              //   Uri url = Uri(
                              //     scheme: 'https',
                              //     path: "${global.dev_phone}",
                              //   );
                              //   await launchUrl(url);
                              // } catch (e) {
                              //   debugPrint(e.toString());
                              // }
                            },
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCallOutgoing04,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          IconButton.filledTonal(
                            highlightColor: CupertinoColors.systemGrey,
                            onPressed: () async {
                              // try {
                              //   Uri url = Uri(
                              //     scheme: 'https',
                              //     path: "${global.dev_mail}",
                              //   );
                              //   await launchUrl(url);
                              // } catch (e) {
                              //   debugPrint(e.toString());
                              // }
                            },
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedMailLove02,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri email = Uri(
                                scheme: 'https',
                                path: "${global.dev_github}",
                              );
                              await launchUrl(email);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedGithub,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_discord}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedDiscord,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_facebook}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedFacebook02,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_instagram}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedInstagram,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_snapchat}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSnapchat,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_threads}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedThreads,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_x}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedNewTwitter,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        IconButton.filledTonal(
                          highlightColor: CupertinoColors.systemGrey,
                          onPressed: () async {
                            try {
                              Uri url = Uri(
                                scheme: 'https',
                                path: "${global.dev_youtube}",
                              );
                              await launchUrl(url);
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedYoutube,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CupertinoNavigationBarBackButton(
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      // disabledColor: CupertinoColors.activeBlue,
      // focusColor: CupertinoColors.activeGreen,
      onPressed: () {
        Navigator.of(context).pop();
        _DevPopUP();
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