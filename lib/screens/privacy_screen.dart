// lib/screens/privacy_screen.dart
import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "🔒 Privacy Policy",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Privacy Matters",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "At HendryHub, we respect and protect your personal data. "
              "This policy explains what information we collect, how we use it, "
              "and what choices you have.",
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),

            _sectionTitle("📌 Information We Collect"),
            const Text(
              "• App preferences (dark mode, notifications).\n"
              "• AI chat history (saved only on your device via Hive).\n"
              "• YouTube videos are fetched live but we do not store your activity.\n"
              "• We do not collect personal data like name, location, or contacts.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 20),

            _sectionTitle("⚡ How We Use Data"),
            const Text(
              "• To remember your settings (like theme or notification choices).\n"
              "• To provide AI features and personalized tips.\n"
              "• To improve your learning experience in the app.\n"
              "• No personal information is shared or sold.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 20),

            _sectionTitle("🛡️ Your Rights"),
            const Text(
              "• You control your preferences anytime in Settings.\n"
              "• You can clear your AI chat history anytime.\n"
              "• You can uninstall the app to remove all stored data.\n"
              "• For any request, you can contact us directly.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 20),

            _sectionTitle("📬 Contact Us"),
            const Text(
              "If you have questions or concerns about privacy, "
              "please reach out to us:",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
            const SizedBox(height: 10),
            const SelectableText(
              "📧 hendrytechcompany@gmail.com",
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: Text(
                "Last updated: August 2025",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
