import 'dart:io';
import 'package:flutter_gemma/flutter_gemma.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class ModelManager {
  final FlutterGemmaPlugin _gemma = FlutterGemmaPlugin.instance;
  final String modelFileName;

  ModelManager({required this.modelFileName});

  /// Full path in assets folder (so you can keep just file name in constructor)
  String get _assetPath => 'models/$modelFileName'; // ✅ matches assets/models/

  /// Checks if the model file is already installed locally.
  Future<bool> isModelInstalled() async {
    try {
      final directory = await getApplicationSupportDirectory();
      final modelFile = File('${directory.path}/$modelFileName');
      final exists = await modelFile.exists();
      print(
        '🔍 Model file check: ${modelFile.path} → ${exists ? "Exists" : "Missing"}',
      );
      return exists;
    } catch (e) {
      print('⚠️ Error checking model existence: $e');
      return false;
    }
  }

  /// Installs the model from assets/models/.
  Future<void> installModelFromAsset() async {
    try {
      print('📦 Installing model from assets/models: $modelFileName');
      await _gemma.modelManager.installModelFromAsset(
        _assetPath,
      ); // ✅ fixed path
      print('✅ Model installed successfully.');
    } catch (e) {
      print('❌ Error installing model from assets: $e');
      rethrow;
    }
  }

  /// Downloads the model from a remote URL (for updates or switching models).
  Future<void> downloadModelFromNetwork({required String url}) async {
    try {
      print('🌐 Downloading model from: $url');
      await _gemma.modelManager.downloadModelFromNetwork(url);
      print('✅ Model downloaded successfully.');
    } catch (e) {
      print('❌ Error downloading model: $e');
      rethrow;
    }
  }
}
