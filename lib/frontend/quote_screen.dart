import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pikanda/utilities/bg.dart';
import 'package:flutter/cupertino.dart';
import 'package:pikanda/frontend/quote_widget.dart';
import 'package:pikanda/frontend/song_widget.dart';
import 'package:pikanda/utilities/globalvar.dart' as global;
import 'package:hugeicons/hugeicons.dart';
import 'package:pikanda/utilities/morphsimcontainer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class QuoteScreen extends StatefulWidget {
  QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final String _sUrl =
      'https://youtu.be/fWQpb6T89d4?si=GegMKgy3RjyMvTWw';
      // 'https://music.youtube.com/watch?v=gZ0vHQKfNH8&si=6vcVbUSFrqNxsWch';
      // 'https://music.youtube.com/watch?v=_9FyH8PmRSU&si=HZdrsG380n2PjIsM';
  final FocusNode _urlFocusNode = FocusNode();
  String? _currentUrl;
  @override
  Widget build(BuildContext context) {
    return BgMaterial(
      leading: CupertinoNavigationBarBackButton(),
      middle: Text(
        'Quotesss..!!',
        style: TextStyle(
          fontFamily: 'Ethnocentric',
          fontSize: global.SizeConfig.screenHeight * 0.025,
          color: CupertinoColors.white,
        ),
      ),
      trailing: GestureDetector(
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedBookmark02,
          color: CupertinoColors.systemGrey,
        ),
        onTap: () {},
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Align(alignment: Alignment.center, child: QuoteWidget()),
          // Align(alignment: Alignment.bottomCenter,child: Response()),
          Spacer(),
          // Response(),

          // Spacer(),
        ],
      ),
      bottomWidget: SongWidget(sUrl: '$_sUrl'),
    );
  }
}

// void _onUrlFocusChange() {
//   if (_urlFocusNode.hasFocus) {
//     // When the TextField gains focus, scroll it into view.
//     // Using addPostFrameCallback to ensure this runs after the layout has been updated for the keyboard.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted && _urlFocusNode.context != null) {
//         Scrollable.ensureVisible(
//           _urlFocusNode.context!,
//           duration: const Duration(milliseconds: 250), // Animation duration
//           curve: Curves.easeOut, // Animation curve
//           alignment: 0.4, // Try to align the field slightly above center (0.0 is top, 1.0 is bottom)
//         );
//       }
//     });
//   }
// }

class Response extends StatefulWidget {
  const Response({super.key});

  @override
  State<Response> createState() => _ResponseState();
}

class _ResponseState extends State<Response> {
  final TextEditingController _response = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MorphedContainer(
        width: double.maxFinite,
        // height: double.maxFinite,
        child: Column(
          children: [
            CupertinoTextField(
              onTapOutside: (value) {
                setState(() {});
                FocusManager.instance.primaryFocus?.unfocus();
              },
              prefix: Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedHugeicons,
                    color: CupertinoColors.white,
                  ),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedHugeicons,
                    color: CupertinoColors.white,
                  ),
                ],
              ),
              suffixMode: OverlayVisibilityMode.editing,
              suffix: Row(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedHugeicons,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
              style: TextStyle(
                fontFamily: 'SF',
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
              autocorrect: true,
              minLines: 2,
              onChanged: (value) => setState(() {}),
              placeholder: "Express Your Feelingsss..!!",
              decoration: BoxDecoration(
                color: CupertinoColors.darkBackgroundGray.withValues(
                  alpha: 0.5,
                ),
                border: Border.all(
                  color: CupertinoColors.systemGrey,
                ), // Customize the border
                borderRadius: BorderRadius.circular(
                  25,
                ), // Customize the border radius
              ),
              controller: _response,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class SongWidget extends StatefulWidget {
  late String sUrl = _SongWidgetState()._surl;
  SongWidget({Key? key, required this.sUrl});
  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  bool _isSongPlaying = false;
  bool _isDeviceMute = false;
  final player = AudioPlayer();
  String _surl = _QuoteScreenState()._sUrl;

  String? title;
  String? artist;
  String? audioUrl;
  String? thumbnailUrl;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMeta();
  }
  Future<void> fetchMeta() async {
    setState(() {
      loading = true;
      error = null;
    });
    final yt = YoutubeExplode();
    try {
      final song = await yt.videos.get(_surl);
      final manifest = await yt.videos.streamsClient.getManifest(_surl);

      // Filter for m4a (audio/mp4) streams
      final m4aStreams = manifest.audioOnly
          .where((s) => s.codec.mimeType == 'audio/mp4')
          .toList();

      String? directUrl;
      if (m4aStreams.isNotEmpty) {
        // Take the highest bitrate m4a stream
        m4aStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        directUrl = m4aStreams.first.url.toString();
      }

      setState(() {
        title = song.title;
        artist = song.author;
        thumbnailUrl = song.thumbnails.highResUrl;
        audioUrl = directUrl; // <-- this is your direct m4a audio link
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    } finally {
      yt.close();
    }
  }

  @override
  void initstate() {
    player.setUrl('$audioUrl');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        height: global.SizeConfig.screenHeight*0.1,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: CupertinoColors.destructiveRed,
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
                    padding: EdgeInsets.only(left: 5.0),
                    child: Container(
                      width: global.SizeConfig.screenWidth * 0.3,
                      height: global.SizeConfig.screenWidth * 0.2,
                      decoration: BoxDecoration(

                        border: Border.all(color: CupertinoColors.black),
                        borderRadius: BorderRadius.circular(25),
                        color: CupertinoColors.white,
                      ),
                      child: CachedNetworkImage(
                        // width: global.SizeConfig.screenWidth * 0.1,
                        // height: global.SizeConfig.screenWidth * 0.1,
                        imageUrl: thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CupertinoActivityIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection:Axis.horizontal,
                            child: Text(
                              '${title}',
                              style: TextStyle(
                                fontSize: global.SizeConfig.screenHeight * 0.025,
                                color: CupertinoColors.systemGrey4,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${artist}',
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
                    padding: EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemPurple.withValues(
                                  alpha: 0.5,
                                ),
                                // shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(
                                  global.SizeConfig.screenWidth * 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: HugeIcon(
                                  icon: _isSongPlaying
                                      ? HugeIcons.strokeRoundedPlay
                                      : HugeIcons.strokeRoundedPause,
                                  color: CupertinoColors.lightBackgroundGray,
                                  size: global.SizeConfig.screenWidth * 0.065,
                                ),
                              ),
                            ),
                            onTap: () {
                              if (player.playing) {
                                player.pause();
                                setState(() {
                                  _isSongPlaying = !_isSongPlaying;
                                });
                                print('$_surl');
                                print('${player.playing}');
                              } else {
                                player.play();
                                setState(() {
                                  _isSongPlaying = !_isSongPlaying;
                                });
                                print('$_surl');
                                print('${artist}');
                                print('${title}');
                                print('$audioUrl');
                                print('${thumbnailUrl}');
                                print('${player.playing}');
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemPurple.withValues(
                                  alpha: 0.5,
                                ),
                                // shape: BoxShape.circle,
                                borderRadius: BorderRadius.circular(
                                  global.SizeConfig.screenWidth * 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: HugeIcon(
                                  icon: _isDeviceMute
                                      ? HugeIcons.strokeRoundedHeadset
                                      : HugeIcons.strokeRoundedHeadsetOff,
                                  color: CupertinoColors.lightBackgroundGray,
                                  size: global.SizeConfig.screenWidth * 0.065,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _isDeviceMute = !_isDeviceMute;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//it will show
// -Quotesflipcard
// -song plays
// -reply leave your feeling
// - love ur unoved the quote
