// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:just_audio/just_audio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pikanda/frontend/quote_screen.dart';
// import 'package:pikanda/utilities/globalvar.dart' as global;
// import 'package:hugeicons/hugeicons.dart';
// import 'package:pikanda/frontend/quote_screen.dart';
// import 'package:youtube_explode_dart/youtube_explode_dart.dart';
//
// class SongWidget extends StatefulWidget {
//   String sUrl;
//   SongWidget({Key? key, this.sUrl =''});
//   @override
//   State<SongWidget> createState() => _SongWidgetState();
// }
//
// class _SongWidgetState extends State<SongWidget> {
//   bool _isSongPlaying = true;
//   bool _isDeviceMute = false;
//   final player = AudioPlayer();
//   String myTitle =  'sUrl';
//   String? title;
//   String? artist;
//   File? thumbnailFile;
//   bool loading = true;
//   String? error;
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
//     final yt = YoutubeExplode();
//     try {
//       final video = await yt.videos.get(myTitle);
//       final videoTitle = video.title;
//       final videoArtist = video.author;
//       final thumbUrl = video.thumbnails.highResUrl;
//
//       // Download the thumbnail to a temp file
//       final tempDir = await getTemporaryDirectory();
//       final thumbResponse = await http.get(Uri.parse(thumbUrl));
//       final thumbPath = '${tempDir.path}/${video.id.value}_thumb.jpg';
//       final file = File(thumbPath);
//       await file.writeAsBytes(thumbResponse.bodyBytes);
//
//       setState(() {
//         title = videoTitle;
//         artist = videoArtist;
//         thumbnailFile = file;
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
//   void initstate() {
//     player.setUrl('');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(10.0),
//       child: Container(
//         // height: global.SizeConfig.screenHeight*0.11
//         width: double.maxFinite,
//         decoration: BoxDecoration(
//           color: CupertinoColors.black,
//           borderRadius: BorderRadius.circular(25),
//         ),
//         child: Padding(
//           padding: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(color: CupertinoColors.black),
//                         borderRadius: BorderRadius.circular(25),
//                         color: CupertinoColors.white,
//                       ),
//
//                       child: Image(
//                         image: AssetImage('assets/images/icon.png'),
//                         height: global.SizeConfig.screenHeight * 0.07,
//                         fit: BoxFit.fill,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(5.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${global.song}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.0256,
//                             color: CupertinoColors.systemGrey4,
//                           ),
//                         ),
//                         Text(
//                           '${global.artist}',
//                           style: TextStyle(
//                             fontSize: global.SizeConfig.screenHeight * 0.022,
//                             color: CupertinoColors.systemGrey2,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Spacer(),
//                   Padding(
//                     padding: EdgeInsets.all(5.0),
//                     child: Row(
//                       children: [
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
//                                   icon: _isSongPlaying
//                                       ? HugeIcons.strokeRoundedPlay
//                                       : HugeIcons.strokeRoundedPause,
//                                   color: CupertinoColors.lightBackgroundGray,
//                                   size: global.SizeConfig.screenWidth * 0.065,
//                                 ),
//                               ),
//                             ),
//                             onTap: () {
//                               if (player.playing) {
//                                 player.pause();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$myTitle');
//                                 print('${SongWidget().sUrl}');
//                                 print('${player.playing}');
//                               } else {
//                                 player.play();
//                                 setState(() {
//                                   _isSongPlaying = !_isSongPlaying;
//                                 });
//                                 print('$myTitle');
//                                 print('${SongWidget().sUrl}');
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
//                                   color: CupertinoColors.lightBackgroundGray,
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
//               LinearProgressIndicator(
//                 borderRadius: BorderRadius.circular(55),
//                 value: 0.5,
//                 backgroundColor: CupertinoColors.systemRed,
//                 color: CupertinoColors.systemYellow,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
