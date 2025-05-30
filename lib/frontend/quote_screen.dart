
  import 'dart:io';

  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'package:path_provider/path_provider.dart';
  import 'package:pikanda/frontend/customwidgets.dart';
  import 'package:pikanda/frontend/home_screen.dart';
  import 'package:pikanda/utilities/bg.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:pikanda/frontend/quote_widget.dart';
  import 'package:pikanda/frontend/song_widget.dart';
  import 'package:pikanda/utilities/globalvar.dart' as global;
  import 'package:hugeicons/hugeicons.dart';
  import 'package:pikanda/utilities/morphsimcontainer.dart';
  import 'package:just_audio/just_audio.dart';
  import 'package:youtube_explode_dart/youtube_explode_dart.dart';
  import 'package:audio_service/audio_service.dart';

  class QuoteScreen extends StatefulWidget {
  QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
  }

  class _QuoteScreenState extends State<QuoteScreen> {
  late String _sUrl =
  // 'https://www.youtube.com/watch?v=VuG7ge_8I2Y';
  // 'https://youtu.be/E9zWVQypoSM?si=okOOTKDudYr8hli5';
  // 'https://youtu.be/0RHjkD-htWQ?si=kKn_NCIBjErZtQuH';
  //     'https://youtu.be/fWQpb6T89d4?si=GegMKgy3RjyMvTWw';
  // 'https://music.youtube.com/watch?v=gZ0vHQKfNH8&si=6vcVbUSFrqNxsWch';
  // 'https://music.youtube.com/watch?v=_9FyH8PmRSU&si=HZdrsG380n2PjIsM';
  // 'https://youtu.be/eWf-mx0_NKU?si=zfNdeRAjITK-lVN6';
  // 'https://music.youtube.com/watch?v=kYtGl1Ge5pg';
  // 'https://music.youtube.com/watch?v=qCDPprTDkJE&si=ablFNaMEuAxkogwD';
  //     'https://music.youtube.com/watch?v=dQw4w9WgXcQ';
  // 'https://www.youtube.com/watch?v=jDzgpibEJPc';
  'https://music.youtube.com/watch?v=dQw4w9WgXcQ'; // Your URL

  final FocusNode _urlFocusNode = FocusNode();
  String? _currentUrl;

  // NEW: Create a GlobalKey for the SongWidget's state
  final GlobalKey<_SongWidgetState> _songWidgetKey = GlobalKey();

  @override
  void dispose() {
  // NEW: Call the stopMusic method on the SongWidget's state when QuoteScreen is disposed
  _songWidgetKey.currentState?.stopMusic();
  super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return BgMaterial(
  leading: Navigator.canPop(context)
  ? CupertinoNavigationBarBackButton(
  onPressed: () {
  // Ensure we pop the route.
  Navigator.pop(context);
  },
  )
      : null,
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
  // NEW: Assign the key to the SongWidget
  bottomWidget: SongWidget(key: _songWidgetKey, sUrl: _sUrl),
  child: Column(
  children: [
  Spacer(),
  Align(alignment: Alignment.center, child: QuoteWidget()),
  Spacer(),
  Response(),
  ],
  ),
  );
  }
  }

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
  color: CupertinoColors.darkBackgroundGray.withOpacity(0.5),
  border: Border.all(
  color: CupertinoColors.systemGrey,
  ),
  borderRadius: BorderRadius.circular(25),
  ),
  controller: _response,
  maxLines: 8,
  ),
  ),
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
  bool _isDeviceMute = false;
  double _previousVolume = 0.5;
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

  // OPTIONAL: Listen to the player's volume changes to update _previousVolume
  player.volumeStream.listen((volume) {
  if (!_isDeviceMute) {
  _previousVolume = volume;
  }
  });
  }

  // NEW: Add a public method to stop the music in SongWidget's state
  Future<void> stopMusic() async {
  await player.stop();
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

  // Fetch video metadata and manifest in parallel
  final results = await Future.wait([
  yt.videos.get(VideoId(videoId)),
  yt.videos.streamsClient.getManifest(VideoId(videoId)),
  ]);

  final video = results[0] as Video;
  final manifest = results[1] as StreamManifest;

  final audioStreams = manifest.audioOnly;
  // ... rest of your stream filtering logic ...
  final m4aStreams =
  audioStreams.where((s) => s.container == 'm4a').toList()
  ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

  final AudioStreamInfo audioStream;

  if (m4aStreams.isNotEmpty) {
  audioStream = m4aStreams.first;
  } else {
  if (audioStreams.isNotEmpty) {
  audioStream = audioStreams.withHighestBitrate();
  } else {
  throw Exception('No audio streams found for this video.');
  }
  }

  setState(() {
  title = video.title.split(' - ').first;
  artist = video.author;
  thumbnailUrl = video.thumbnails.mediumResUrl;
  audioUrl = audioStream.url.toString();
  loading = false;
  });

  // Only set the URL if it's actually loaded and not an error
  await player.setUrl(audioUrl.toString());
  await player.play(); // NEW: Start playing automatically when loaded

  } catch (e) {
  setState(() {
  error = e.toString();
  loading = false;
  });
  }
  }

  @override
  void dispose() {
  player.dispose(); // Dispose the player when SongWidget is removed
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
  color: CupertinoColors.black.withAlpha(100),
  blurRadius: 25,
  spreadRadius: 1,
  blurStyle: BlurStyle.normal,
  ),
  ],
  ),
  child: loading
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
  child: Container(
  decoration: BoxDecoration(
  shape: BoxShape.rectangle,
  color: CupertinoColors.destructiveRed,
  image: DecorationImage(
  image: NetworkImage(thumbnailUrl!),
  filterQuality: FilterQuality.high,
  fit: BoxFit.cover,
  ),
  ),
  width: global.SizeConfig.screenWidth * 0.13,
  height: global.SizeConfig.screenWidth * 0.13,
  ),
  ),

  // Title & Artist
  Expanded(
  child: Padding(
  padding:
  const EdgeInsets.symmetric(horizontal: 10.0),
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  title ?? 'Unknown Title',
  maxLines: 1,
  overflow: TextOverflow.fade,
  style: TextStyle(
  fontSize: global.SizeConfig.screenHeight *
  0.023,
  color: CupertinoColors.systemGrey4,
  ),
  ),
  Text(
  artist ?? 'Unknown Artist',
  maxLines: 1,
  overflow: TextOverflow.ellipsis,
  style: TextStyle(
  fontSize: global.SizeConfig.screenHeight *
  0.017,
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
  // Default to false if no data yet, to avoid initial play button showing pause
  final isPlaying = playerState?.playing ?? false;

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
  color:
  CupertinoColors.systemPurple.withOpacity(0.6),
  child: Padding(
  padding: EdgeInsets.all(1.0),
  child: Center(
  child: HugeIcon(
  icon: isPlaying
  ? HugeIcons.strokeRoundedPause
      : HugeIcons.strokeRoundedPlay,
  color: CupertinoColors.white,
  size: global.SizeConfig.screenWidth *
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
  color:
  CupertinoColors.systemPurple.withOpacity(0.6),
  child: Padding(
  padding: EdgeInsets.all(1.0),
  child: Center(
  child: _isDeviceMute
  ? HugeIcon(
  icon: HugeIcons
      .strokeRoundedHeadsetOff,
  color:
  CupertinoColors.destructiveRed,
  size: global.SizeConfig.screenWidth *
  0.06,
  )
      : HugeIcon(
  icon:
  HugeIcons.strokeRoundedHeadset,
  color: CupertinoColors.systemGreen,
  size: global.SizeConfig.screenWidth *
  0.06,
  ),
  ),
  ),
  ),
  onTap: () async {
  setState(() {
  _isDeviceMute = !_isDeviceMute;
  });

  if (_isDeviceMute) {
  _previousVolume = player.volume;
  await player.setVolume(0.0);
  } else {
  await player.setVolume(_previousVolume);
  }
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
