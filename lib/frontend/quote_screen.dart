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
  late String _sUrl = 'https://www.youtube.com/watch?v=VuG7ge_8I2Y';
  // 'https://youtu.be/E9zWVQypoSM?si=okOOTKDudYr8hli5';
  // 'https://youtu.be/0RHjkD-htWQ?si=kKn_NCIBjErZtQuH';
  //     'https://youtu.be/fWQpb6T89d4?si=GegMKgy3RjyMvTWw';
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
          Spacer(),
          Response(),
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
        child: Row(
          children: [
            Flexible(
              child: CupertinoTextField(
                onTapOutside: (value) {
                  setState(() {});
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                style: TextStyle(
                  fontFamily: 'SF',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
                autocorrect: true,
                minLines: 1,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
            ),
            // HugeIcon(icon: icon, color: color)
          ],
        ),
      ),
    );
  }
}

class SongWidget extends StatefulWidget {
  final String sUrl;
  const SongWidget({Key? key, required this.sUrl}) : super(key: key);

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  late AudioPlayer player;
  late YoutubeExplode yt;
  bool _isSongPlaying = true;
  bool _isDeviceMute = false;
  String? title;
  String? artist;
  String? audioUrl;
  String? thumbnailUrl;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    yt = YoutubeExplode();
    fetchMeta();
  }

  String? _extractVideoId(String url) {
    final regExp = RegExp(
      r'^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=|music\.youtube\.com\/watch\?v=)([^#\&?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return (match != null && match.group(2)!.length == 11)
        ? match.group(2)
        : null;
  }

  Future<void> fetchMeta() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final videoId = _extractVideoId(widget.sUrl);
      if (videoId == null) throw Exception('Invalid YouTube URL');

      final video = await yt.videos.get(VideoId(videoId));
      final manifest = await yt.videos.streamsClient.getManifest(
        VideoId(videoId),
      );

      // Get best audio stream (M4A first, then fallback)
      final audioStreams = manifest.audioOnly;
      final m4aStreams =
          audioStreams.where((s) => s.container == 'm4a').toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

      final audioStream =
          m4aStreams.isNotEmpty
              ? m4aStreams.first
              : audioStreams.withHighestBitrate();

      await player.setUrl(audioStream.url.toString());

      setState(() {
        title = video.title.split(' - ').first;
        artist = video.author;
        thumbnailUrl = video.thumbnails.highResUrl;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: global.SizeConfig.screenHeight * 0.08,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemPurple.withAlpha(100),
              blurRadius: 5,
              spreadRadius: 2,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child:
            loading
                ? Center(
                  child: CupertinoActivityIndicator(
                    radius: global.SizeConfig.screenHeight * 0.02,
                  ),
                )
                : error != null
                ? Center(child: Text(error!, style: TextStyle(fontSize: 12)))
                : Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          filterQuality: FilterQuality.high,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: CupertinoColors.destructiveRed,
                              image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fitHeight
                              ),
                            ),
                          ),
                          imageUrl: thumbnailUrl!,
                          width: global.SizeConfig.screenWidth * 0.13,
                          height: global.SizeConfig.screenWidth * 0.13,
                          fit: BoxFit.fitWidth,
                          placeholder:
                              (context, url) => Container(
                                color: CupertinoColors.systemGrey4,
                                child: Center(
                                  child: CupertinoActivityIndicator(
                                    radius:
                                        global.SizeConfig.screenWidth * 0.02,
                                  ),
                                ),
                              ),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.music_note),
                        ),
                      ),

                      // Title & Artist
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title ?? 'Unknown Title',
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.023,
                                  color: CupertinoColors.systemGrey4,
                                ),
                              ),
                              Text(
                                artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: TextStyle(
                                  fontSize:
                                      global.SizeConfig.screenHeight * 0.017,
                                  color: CupertinoColors.systemGrey2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Playback Controls
                      StreamBuilder<PlayerState>(
                        stream: player.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final isPlaying = playerState?.playing ?? true;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: GestureDetector(
                                  child: MorphedContainer(
                                    height:
                                        global.SizeConfig.screenWidth * 0.09,
                                    width: global.SizeConfig.screenWidth * 0.09,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        global.SizeConfig.screenWidth * 1,
                                      ),
                                    ),
                                    color: CupertinoColors.systemPurple.withAlpha(150),
                                    child: Padding(
                                      padding: EdgeInsets.all(1.0),
                                      child: Center(
                                        child: HugeIcon(
                                          icon:
                                              _isSongPlaying
                                                  ? HugeIcons.strokeRoundedPause
                                                  : HugeIcons
                                                      .strokeRoundedPlay,
                                          color: CupertinoColors.white,
                                          size:
                                              global.SizeConfig.screenWidth *
                                              0.06,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onTap: () async {
                                    if (isPlaying) {
                                      await player.pause();
                                    } else {
                                      await player.play();
                                    }
                                    setState(() {
                                      _isSongPlaying = !_isSongPlaying;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.0),
                                child: GestureDetector(
                                  child: MorphedContainer(
                                    height:
                                    global.SizeConfig.screenWidth * 0.09,
                                    width: global.SizeConfig.screenWidth * 0.09,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        global.SizeConfig.screenWidth * 1,
                                      ),
                                    ),
                                    color: CupertinoColors.systemPurple.withAlpha(150),
                                    child: Padding(
                                      padding: EdgeInsets.all(1.0),
                                      child: Center(
                                        child: _isDeviceMute ? HugeIcon(
                                  icon:  HugeIcons.strokeRoundedHeadsetOff,
                                  color: CupertinoColors.destructiveRed,
                                  size: global.SizeConfig.screenWidth * 0.06,
                                        ):HugeIcon(
                                          icon:  HugeIcons.strokeRoundedHeadset,
                                          color: CupertinoColors.systemGreen,
                                          size: global.SizeConfig.screenWidth * 0.06,
                                        )
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _isDeviceMute = !_isDeviceMute;
                                    });
                                    player.setVolume(_isDeviceMute ? 0.0 : 1.0);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
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
