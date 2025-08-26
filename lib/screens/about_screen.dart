// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("ℹ️ About", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/images/hendry_logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 16),
            const Text(
              "HendryHub",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Founder message
            Card(
              color: const Color(0xFF1B2127),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "👋 Hello! I’m Jackson Patrick Byamungu, founder of Hendry Tech. "
                  "This app combines my YouTube channel with AI to empower learners "
                  "with tech tutorials, quizzes, and offline AI assistance. "
                  "My vision is to create a tech ecosystem as impactful as Microsoft — "
                  "starting here with HendryHub 🚀.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Roadmap / Vision
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "📌 Roadmap",
                style: TextStyle(
                  color: Colors.deepPurpleAccent.shade100,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    "Phase 1: Launch HendryHub with offline AI",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(
                    "Phase 2: Expand content + quizzes",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.timelapse, color: Colors.amber),
                  title: Text(
                    "Phase 3: Build Hendry MB Vault & ecosystem",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Links
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "🌐 Connect with me",
                style: TextStyle(
                  color: Colors.deepPurpleAccent.shade100,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFF1B2127),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.video_library,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      "YouTube Channel",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () =>
                        _launchUrl("https://www.youtube.com/@Hendry_Tech"),
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(
                      Icons.email,
                      color: Colors.lightBlueAccent,
                    ),
                    title: const Text(
                      "Email Me",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () => _launchUrl("mailto:hendrytech@gmail.com"),
                  ),
                  const Divider(color: Colors.white24),
                  ListTile(
                    leading: const Icon(
                      Icons.public,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      "Website",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () =>
                        _launchUrl("https://hendrytechfamily.wordpress.com"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
