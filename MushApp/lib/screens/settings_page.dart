import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Ayarlar", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader("Profil"),
          _settingsTile(Icons.person_outline, "Hesap Bilgileri", "Berkay Karabulut"),
          _settingsTile(Icons.history, "Tarama Geçmişi", "24 Kayıt"),
          
          const SizedBox(height: 24),
          _sectionHeader("Uygulama"),
          _settingsTile(Icons.notifications_none, "Bildirimler", "Açık"),
          _settingsTile(Icons.dark_mode_outlined, "Görünüm", "Aydınlık"),
          _settingsTile(Icons.language, "Dil", "Türkçe"),

          const SizedBox(height: 24),
          _sectionHeader("Destek"),
          _settingsTile(Icons.help_outline, "Yardım Merkezi", ""),
          _settingsTile(Icons.info_outline, "Hakkında", "Versiyon 1.0.0"),

          const SizedBox(height: 40),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Çıkış Yap",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {},
      ),
    );
  }
}