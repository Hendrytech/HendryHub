// lib/services/youtube_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class YouTubeVideo {
  final String videoId;
  final String title;
  final String thumbnailUrl;
  final String? description;
  final DateTime? publishedAt;
  final String? duration;

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
      videoId: json['videoId'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      duration: json['duration'],
    );
  }
}

class YouTubeService {
  // 👉 Raw GitHub URL (make sure videos.json is inside repo at /assets/json/)
  static const String githubUrl =
      'https://raw.githubusercontent.com/Hendrytech/HendryHub/main/assets/json/videos.json';

  Future<List<YouTubeVideo>> fetchVideos() async {
    final response = await http.get(Uri.parse(githubUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch videos: ${response.body}');
    }

    final data = json.decode(response.body);
    if (data is! List) throw Exception("Invalid videos.json format");

    return data
        .map<YouTubeVideo>((json) => YouTubeVideo.fromJson(json))
        .toList();
  }
}
