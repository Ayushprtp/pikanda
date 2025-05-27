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
      // 'https://www.youtube.com/watch?v=VuG7ge_8I2Y';
      // 'https://youtu.be/E9zWVQypoSM?si=okOOTKDudYr8hli5';
      'https://youtu.be/0RHjkD-htWQ?si=kKn_NCIBjErZtQuH';
      // 'https://youtu.be/fWQpb6T89d4?si=GegMKgy3RjyMvTWw';
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
  bool _isSongPlaying = false;
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
    return (match != null && match.group(2)!.length == 11) ? match.group(2) : null;
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
      final manifest = await yt.videos.streamsClient.getManifest(VideoId(videoId));

      // Get best audio stream (M4A first, then fallback)
      final audioStreams = manifest.audioOnly;
      final m4aStreams = audioStreams
          .where((s) => s.container == 'm4a')
          .toList()
        ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

      final audioStream = m4aStreams.isNotEmpty
          ? m4aStreams.first
          : audioStreams.withHighestBitrate();

      await player.setUrl(audioStream.url.toString());

      setState(() {
        title = video.title.split(' - ').first;
        artist = video.author;
        thumbnailUrl = video.thumbnails.mediumResUrl;
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
        height: global.SizeConfig.screenHeight * 0.1,
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: CupertinoColors.black,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemRed.withAlpha(1),
              blurRadius: 8,
              spreadRadius: 1,
            )
          ],
        ),
        child: loading
            ? Center(
          child: CupertinoActivityIndicator(
            radius: global.SizeConfig.screenHeight * 0.02,
          ),
        )
            : error != null
            ? Center(
          child: Text(
            error!,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        )
            : Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: thumbnailUrl!,
                  width: global.SizeConfig.screenWidth * 0.15,
                  height: global.SizeConfig.screenWidth * 0.15,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CupertinoActivityIndicator(
                        radius: global.SizeConfig.screenWidth * 0.02,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.music_note),
                ),
              ),

              const SizedBox(width: 10),

              // Title & Artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title ?? 'Unknown Title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      artist ?? 'Unknown Artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Playback Controls
              StreamBuilder<PlayerState>(
                stream: player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final isPlaying = playerState?.playing ?? false;

                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () async {
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
                      IconButton(
                        icon: Icon(
                          _isDeviceMute
                              ? Icons.volume_off_rounded
                              : Icons.volume_up_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          setState(() {
                            _isDeviceMute = !_isDeviceMute;
                          });
                          player.setVolume(_isDeviceMute ? 0.0 : 1.0);
                        },
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
//
// class SongWidget extends StatefulWidget {
//   late String sUrl = _SongWidgetState()._surl;
//   SongWidget({Key? key, required this.sUrl});
//   @override
//   State<SongWidget> createState() => _SongWidgetState();
// }
//
// class _SongWidgetState extends State<SongWidget> {
//   bool _isSongPlaying = false;
//   bool _isDeviceMute = false;
//   final player = AudioPlayer();
//   String _surl = _QuoteScreenState()._sUrl;
//
//   String? title;
//   String? artist;
//   String? audioUrl;
//   String? thumbnailUrl;
//   Duration? duration;
//   bool loading = true;
//   String? error;
//   final yt = YoutubeExplode();
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMeta();
//   }
//
//   Future<void> fetchMeta() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     try {
//       final song = await yt.videos.get(_surl);
//       final manifest = await yt.videos.streamsClient.getManifest(_surl);
//
//       // Filter for m4a (audio/mp4) streams
//       final m4aStreams = manifest.audioOnly
//           .where((s) => s.codec.mimeType == 'audio/m4a')
//           .toList();
//
//       String? directUrl;
//       if (m4aStreams.isNotEmpty) {
//         // Take the highest bitrate m4a stream
//         m4aStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
//         directUrl = m4aStreams.first.url.toString();
//       }
//
//       setState(() {
//         title = song.title;
//         artist = song.author;
//         thumbnailUrl = song.thumbnails.highResUrl;
//         audioUrl = directUrl; // <-- this is your direct m4a audio link
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         loading = false;
//       });
//     } finally {
//       yt.close();
//     }
//   }
//
//   @override
//   void initstate() {
//     player.setUrl('$audioUrl');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Container(
//         height: global.SizeConfig.screenHeight*0.1,
//         width: double.maxFinite,
//         decoration: BoxDecoration(
//           color: CupertinoColors.black,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//           child: loading? Center(child: CupertinoActivityIndicator(
//             radius: global.SizeConfig.screenHeight*0.02,
//           )):
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//                   Padding(
//                     padding: EdgeInsets.only(left: 5.0),
//                     child: ClipRRect(
//
//                       borderRadius: BorderRadius.circular(25),
//                       child: Container(
//                         width: global.SizeConfig.screenWidth * 0.15,
//                         height: global.SizeConfig.screenWidth * 0.15,
//                         decoration: BoxDecoration(
//
//                           border: Border.all(color: CupertinoColors.black),
//                           borderRadius: BorderRadius.circular(25),
//                           color: CupertinoColors.white,
//                         ),
//                         child: CachedNetworkImage(
//                           // width: global.SizeConfig.screenWidth * 0.1,
//                           // height: global.SizeConfig.screenWidth * 0.1,
//                           imageUrl: thumbnailUrl!,
//                           fit: BoxFit.cover,
//                           // color: CupertinoColors.black,
//                           placeholder: (context, url) =>
//                               const Center(child: CupertinoActivityIndicator()),
//                           errorWidget: (context, url, error) =>
//                               const Center(child: Icon(Icons.error)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//
//                           child: Text(
//                           '${title}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.009,
//                             color: CupertinoColors.white,
//                           ),
//                         ),),
//                         Text(
//                           '${artist}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.02,
//                             color: CupertinoColors.white.withAlpha(150),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Spacer(),
//                   Padding(
//                     padding: EdgeInsets.all(5.0),
//                     child: Row(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(right: 10.0),
//                           child: GestureDetector(
//                             child: MorphedContainer(
//                               borderRadius: BorderRadius.all( Radius.circular(global.SizeConfig.screenWidth * 1,
//                               )),
//                               color: CupertinoColors.destructiveRed,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(5.0),
//                                   child: HugeIcon(
//                                     icon: _isSongPlaying
//                                         ? HugeIcons.strokeRoundedPlay
//                                         : HugeIcons.strokeRoundedPause,
//                                     color: CupertinoColors.white,
//                                     size: global.SizeConfig.screenWidth * 0.065,
//                                   ),
//                                 ),
//                               ),
//                             onTap: () {
//                               if (player.playing) {
//                                 player.pause();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$_surl');
//                                 print('${player.playing}');
//                               } else {
//                                 player.play();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$_surl');
//                                 print('${artist}');
//                                 print('${title}');
//                                 print('$audioUrl');
//                                 print('${thumbnailUrl}');
//                                 print('${player.playing}');
//                               }
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: GestureDetector(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: CupertinoColors.systemPurple.withValues(
//                                   alpha: 0.5,
//                                 ),
//                                 // shape: BoxShape.circle,
//                                 borderRadius: BorderRadius.circular(
//                                   global.SizeConfig.screenWidth * 1,
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: HugeIcon(
//                                   icon: _isDeviceMute
//                                       ? HugeIcons.strokeRoundedHeadset
//                                       : HugeIcons.strokeRoundedHeadsetOff,
//                                   color: CupertinoColors.white,
//                                   size: global.SizeConfig.screenWidth * 0.065,
//                                 ),
//                               ),
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 _isDeviceMute = !_isDeviceMute;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//it will show
// -Quotesflipcard
// -song plays
// -reply leave your feeling
// - love ur unoved the quote


// class SongWidget extends StatefulWidget {
//   late String sUrl = _SongWidgetState()._surl;
//   SongWidget({Key? key, required this.sUrl});
//   @override
//   State<SongWidget> createState() => _SongWidgetState();
// }
//
// class _SongWidgetState extends State<SongWidget> {
//   bool _isSongPlaying = false;
//   bool _isDeviceMute = false;
//   final player = AudioPlayer();
//   String _surl = _QuoteScreenState()._sUrl;
//
//   String? title;
//   String? artist;
//   String? audioUrl;
//   String? thumbnailUrl;
//   bool loading = true;
//   String? error;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMeta();
//   }
//   Future<void> fetchMeta() async {
//     setState(() {
//       loading = true;
//       error = null;
//     });
//     final yt = YoutubeExplode();
//     try {
//       final song = await yt.videos.get(_surl);
//       final manifest = await yt.videos.streamsClient.getManifest(_surl);
//
//       // Filter for m4a (audio/mp4) streams
//       final m4aStreams = manifest.audioOnly
//           .where((s) => s.codec.mimeType == 'audio/mp4')
//           .toList();
//
//       String? directUrl;
//       if (m4aStreams.isNotEmpty) {
//         // Take the highest bitrate m4a stream
//         m4aStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
//         directUrl = m4aStreams.first.url.toString();
//       }
//
//       setState(() {
//         title = song.title;
//         artist = song.author;
//         thumbnailUrl = song.thumbnails.highResUrl;
//         audioUrl = directUrl; // <-- this is your direct m4a audio link
//         loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         error = e.toString();
//         loading = false;
//       });
//     } finally {
//       yt.close();
//     }
//   }
//
//   @override
//   void initstate() {
//     player.setUrl('$audioUrl');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Container(
//         height: global.SizeConfig.screenHeight*0.1,
//         width: double.maxFinite,
//         decoration: BoxDecoration(
//           color: CupertinoColors.black,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//           child: loading? Center(child: CupertinoActivityIndicator(
//             radius: global.SizeConfig.screenHeight*0.02,
//           )):
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//                   Padding(
//                     padding: EdgeInsets.only(left: 5.0),
//                     child: ClipRRect(
//
//                       borderRadius: BorderRadius.circular(25),
//                       child: Container(
//                         width: global.SizeConfig.screenWidth * 0.15,
//                         height: global.SizeConfig.screenWidth * 0.15,
//                         decoration: BoxDecoration(
//
//                           border: Border.all(color: CupertinoColors.black),
//                           borderRadius: BorderRadius.circular(25),
//                           color: CupertinoColors.white,
//                         ),
//                         child: CachedNetworkImage(
//                           // width: global.SizeConfig.screenWidth * 0.1,
//                           // height: global.SizeConfig.screenWidth * 0.1,
//                           imageUrl: thumbnailUrl!,
//                           fit: BoxFit.fitHeight,
//                           // color: CupertinoColors.black,
//                           placeholder: (context, url) =>
//                               const Center(child: CupertinoActivityIndicator()),
//                           errorWidget: (context, url, error) =>
//                               const Center(child: Icon(Icons.error)),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           child: Text(
//                             'This is a very long text that exceeds the horizontal space of the screen and can be scrolled.',
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                         SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//
//                           child: Text(
//                           '${title}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.005,
//                             color: CupertinoColors.white,
//                           ),
//                         ),),
//                         Text(
//                           '${artist}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.02,
//                             color: CupertinoColors.white.withAlpha(150),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Spacer(),
//                   Padding(
//                     padding: EdgeInsets.all(5.0),
//                     child: Row(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(right: 10.0),
//                           child: GestureDetector(
//                             child: MorphedContainer(
//                               borderRadius: BorderRadius.all( Radius.circular(global.SizeConfig.screenWidth * 1,
//                               )),
//                               color: CupertinoColors.destructiveRed,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(5.0),
//                                   child: HugeIcon(
//                                     icon: _isSongPlaying
//                                         ? HugeIcons.strokeRoundedPlay
//                                         : HugeIcons.strokeRoundedPause,
//                                     color: CupertinoColors.white,
//                                     size: global.SizeConfig.screenWidth * 0.065,
//                                   ),
//                                 ),
//                               ),
//                             onTap: () {
//                               if (player.playing) {
//                                 player.pause();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$_surl');
//                                 print('${player.playing}');
//                               } else {
//                                 player.play();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$_surl');
//                                 print('${artist}');
//                                 print('${title}');
//                                 print('$audioUrl');
//                                 print('${thumbnailUrl}');
//                                 print('${player.playing}');
//                               }
//                             },
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.all(10.0),
//                           child: GestureDetector(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: CupertinoColors.systemPurple.withValues(
//                                   alpha: 0.5,
//                                 ),
//                                 // shape: BoxShape.circle,
//                                 borderRadius: BorderRadius.circular(
//                                   global.SizeConfig.screenWidth * 1,
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(5.0),
//                                 child: HugeIcon(
//                                   icon: _isDeviceMute
//                                       ? HugeIcons.strokeRoundedHeadset
//                                       : HugeIcons.strokeRoundedHeadsetOff,
//                                   color: CupertinoColors.white,
//                                   size: global.SizeConfig.screenWidth * 0.065,
//                                 ),
//                               ),
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 _isDeviceMute = !_isDeviceMute;
//                               });
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//it will show
// -Quotesflipcard
// -song plays
// -reply leave your feeling
// - love ur unoved the quote
