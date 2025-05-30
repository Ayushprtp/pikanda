// lib/frontend/quote_widget.dart (or wherever your SongWidget is located)

import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pikanda/frontend/quote_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart'; // <<< ADD THIS IMPORT
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Temporarily REMOVE: import 'package:pikanda/backend/music_services.dart'; // Temporarily comment out for testing

// Assuming these are defined globally or in a utility file
import '../utilities/bg.dart';
import '../utilities/globalvar.dart' as global;
import '../utilities/morphsimcontainer.dart';

// --- Constants and Custom Cache Manager (Keep as is) ---
class CustomCacheManager extends CacheManager {
  static const key = 'customAudioCache';
  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }

  CustomCacheManager._()
      : super(
    Config(
      key,
      stalePeriod: const Duration(hours: 24),
      maxNrOfCacheObjects: 100,
    ),
  );
}

// Custom URL parser (Keep as is)
class CustomUrlParser {
  static String? extractVideoId(String url) {
    final regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:m\.)?(?:music\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=|embed\/|v\/|shorts\/|e\/|clip\/|playlist\?list=|live\/)?([a-zA-Z0-9_-]{11})(?:\S+)?$',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.group(1) != null && match.group(1)!.length == 11) {
      return match.group(1);
    }
    return null;
  }
}

// --- QuoteScreen (Keep as is, update the _sUrl example) ---
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}


class _QuoteScreenState extends State<QuoteScreen> {
  final String _sUrl = 'https://youtu.be/1GRVh1u3ME4?si=lPxwk7c1m9OHmyGr';

  final GlobalKey<_SongWidgetState> _songWidgetKey = GlobalKey();

  @override
  void dispose() {
    _songWidgetKey.currentState?.stopMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BgMaterial(
      leading: Navigator.canPop(context)
          ? CupertinoNavigationBarBackButton(
        onPressed: () {
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
      bottomWidget: SongWidget(
        key: _songWidgetKey,
        sUrl: _sUrl,
        onPlaybackStatusChanged: (isPlaying) {
          debugPrint('Song playback status: $isPlaying');
        },
      ),
      child: const Column(
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
                style: const TextStyle(
                  fontFamily: 'SF',
                  fontSize: 16,
                  fontStyle: FontStyle.normal,
                ),
                autocorrect: true,
                minLines: 1,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                onChanged: (value) => setState(() {}),
                placeholder: "Express Your Feelingsss..!!",
                decoration: BoxDecoration(
                  color: CupertinoColors.darkBackgroundGray.withAlpha(50),
                  border: Border.all(color: CupertinoColors.systemGrey),
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

// --- SongWidget Class (Updated to use YoutubeExplode) ---

class SongWidget extends StatefulWidget {
  final String sUrl;
  final Duration? initialPosition;
  final Function(bool isPlaying)? onPlaybackStatusChanged;

  const SongWidget({
    Key? key,
    required this.sUrl,
    this.initialPosition,
    this.onPlaybackStatusChanged,
  }) : super(key: key);

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  late AudioPlayer _player;
  late YoutubeExplode _ytExplode; // <<< Use YoutubeExplode directly

  bool _isDeviceMute = false;
  double _previousVolume = 0.5;
  String? title;
  String? artist;
  String? thumbnailUrl;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _ytExplode = YoutubeExplode(); // <<< Initialize YoutubeExplode

    _initPlayerListeners();
    fetchAndPlayMeta();
  }

  void _initPlayerListeners() {
    _player.volumeStream.listen((volume) {
      if (!_isDeviceMute) {
        _previousVolume = volume;
      }
    });

    _player.playerStateStream.listen((playerState) {
      widget.onPlaybackStatusChanged?.call(playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.play();
      }
    });
  }

  Future<void> stopMusic() async {
    await _player.stop();
  }

  Future<void> fetchAndPlayMeta() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final videoId = CustomUrlParser.extractVideoId(widget.sUrl);
      if (videoId == null) {
        throw Exception('Invalid YouTube URL provided: ${widget.sUrl}');
      }

      // --- Use YoutubeExplode to get video and stream info ---
      final Video video = await _ytExplode.videos.get(videoId);
      final StreamManifest manifest = await _ytExplode.videos.streamsClient.getManifest(videoId);

      setState(() {
        title = video.title;
        artist = video.author;
        thumbnailUrl = video.thumbnails.highResUrl; // Or other resolutions
        loading = false;
      });

      // Find the best audio-only stream
      final AudioStreamInfo? audioStream = manifest.audioOnly.where((s) => s.codec == 'opus').sortByBitrate().lastOrNull;

      if (audioStream == null) {
        throw Exception('No suitable audio stream found for this video.');
      }

      // Get the stream URL
      final String streamUrl = audioStream.url.toString(); // Convert Uri to String

      debugPrint('Attempting to play stream from YoutubeExplode: $streamUrl');

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: MediaItem(
            id: videoId,
            title: title ?? 'Unknown Title',
            artist: artist ?? 'Unknown Artist',
            artUri: Uri.parse(thumbnailUrl ?? ''),
          ),
        ),
        initialPosition: widget.initialPosition ?? Duration.zero,
      );

      await _player.play();
    } catch (e) {
      debugPrint('Error fetching metadata or playing audio with YoutubeExplode: $e');
      setState(() {
        error = 'Failed to load song: ${e.toString().split(':').last.trim()}';
        loading = false;
      });
    }
  }

  Widget _buildCachedThumbnail() {
    if (thumbnailUrl == null || thumbnailUrl!.isEmpty) {
      return const CupertinoActivityIndicator();
    }
    return FutureBuilder<File>(
      future: CustomCacheManager().getSingleFile(thumbnailUrl!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Image.file(snapshot.data!, fit: BoxFit.cover, filterQuality: FilterQuality.high);
        } else if (snapshot.hasError) {
          debugPrint('Error loading cached thumbnail: ${snapshot.error}');
          return const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: CupertinoColors.systemRed);
        }
        return const CupertinoActivityIndicator();
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _ytExplode.close(); // <<< Close YoutubeExplode instance
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
            ? Center(child: Text(error!, style: const TextStyle(fontSize: 12, color: CupertinoColors.systemRed)))
            : Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: global.SizeConfig.screenWidth * 0.13,
                  height: global.SizeConfig.screenWidth * 0.13,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: CupertinoColors.destructiveRed,
                  ),
                  child: _buildCachedThumbnail(),
                ),
              ),

              // Title & Artist
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? 'Unknown Title',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: global.SizeConfig.screenHeight * 0.023,
                          color: CupertinoColors.systemGrey4,
                        ),
                      ),
                      Text(
                        artist ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: global.SizeConfig.screenHeight * 0.017,
                          color: CupertinoColors.systemGrey2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Playback Controls
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final isPlaying = playerState?.playing ?? false;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: GestureDetector(
                          child: MorphedContainer(
                            height: global.SizeConfig.screenWidth * 0.09,
                            width: global.SizeConfig.screenWidth * 0.09,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                global.SizeConfig.screenWidth * 1,
                              ),
                            ),
                            color: CupertinoColors.systemPurple.withOpacity(0.6),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Center(
                                child: HugeIcon(
                                  icon: isPlaying ? HugeIcons.strokeRoundedPause : HugeIcons.strokeRoundedPlay,
                                  color: CupertinoColors.white,
                                  size: global.SizeConfig.screenWidth * 0.06,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (isPlaying) {
                              await _player.pause();
                            } else {
                              await _player.play();
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: GestureDetector(
                          child: MorphedContainer(
                            height: global.SizeConfig.screenWidth * 0.09,
                            width: global.SizeConfig.screenWidth * 0.09,
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                global.SizeConfig.screenWidth * 1,
                              ),
                            ),
                            color: CupertinoColors.systemPurple.withOpacity(0.6),
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Center(
                                child: _isDeviceMute
                                    ? HugeIcon(
                                  icon: HugeIcons.strokeRoundedHeadsetOff,
                                  color: CupertinoColors.destructiveRed,
                                  size: global.SizeConfig.screenWidth * 0.06,
                                )
                                    : HugeIcon(
                                  icon: HugeIcons.strokeRoundedHeadset,
                                  color: CupertinoColors.systemGreen,
                                  size: global.SizeConfig.screenWidth * 0.06,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            setState(() {
                              _isDeviceMute = !_isDeviceMute;
                            });

                            if (_isDeviceMute) {
                              _previousVolume = _player.volume;
                              await _player.setVolume(0.0);
                            } else {
                              await _player.setVolume(_previousVolume);
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