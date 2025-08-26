import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

class LocalDataService {
  /// Load a random tip from tips.json
  static Future<String> loadRandomTip() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/datas/tips.json', // ✅ corrected path
      );
      final List<dynamic> tips = json.decode(jsonString);
      if (tips.isNotEmpty) {
        final randomIndex = Random().nextInt(tips.length);
        return tips[randomIndex];
      } else {
        return "Hakuna kidokezo kilichopatikana kwa sasa.";
      }
    } catch (e) {
      return "Kidokezo hakikuweza kupakiwa. Tafadhali jaribu tena.";
    }
  }

  /// Load a random quiz from quizzes.json
  static Future<Map<String, dynamic>> loadRandomQuiz() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/datas/quizzes.json', // ✅ corrected path
      );
      final List<dynamic> quizzes = json.decode(jsonString);

      if (quizzes.isNotEmpty) {
        final randomIndex = Random().nextInt(quizzes.length);
        final quiz = quizzes[randomIndex];

        // Ensure quiz format matches {"question":..., "options":..., "answerIndex":...}
        return {
          "question": quiz["question"] ?? "Swali halipo",
          "options": List<String>.from(quiz["options"] ?? []),
          "answerIndex": quiz["answerIndex"] ?? 0,
        };
      } else {
        return {
          "question": "Hakuna swali lililopatikana kwa sasa.",
          "options": ["Hakuna", "Chochote", "Wala", "Swali"],
          "answerIndex": 0,
        };
      }
    } catch (e) {
      return {
        "question": "Swali halikuweza kupakiwa. Tafadhali jaribu tena.",
        "options": ["Jaribu tena", "Hakuna", "Hitilafu", "Upya"],
        "answerIndex": 0,
      };
    }
  }
}
