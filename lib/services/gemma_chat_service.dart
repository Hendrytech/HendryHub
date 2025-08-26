import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

class GemmaChatService {
  InferenceChat? _chat;
  InferenceModel? _model;

  int _currentMaxTokens = 2048;
  final String _defaultModel =
      'Gemma3-1B-IT_multi-prefill-seq_q4_block32_ekv1280.task';

  bool _isInitialized = false;

  /// Copies the model file to app support directory if needed.
  Future<String> _prepareModelFile(String assetName) async {
    try {
      final dir = await getApplicationSupportDirectory();
      final filePath = '${dir.path}/$assetName';
      final file = File(filePath);

      if (await file.exists() && await file.length() > 0) {
        print('📂 Model already available at: $filePath');
        return filePath;
      }

      print('📦 Copying model from assets/models/$assetName');
      final byteData = await rootBundle.load('assets/models/$assetName');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      print('✅ Model copied to: $filePath');
      return filePath;
    } catch (e) {
      print('❌ Failed to prepare model file: $e');
      rethrow;
    }
  }

  /// Initializes the model and chat session.
  Future<void> initialize({
    String? modelFileName,
    int maxTokens = 2048,
    ModelType modelType = ModelType.gemmaIt,
  }) async {
    try {
      final fileName = modelFileName ?? _defaultModel;
      await _prepareModelFile(fileName);

      // Ensure plugin knows about the model
      final isInstalled =
          await FlutterGemmaPlugin.instance.modelManager.isModelInstalled;
      if (!isInstalled) {
        await FlutterGemmaPlugin.instance.modelManager.installModelFromAsset(
          'models/$fileName',
        );
      }

      _currentMaxTokens = maxTokens;

      _model = await FlutterGemmaPlugin.instance.createModel(
        modelType: modelType,
        maxTokens: maxTokens,
      );

      _chat = await _model!.createChat(
        temperature: 0.8,
        randomSeed: 42,
        topK: 1,
        topP: 0.9,
        tokenBuffer: 256,
        modelType: modelType,
        isThinking: true,
      );

      _isInitialized = true;
      print('✅ Chat service initialized (maxTokens=$maxTokens)');
    } catch (e) {
      _isInitialized = false;
      print('❌ Error initializing GemmaChatService: $e');
      rethrow;
    }
  }

  /// Re-initialize the chat with a new token limit.
  Future<void> updateMaxTokens(int newMax) async {
    if (newMax == _currentMaxTokens) {
      return;
    }
    await initialize(modelFileName: _defaultModel, maxTokens: newMax);
  }

  /// Generates a single full response.
  Future<String> generateResponse(String userMessage) async {
    if (!_isInitialized || _chat == null) {
      return 'Error: Chat service not initialized.';
    }

    try {
      final session = _chat!.session;
      await session.addQueryChunk(Message(text: userMessage));
      final response = await session.getResponse();
      return response;
    } catch (e) {
      return 'Error: $e';
    }
  }

  /// Streams the response in chunks.
  Stream<String> streamResponse(String userMessage) async* {
    if (!_isInitialized || _chat == null) {
      yield 'Error: Chat service not initialized.';
      return;
    }

    try {
      final session = _chat!.session;
      await session.addQueryChunk(Message(text: userMessage));
      yield* session.getResponseAsync();
    } catch (e) {
      yield 'Error: $e';
    }
  }
}
