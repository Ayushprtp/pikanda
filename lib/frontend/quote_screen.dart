// lib/frontend/quote_widget.dart (or wherever your SongWidget is located)

import 'dart:ffi';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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


// --- QuoteScreen (Keep as is, update the _sUrl example) ---
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}


class _QuoteScreenState extends State<QuoteScreen> {
  final String _sUrl =
      // _ResponseState()._response.text;
      // 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
  'https://youtu.be/eWf-mx0_NKU?si=0NpcyIPrziiUhaX9';

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
        previousPageTitle: 'Home',
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
        startPosition: Duration(seconds: 30),
        endPosition: Duration(seconds: 90),
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
class SongWidget extends StatefulWidget {
  final String sUrl;
  final Duration? initialPosition;
  final Duration? startPosition;
  final Duration? endPosition;
  final Function(bool isPlaying)? onPlaybackStatusChanged;

  const SongWidget({
    Key? key,
    required this.sUrl,
    this.initialPosition,
    this.startPosition,
    this.endPosition,
    this.onPlaybackStatusChanged,
  }) : super(key: key);

  @override
  State<SongWidget> createState() => _SongWidgetState();
}

class _SongWidgetState extends State<SongWidget> {
  late AudioPlayer _player;
  late YoutubeExplode _ytExplode;

  bool _isDeviceMute = false;
  double _previousVolume = 0.5;
  String? title;
  String? artist;
  String? thumbnailUrl;
  bool loading = true;
  String? error;
  Duration? _start;
  Duration? _end;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _ytExplode = YoutubeExplode();

    _initPlayerListeners();
    fetchAndPlayMeta();
  }

  void _initPlayerListeners() {
    _player.volumeStream.listen((volume) {
      if (!_isDeviceMute) {
        _previousVolume = volume;
      }
    });

    // Loop between start and end
    _player.positionStream.listen((position) {
      if (_start != null && _end != null && _end! > _start!) {
        if (position >= _end!) {
          _player.seek(_start!);
          _player.play();
        }
      }
    });

    _player.playerStateStream.listen((playerState) {
      widget.onPlaybackStatusChanged?.call(playerState.playing);
    });
  }

  Future<void> stopMusic() async {
    await _player.stop();
  }

  // Download and cache the full audio file, return File
  Future<File> _getOrDownloadAudioFile(String audioUrl, String audioKey) async {
    final cacheManager = CustomCacheManager();
    final cachedFile = await cacheManager.getFileFromCache(audioKey);

    if (cachedFile != null && cachedFile.file.existsSync()) {
      return cachedFile.file;
    }

    final response = await HttpClient().getUrl(Uri.parse(audioUrl)).then((req) => req.close());
    if (response.statusCode != 200) throw Exception('Audio download failed');

    final bytes = await consolidateHttpClientResponseBytes(response);
    final file = await cacheManager.putFile(audioKey, bytes, fileExtension: 'm4a', maxAge: const Duration(hours: 24));
    return file;
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

      final Video video = await _ytExplode.videos.get(videoId);
      String cleanTitle = video.title;
      if (video.author.isNotEmpty && cleanTitle.contains(' - ')) {
        final parts = cleanTitle.split(' - ');
        cleanTitle = parts.sublist(1).join(' - ');
      }

      final StreamManifest manifest = await _ytExplode.videos.streamsClient.getManifest(videoId);

      setState(() {
        title = cleanTitle;
        artist = video.author;
        thumbnailUrl = video.thumbnails.highResUrl;
        loading = false;
      });

      AudioStreamInfo? audioStream;

      // Prefer m4a as it is more broadly supported by just_audio
      final m4aStreams = manifest.audioOnly.where((s) => s.container.name.toLowerCase() == 'm4a').toList();
      m4aStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      if (m4aStreams.isNotEmpty) {
        audioStream = m4aStreams.first;
      }

      // Fallback to opus
      if (audioStream == null) {
        final opusStreams = manifest.audioOnly.where((s) => s.codec.toString().toLowerCase() == 'opus').toList();
        opusStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        if (opusStreams.isNotEmpty) {
          audioStream = opusStreams.first;
        }
      }

      // Fallback to any audio
      if (audioStream == null && manifest.audioOnly.isNotEmpty) {
        final allStreams = manifest.audioOnly.toList();
        allStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        audioStream = allStreams.first;
      }

      if (audioStream == null) {
        throw Exception('No suitable audio stream found for this video.');
      }

      final String streamUrl = audioStream.url.toString();

      // Determine start and end for looping
      final Duration fullDuration = video.duration ?? Duration.zero;
      _start = widget.startPosition ?? Duration.zero;
      _end = widget.endPosition ?? fullDuration;

      // Download and cache the full file, then play from local file
      final audioKey = 'audio_${videoId}';
      final audioFile = await _getOrDownloadAudioFile(streamUrl, audioKey);

      await _player.setAudioSource(
        ClippingAudioSource(
          start: _start!,
          end: _end!,
          child: AudioSource.uri(
            Uri.file(audioFile.path),
            tag: MediaItem(
              id: videoId,
              title: title ?? 'Unknown Title',
              artist: artist ?? 'Unknown Artist',
              artUri: Uri.parse(thumbnailUrl ?? ''),
            ),
          ),
        ),
        initialPosition: widget.initialPosition ?? _start!,
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
          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
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
    _ytExplode.close();
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
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Container(
                  width: global.SizeConfig.screenWidth * 0.125,
                  height: global.SizeConfig.screenWidth * 0.125,
                  decoration: BoxDecoration(
                      color: CupertinoColors.destructiveRed,
                      borderRadius: BorderRadius.circular(20)
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