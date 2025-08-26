import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // ✅ import RootShell instead of HomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required Null Function() onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// ✅ Do all app startup tasks here
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              RootShell(isDark: isDark, onToggleTheme: (_) {}),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Splash background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/hendry_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Welcome to HendryHub',
                    speed: Duration(milliseconds: 80),
                  ),
                  TyperAnimatedText(
                    'Your tech journey starts here...',
                    speed: Duration(milliseconds: 60),
                  ),
                ],
                totalRepeatCount: 1,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: Colors.deepPurple,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
