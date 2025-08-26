// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../services/local_data_service.dart';
import '../services/youtube_service.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onOpenAiTab; // ✅ callback to RootShell

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.onOpenAiTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final YouTubeService _youTubeService = YouTubeService();

  late Future<List<YouTubeVideo>> _videosFuture;
  late Future<String> _aiTipFuture;
  late Future<Map<String, dynamic>> _quizFuture;

  int? _selectedAnswerIndex;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nowDark = Theme.of(context).brightness == Brightness.dark;
    if (nowDark != _isDarkMode) {
      _isDarkMode = nowDark; // no setState to avoid extra build
    }
  }

  void _loadAllData() {
    _videosFuture = _youTubeService.fetchVideos(maxResults: 6);
    _aiTipFuture = LocalDataService.loadRandomTip();
    _quizFuture = LocalDataService.loadRandomQuiz();
  }

  void _retryVideos() => setState(
    () => _videosFuture = _youTubeService.fetchVideos(maxResults: 6),
  );
  void _retryTip() =>
      setState(() => _aiTipFuture = LocalDataService.loadRandomTip());
  void _retryQuiz() =>
      setState(() => _quizFuture = LocalDataService.loadRandomQuiz());

  TextStyle get _sectionTitleStyle => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  TextStyle get _bodyTextStyle =>
      const TextStyle(color: Colors.white, fontSize: 16);

  Widget _buildErrorSection(String message, VoidCallback onRetry) {
    return Column(
      children: [
        Text(message, style: _bodyTextStyle, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onRetry,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Retry'),
        ),
      ],
    );
  }

  void _openVideoPlayer(YouTubeVideo video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _YouTubePlayerPage(videoId: video.videoId, title: video.title),
      ),
    );
  }

  Widget _buildVideoCard(YouTubeVideo video) {
    return GestureDetector(
      onTap: () => _openVideoPlayer(video),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                video.thumbnailUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              video.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz(Map<String, dynamic> quizData) {
    final question = quizData['question'] as String;
    final options = List<String>.from(quizData['options']);
    final correctIndex = quizData['answerIndex'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(options.length, (i) {
          final selected = _selectedAnswerIndex == i;
          final isCorrect = selected && i == correctIndex;
          final isWrong = selected && i != correctIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedAnswerIndex = i),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green
                    : isWrong
                    ? Colors.red
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      options[i],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (isCorrect) const Icon(Icons.check, color: Colors.white),
                  if (isWrong) const Icon(Icons.close, color: Colors.white),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _sectionTitleStyle),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        title: const Text('HendryHub'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () {
              final next = !_isDarkMode;
              setState(() => _isDarkMode = next);
              widget.onToggleTheme(next);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.deepPurple,
        onRefresh: () async {
          _loadAllData();
          await Future.wait([_videosFuture, _aiTipFuture, _quizFuture]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '👋 Karibu HendryHub 🇹🇿',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // 🔥 Latest Videos
              _section(
                title: '🔥 Latest Videos',
                child: SizedBox(
                  height: 200,
                  child: FutureBuilder<List<YouTubeVideo>>(
                    future: _videosFuture,
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        final msg = 'Failed to load videos.';
                        return _buildErrorSection(msg, _retryVideos);
                      }
                      final videos = snap.data ?? const <YouTubeVideo>[];
                      if (videos.isEmpty) {
                        return const Center(
                          child: Text(
                            'No videos found.',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }
                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: videos.map(_buildVideoCard).toList(),
                      );
                    },
                  ),
                ),
              ),

              // 💡 Tip
              _section(
                title: '💡 Hendry AI Daily Tip',
                child: FutureBuilder<String>(
                  future: _aiTipFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError || !snap.hasData) {
                      return _buildErrorSection(
                        'Failed to load tip.',
                        _retryTip,
                      );
                    }
                    return Card(
                      color: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(snap.data!, style: _bodyTextStyle),
                      ),
                    );
                  },
                ),
              ),

              // 🧠 Quiz
              _section(
                title: '🧠 Quick Tech Quiz',
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _quizFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snap.hasError ||
                        snap.data == null ||
                        snap.data!['question'] == null) {
                      return _buildErrorSection(
                        'Error loading quiz.',
                        _retryQuiz,
                      );
                    }

                    // If the quiz arrived but we didn't yet prepare it (rare race),
                    // prepare it now. This ensures shuffle is initialized quickly.
                    // _prepareQuiz uses setState internally but it's safe because it's called
                    // only when the question changes.

                    return _buildQuiz(snap.data!);
                  },
                ),
              ),

              // 🤖 AI Card
              _section(
                title: '🤖 Ask Hendry AI',
                child: GestureDetector(
                  onTap: widget.onOpenAiTab, // ✅ jump to AI tab in RootShell
                  child: Card(
                    color: Colors.blueGrey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.smart_toy, color: Colors.white, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Have a question? Tap here to chat with Hendry AI (offline).",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small dedicated page for playing a single YouTube video using the iFrame player.
/// This works on both Android and iOS and supports fullscreen.
class _YouTubePlayerPage extends StatefulWidget {
  final String videoId;
  final String title;

  const _YouTubePlayerPage({required this.videoId, required this.title});

  @override
  State<_YouTubePlayerPage> createState() => _YouTubePlayerPageState();
}

class _YouTubePlayerPageState extends State<_YouTubePlayerPage> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        showControls: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close(); // important to free resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerScaffold(
      controller: _controller,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(title: Text(widget.title)),
          body: Center(
            child: AspectRatio(aspectRatio: 16 / 9, child: player),
          ),
        );
      },
    );
  }
}
