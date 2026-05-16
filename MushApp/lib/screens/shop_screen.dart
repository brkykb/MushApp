import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mantar/providers/mushroom_provider.dart';

class MushShopScreen extends StatelessWidget {
  const MushShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<MushroomProvider>().userProfile;
    final coins = profile?['money']?.toString() ?? "0";

    return Scaffold(
      appBar: AppBar(
        title: const Text("MushShop"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Color(0xFFD4AF37), size: 18),
                const SizedBox(width: 4),
                Text(
                  coins,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPremiumBanner(),
          const SizedBox(height: 24),
          const Text("Coin Kazan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
          _buildEarnCard("Video İzle", "+50 Coin", Icons.play_circle_fill),
          const SizedBox(height: 24),
          const Text("Mağaza Ürünleri", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
          _buildShopItem("5x Ekstra Tarama", "150 Coin", "Asla bir keşfi kaçırma"),
          _buildShopItem("Sonbahar Harita Paketi", "500 Coin", "Gizli noktaları keşfet"),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3022),
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1542273917363-3b1817f69a2d'), 
          fit: BoxFit.cover, 
          opacity: 0.3,
          colorFilter: ColorFilter.mode(const Color(0xFF1B3022).withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MushApp Pro", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Sınırsız tarama, nadir mantar uyarıları ve çevrimdışı haritalar.", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF1B3022), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Şimdi Yükselt"),
          )
        ],
      ),
    );
  }

  Widget _buildEarnCard(String title, String reward, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(reward, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        trailing: ElevatedButton(onPressed: () {}, child: const Text("İzle")),
      ),
    );
  }

  Widget _buildShopItem(String name, String price, String desc) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1B3022), borderRadius: BorderRadius.circular(12)),
          child: Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
