import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pikanda/frontend/quote_widget.dart';
import 'package:pikanda/frontend/response_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../utilities/bg.dart';
import '../utilities/globalvar.dart' as global;
import '../utilities/morphsimcontainer.dart';

// --- QuoteScreen (UI unchanged) ---
class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final String _sUrl =
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
        startPosition: Duration(seconds: 15),
        endPosition: Duration(seconds: 30),
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



// --- Custom Cache Manager for audio (24h) ---
class CustomCacheManager extends CacheManager {
  static const key = 'customAudioCache';
  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }

  CustomCacheManager._()
      : super(Config(
    key,
    stalePeriod: const Duration(hours: 24),
    maxNrOfCacheObjects: 100,
  ));
}

// --- Robust YouTube/YouTube Music Video ID extraction ---
class CustomUrlParser {
  static String? extractVideoId(String url) {
    final ytMusicReg = RegExp(r'[\?&]v=([a-zA-Z0-9_-]{11})');
    final match1 = ytMusicReg.firstMatch(url);
    if (match1 != null && match1.group(1) != null) return match1.group(1);

    final regExp = RegExp(
      r'^(?:https?:\/\/)?(?:www\.)?(?:m\.)?(?:music\.)?(?:youtube\.com|youtu\.be)\/(?:watch\?v=|embed\/|v\/|shorts\/|e\/|clip\/|playlist\?list=|live\/)?([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match2 = regExp.firstMatch(url);
    if (match2 != null && match2.group(1) != null) return match2.group(1);

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
    _fetchAndPlay();
  }

  void _initPlayerListeners() {
    _player.volumeStream.listen((volume) {
      if (!_isDeviceMute) {
        _previousVolume = volume;
      }
    });

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

  Future<void> _fetchAndPlay() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final videoId = CustomUrlParser.extractVideoId(widget.sUrl);
      if (videoId == null) throw Exception('Invalid YouTube/YouTube Music URL: ${widget.sUrl}');
      final video = await _ytExplode.videos.get(videoId);

      setState(() {
        title = video.title;
        artist = video.author;
        thumbnailUrl = video.thumbnails.highResUrl;
      });

      final manifest = await _ytExplode.videos.streamsClient.getManifest(videoId);

      // --- Select the best available audio stream and set key/extension accordingly ---
      AudioStreamInfo? selectedStream;
      String ext = 'm4a';
      // 1. m4a
      final m4aStreams = manifest.audioOnly.where((s) => s.container.name.toLowerCase() == 'm4a').toList();
      m4aStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
      if (m4aStreams.isNotEmpty) {
        selectedStream = m4aStreams.first;
        ext = 'm4a';
      }
      // 2. opus
      if (selectedStream == null) {
        final opusStreams = manifest.audioOnly.where((s) => s.codec.toString().toLowerCase().contains('opus')).toList();
        opusStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        if (opusStreams.isNotEmpty) {
          selectedStream = opusStreams.first;
          ext = 'opus';
        }
      }
      // 3. webm
      if (selectedStream == null) {
        final webmStreams = manifest.audioOnly.where((s) => s.container.name.toLowerCase() == 'webm').toList();
        webmStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        if (webmStreams.isNotEmpty) {
          selectedStream = webmStreams.first;
          ext = 'webm';
        }
      }
      // 4. any other
      if (selectedStream == null && manifest.audioOnly.isNotEmpty) {
        final allStreams = manifest.audioOnly.toList();
        allStreams.sort((a, b) => b.bitrate.compareTo(a.bitrate));
        selectedStream = allStreams.first;
        ext = selectedStream.container.name.toLowerCase();
      }
      if (selectedStream == null) throw Exception('No suitable audio stream found.');

      final streamUrl = selectedStream.url.toString();
      final audioKey = 'audio_${videoId}_${selectedStream.tag}';

      final cacheManager = CustomCacheManager();
      final cachedFile = await cacheManager.getFileFromCache(audioKey);

      final Duration fullDuration = video.duration ?? Duration.zero;
      _start = widget.startPosition ?? Duration.zero;
      _end = widget.endPosition ?? fullDuration;

      File? playableFile;
      bool isCachedPlayable = false;

      // Try cached file if exists
      if (cachedFile != null && cachedFile.file.existsSync() && cachedFile.file.lengthSync() > 100 * 1024) {
        try {
          await _player.setAudioSource(
            ClippingAudioSource(
              start: _start!,
              end: _end!,
              child: AudioSource.uri(
                Uri.file(cachedFile.file.path),
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
          isCachedPlayable = true;
          playableFile = cachedFile.file;
        } catch (e) {
          debugPrint('Cached file not playable, will stream from CDN: $e');
        }
      }

      // If cache is NOT playable, stream and cache in background
      if (!isCachedPlayable) {
        await _player.setAudioSource(
          ClippingAudioSource(
            start: _start!,
            end: _end!,
            child: AudioSource.uri(
              Uri.parse(streamUrl),
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

        // Background: download/caching
        _downloadAndCacheAudio(streamUrl, audioKey, ext);
      }

      setState(() {
        loading = false;
      });

      await _player.play();
    } catch (e, stk) {
      debugPrint('Error streaming/caching audio: $e\n$stk');
      setState(() {
        error = 'Failed to load song: ${e.toString().split(':').last.trim()}';
        loading = false;
      });
    }
  }

  // Download and cache audio in background
  Future<void> _downloadAndCacheAudio(String url, String key, String ext) async {
    try {
      final cacheManager = CustomCacheManager();
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) throw Exception('Audio download failed');
      final bytes = await consolidateHttpClientResponseBytes(response);
      if (bytes.length < 100 * 1024) throw Exception('Audio file too small for caching');
      await cacheManager.putFile(key, bytes, fileExtension: ext, maxAge: const Duration(hours: 24));
      debugPrint('Audio cached for key: $key');
    } catch (e) {
      debugPrint('Audio cache failed: $e');
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
                      color: CupertinoColors.black,
                      borderRadius: BorderRadius.circular(20)),
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
                                  icon: isPlaying
                                      ? HugeIcons.strokeRoundedPause
                                      : HugeIcons.strokeRoundedPlay,
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