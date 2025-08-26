// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy_screen.dart' as privacy;
import 'about_screen.dart' as about;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onToggleTheme});
  final void Function(bool isDark) onToggleTheme;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _updateTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
    setState(() => _isDarkTheme = isDark);
    widget.onToggleTheme(isDark);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDark ? "🌙 Dark mode enabled" : "☀️ Light mode enabled",
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  Future<void> _updateNotifications(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', isEnabled);
    setState(() => _notificationsEnabled = isEnabled);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEnabled ? "🔔 Notifications enabled" : "🔕 Notifications disabled",
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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

  Widget _buildTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFF1B2127),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurpleAccent),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111418),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111418),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('⚙️ Settings', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Appearance"),
          SwitchListTile(
            title: const Text(
              "Dark Theme",
              style: TextStyle(color: Colors.white),
            ),
            value: _isDarkTheme,
            onChanged: _updateTheme,
            activeThumbColor: Colors.deepPurpleAccent,
          ),

          _buildSectionTitle("Preferences"),
          SwitchListTile(
            title: const Text(
              "Notifications",
              style: TextStyle(color: Colors.white),
            ),
            value: _notificationsEnabled,
            onChanged: _updateNotifications,
            activeThumbColor: Colors.deepPurpleAccent,
          ),

          _buildSectionTitle("More"),
          _buildTile(
            title: "Privacy Policy",
            icon: Icons.privacy_tip,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const privacy.PrivacyScreen()),
            ),
          ),
          _buildTile(
            title: "About App",
            icon: Icons.info,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const about.AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
