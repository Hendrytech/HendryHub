// lib/services/youtube_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeVideo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String? description;
  final DateTime? publishedAt;
  final String? duration; // ⏱️ New

  YouTubeVideo({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    this.description,
    this.publishedAt,
    this.duration,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) {
    return YouTubeVideo(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
      description: json['snippet']['description'],
      publishedAt: DateTime.tryParse(json['snippet']['publishedAt'] ?? ''),
    );
  }

  YouTubeVideo copyWith({String? duration}) {
    return YouTubeVideo(
      videoId: videoId,
      title: title,
      thumbnailUrl: thumbnailUrl,
      description: description,
      publishedAt: publishedAt,
      duration: duration ?? this.duration,
    );
  }
}

class YouTubeService {
  static const String apiKey = 'AIzaSyDwUtd86DXIabwvDVkXpjqQ65pnrFJBHm8';
  static const String channelId = 'UCFR5X_YpP25n2y6CFOw4ILQ';
  static const String baseUrl = 'https://www.googleapis.com/youtube/v3';

  Future<List<YouTubeVideo>> fetchVideos({int maxResults = 10}) async {
    final url = Uri.parse(
      '$baseUrl/search?part=snippet&channelId=$channelId&maxResults=$maxResults&order=date&type=video&key=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch videos: ${response.body}');
    }

    final data = json.decode(response.body);
    final List items = data['items'];
    List<YouTubeVideo> videos = items
        .where((item) => item['id']['kind'] == 'youtube#video')
        .map<YouTubeVideo>((item) => YouTubeVideo.fromJson(item))
        .toList();

    // Fetch durations
    final ids = videos.map((v) => v.videoId).join(',');
    final detailsUrl = Uri.parse(
      '$baseUrl/videos?part=contentDetails&id=$ids&key=$apiKey',
    );
    final detailsResponse = await http.get(detailsUrl);

    if (detailsResponse.statusCode == 200) {
      final detailsData = json.decode(detailsResponse.body);
      final details = {for (var v in detailsData['items']) v['id']: v};

      videos = videos.map((video) {
        final detail = details[video.videoId];
        final duration = detail != null
            ? _parseDuration(detail['contentDetails']['duration'])
            : null;
        return video.copyWith(duration: duration);
      }).toList();
    }

    return videos;
  }

  /// Converts ISO 8601 duration (PT15M33S) → 15:33
  String _parseDuration(String iso) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(iso);
    if (match == null) return "0:00";

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (hours > 0) {
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "$minutes:${twoDigits(seconds)}";
    }
  }
}
