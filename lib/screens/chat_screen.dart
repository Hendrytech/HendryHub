import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemma_chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final GemmaChatService _chatService = GemmaChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [];
  bool _isStreaming = false;
  String _bufferedResponse = '';
  bool _isModelReady = false;
  String? _initError;

  int _selectedTokens = 2048;
  StreamSubscription<String>? _streamSub;

  late AnimationController _dotsController;
  late Animation<int> _dotsAnimation;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initializeChatService();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _dotsAnimation = StepTween(begin: 1, end: 3).animate(_dotsController);
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _streamSub?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTokens = prefs.getInt('max_tokens') ?? 2048;
    });
  }

  Future<void> _savePreferences(int tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('max_tokens', tokens);
    setState(() {
      _selectedTokens = tokens;
    });
    // 🔥 tell chat service to update tokens dynamically
    await _chatService.updateMaxTokens(tokens);
  }

  Future<void> _initializeChatService() async {
    try {
      await _chatService.initialize(
        modelFileName: 'Gemma3-1B-IT_multi-prefill-seq_q4_block32_ekv1280.task',
      );
      setState(() => _isModelReady = true);
    } catch (e) {
      setState(() => _initError = e.toString());
    }
  }

  void _sendMessage({String? regeneratePrompt}) {
    final input = regeneratePrompt ?? _controller.text.trim();
    if (input.isEmpty || _isStreaming || !_isModelReady) return;

    if (regeneratePrompt == null) {
      setState(() {
        _messages.add({"role": "user", "text": input});
      });
      _controller.clear();
    }

    setState(() {
      _bufferedResponse = '';
      _isStreaming = true;
    });

    _scrollToBottom();

    _streamSub = _chatService
        .streamResponse(input)
        .listen(
          (chunk) {
            setState(() {
              _bufferedResponse += chunk;
            });
            _scrollToBottom();
          },
          onDone: () {
            setState(() {
              _messages.add({
                "role": "ai",
                "text": _bufferedResponse,
                "prompt": input,
              });
              _isStreaming = false;
            });
            _scrollToBottom();
          },
          onError: (error) {
            setState(() {
              _messages.add({"role": "error", "text": error.toString()});
              _isStreaming = false;
            });
            _scrollToBottom();
          },
        );
  }

  void _cancelResponse() {
    _streamSub?.cancel();
    setState(() {
      if (_bufferedResponse.isNotEmpty) {
        _messages.add({"role": "ai", "text": _bufferedResponse});
      }
      _isStreaming = false;
    });
  }

  void _regenerateResponse(String? prompt) {
    if (prompt != null && prompt.isNotEmpty) {
      _sendMessage(regeneratePrompt: prompt);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isUser = msg["role"] == "user";
    final isAI = msg["role"] == "ai";
    final bgColor = isUser
        ? const Color.fromARGB(255, 1, 39, 70)
        : const Color.fromARGB(106, 1, 39, 70);
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Align(
        alignment: align,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                isAI ? "🤖 Hendry AI:\n${msg["text"]}" : msg["text"] ?? "",
                style: const TextStyle(fontSize: 16),
              ),
              if (isAI)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () => _copyToClipboard(msg["text"] ?? ""),
                      tooltip: "Copy",
                    ),
                    if (msg["prompt"] != null)
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18),
                        onPressed: () => _regenerateResponse(msg["prompt"]),
                        tooltip: "Regenerate",
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreamingBubble() {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedBuilder(
                animation: _dotsAnimation,
                builder: (context, child) {
                  if (_bufferedResponse.isEmpty) {
                    final dots = "." * _dotsAnimation.value;
                    return Text(
                      "🤖 Hendry AI is thinking$dots",
                      style: TextStyle(fontSize: 16, color: scheme.onSurface),
                    );
                  }
                  return SelectableText(
                    _bufferedResponse,
                    style: TextStyle(fontSize: 16, color: scheme.onSurface),
                  );
                },
              ),
              const SizedBox(height: 6),
              if (_isStreaming)
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text("Cancel"),
                    onPressed: _cancelResponse,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return Scaffold(
        body: Center(child: Text('❌ Model init failed: $_initError')),
      );
    }

    if (!_isModelReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hendry AI"),
        actions: [
          DropdownButton<int>(
            value: _selectedTokens,
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 512, child: Text("⚡ Quick Mode")),
              DropdownMenuItem(value: 1024, child: Text("⚖ Balanced Mode")),
              DropdownMenuItem(value: 2048, child: Text("🧠 Deep Thinking")),
            ],
            onChanged: (val) {
              if (val != null) _savePreferences(val);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isStreaming ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _buildMessageBubble(_messages[index]);
                } else {
                  return _buildStreamingBubble();
                }
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: Scrollbar(
                      child: TextField(
                        controller: _controller,
                        maxLines: null,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: "Ask Hendry AI anything...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        enabled: !_isStreaming && _isModelReady,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isModelReady ? () => _sendMessage() : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
