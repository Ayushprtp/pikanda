// lib/backend/music_services.dart (or wherever your YoutubeMusicApiService is)

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YoutubeMusicApiService {
  static final YoutubeMusicApiService _instance = YoutubeMusicApiService._internal();

  factory YoutubeMusicApiService() {
    return _instance;
  }

  YoutubeMusicApiService._internal();

  late Dio _dio;
  late SharedPreferences _prefs;
  late String _visitorId;
  late Map<String, String> _internalHeaders;
  late Map<String, dynamic> _internalContext;

  // *** CRITICAL FIX: Use the actual YouTube Music API domain and referer ***
  // These URLs are for the actual API endpoints, not generic googleusercontent.com placeholders.
  // The 'browse' and 'player' endpoints typically go to different subdomains.
  // Make sure you use 'https' for production as well. For now, http might be fine for emulator.
  final String _apiBaseUrl = 'http://music.youtube.com/youtubei/v1/'; // Actual YTM API endpoint for player, browse etc.
  final String _ytmReferer = 'http://music.youtube.com/'; // Actual YouTube Music website base URL

  Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _dio = Dio(BaseOptions(
      baseUrl: _apiBaseUrl, // Use the correct API base URL here
      headers: {
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/json',
        'Origin': _ytmReferer.substring(0, _ytmReferer.length - 1), // Origin usually excludes trailing slash
        'Referer': _ytmReferer, // Correct referer for YTM
        'Cookie': 'CONSENT=YES+1',
      },
      responseType: ResponseType.json,
      validateStatus: (status) {
        return status != null && status < 500; // Accept 2xx, 3xx, and 4xx responses for debugging
      },
    ));

    await _prepareClientData();
    debugPrint('YoutubeMusicApiService: Initialized successfully.');
  }

  Future<void> _prepareClientData() async {
    _visitorId = await _getOrCreateVisitorId();

    // *** CRITICAL: Get a recent and valid clientVersion. ***
    // As of today, June 1, 2025, a dynamically generated version is good.
    final date = DateTime.now();
    final clientVersion = '2.${DateFormat('yyyyMMdd').format(date)}.01.00';
    // Example if dynamic fails later: const String clientVersion = '2.20250531.01.00';

    _internalHeaders = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36', // Slightly updated Chrome version
      'X-Goog-Visitor-Id': _visitorId,
      'X-Youtube-Client-Name': 'WEB_REMIX',
      'X-Youtube-Client-Version': clientVersion,
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Referer': _ytmReferer, // Use the correct YTM referer
      'Origin': _ytmReferer.substring(0, _ytmReferer.length - 1), // Origin usually excludes trailing slash
      'Cookie': 'CONSENT=YES+1;',
    };

    _internalContext = {
      'context': {
        'client': {
          'clientName': 'WEB_REMIX',
          'clientVersion': clientVersion, // Ensure this matches the header
          'gl': 'US',
          'hl': 'en',
          'platform': 'WEB',
          'userAgent': _internalHeaders['User-Agent'],
          'acceptHeader': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'utcOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
          'deviceScreenConfig': {
            'widthPoints': 1920,
            'heightPoints': 1080,
          },
          'mainAppWebInfo': {
            'graftUrl': '/feed/music_home',
            'routePrefix': '/music',
            'baseUrl': _ytmReferer, // Base URL for the main app web info should also be YTM
          },
        },
        'user': {
          'lockedSafetyMode': false,
        },
        'request': {
          'useSsl': true,
          'internalExperimentFlags': [],
          'consistencyTokenJars': [],
        },
        'playbackContext': {
          'contentPlaybackContext': {
            'autoCaptionsDefaultOn': false,
            'autonav': true,
            'html5Preference': 'HTML5_PREF_WANTS',
            'lactMilliseconds': '60000',
            'playerType': 'WEB_PLAYER',
            'referer': _ytmReferer, // Use the correct YTM referer
            'signatureTimestamp': _getSignatureTimestamp(),
            'videoDetails': {},
          },
        },
      },
    };

    _dio.options.headers.addAll(_internalHeaders);
  }

  // Signature timestamp is still a weak point, but we're debugging the connection first.
  int _getSignatureTimestamp() {
    // This value needs to be scraped dynamically. For stability, use a recent one.
    // As of June 2025, values around 19000-20000 for WEB_REMIX are common.
    return 20000;
  }

  Future<String> _getOrCreateVisitorId() async {
    final String? visitorDataJson = _prefs.getString('yt_visitor_id');
    if (visitorDataJson != null) {
      try {
        final Map<String, dynamic> visitorData = jsonDecode(visitorDataJson);
        final int exp = visitorData['exp'] as int;
        if (DateTime.now().millisecondsSinceEpoch ~/ 1000 < exp) {
          debugPrint('Using cached visitorId: ${visitorData['id']}');
          return visitorData['id'] as String;
        }
      } catch (e) {
        debugPrint('Error decoding cached visitorId: $e. Generating new one.');
      }
    }
    final String newId = 'CgZmbm9zZXI' + DateTime.now().microsecondsSinceEpoch.toString().padLeft(16, '0');
    final Map<String, dynamic> newVisitorData = {
      'id': newId,
      'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2592000
    };
    await _prefs.setString('yt_visitor_id', jsonEncode(newVisitorData));
    debugPrint('Generated new visitorId: $newId');
    return newId;
  }

  Future<Map<String, dynamic>> _sendRequest(String endpoint, Map<String, dynamic> payload) async {
    try {
      // Construct the full URL for logging
      final fullUrl = '${_dio.options.baseUrl}$endpoint';
      debugPrint('Sending request to: $fullUrl');
      debugPrint('Request Headers: ${_dio.options.headers}');
      debugPrint('Request Payload: ${jsonEncode(payload)}');

      final response = await _dio.post(
        endpoint,
        data: jsonEncode(payload),
      );

      debugPrint('HTTP Status Code: ${response.statusCode}');
      debugPrint('Raw API Response (Dio.data): ${response.data}');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        debugPrint('API Error ${response.statusCode}: ${response.data}');
        throw Exception('API Error ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('Dio Error for $endpoint: ${e.message}');
      if (e.response != null) {
        debugPrint('Dio Response Status: ${e.response?.statusCode}');
        debugPrint('Dio Response Data: ${e.response?.data}');
        debugPrint('Dio Response Headers: ${e.response?.headers}');
      } else {
        debugPrint('No response received. Check network connection or base URL.');
      }
      throw Exception('Network or Dio Error: ${e.message}');
    } catch (e) {
      debugPrint('General Error for $endpoint: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMediaInfo(String videoId) async {
    final Map<String, dynamic> payload = Map.from(_internalContext);
    payload['videoId'] = videoId;
    payload['racyCheckOk'] = true;
    payload['contentCheckOk'] = true;

    debugPrint('Attempting to fetch info for videoId: $videoId');

    final response = await _sendRequest('player', payload);

    final videoDetails = response['videoDetails'] as Map<String, dynamic>?;
    final streamingData = response['streamingData'] as Map<String, dynamic>?;

    if (videoDetails == null || streamingData == null) {
      debugPrint('Missing videoDetails or streamingData in API response.');
      debugPrint('Full response structure: ${response}');
      throw Exception('Failed to parse video details or streaming data from API response. Response keys missing.');
    }

    final String title = videoDetails['title'] ?? 'Unknown Title';
    final String author = videoDetails['author'] ?? 'Unknown Artist';
    final String thumbnailUrl = (videoDetails['thumbnail']?['thumbnails'] as List?)
        ?.lastWhere((thumb) => thumb['url'] != null, orElse: () => {})['url']
    as String? ?? '';

    final List<dynamic> adaptiveFormats = streamingData['adaptiveFormats'] ?? [];
    final List<Map<String, dynamic>> audioStreams = [];

    for (var format in adaptiveFormats) {
      if (format['mimeType']?.startsWith('audio/') == true) {
        audioStreams.add({
          'url': format['url'],
          'bitrate': format['bitrate'],
          'mimeType': format['mimeType'],
          'codec': format['audioCodec'],
          'contentLength': format['contentLength'],
        });
      }
    }

    return {
      'title': title,
      'artist': author,
      'thumbnailUrl': thumbnailUrl,
      'audioStreams': audioStreams,
      'status': response['playabilityStatus']?['status']
    };
  }
}