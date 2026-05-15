import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mantar/models/mushroom.dart';
import 'package:mantar/providers/mushroom_provider.dart';

class MushProfileScreen extends StatefulWidget {
  const MushProfileScreen({super.key});

  @override
  State<MushProfileScreen> createState() => _MushProfileScreenState();
}

class _MushProfileScreenState extends State<MushProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MushroomProvider>().fetchUserProfile();
      context.read<MushroomProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<MushroomProvider>().userProfile;
    final history = context.watch<MushroomProvider>().history;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.account_circle, size: 100, color: Color(0xFF1B3022)),
            const SizedBox(height: 16),
            Text(
              profile?['name'] ?? FirebaseAuth.instance.currentUser?.displayName ?? "Kullanıcı",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B3022)),
            ),
            Text(
              "Level ${profile?['level'] ?? 1} Mantar Avcısı",
              style: const TextStyle(color: Colors.grey),
            ),
            _buildXPProgress(profile),
            _buildStatsRow(context, profile),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Son Keşiflerin", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
              ),
            ),
            _buildAlbumGrid(history),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildXPProgress(Map<String, dynamic>? profile) {
    double exp = (profile?['exp'] ?? 0).toDouble();
    double maxExp = (profile?['max_exp'] ?? 100).toDouble();
    double progress = exp / maxExp;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("XP İlerlemesi", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("${exp.toInt()} / ${maxExp.toInt()}"),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress, color: const Color(0xFF1B3022), backgroundColor: Colors.grey[200], minHeight: 10),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, Map<String, dynamic>? profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(profile?['collection_count']?.toString() ?? "0", "Keşifler"),
        _buildStatItem(profile?['money']?.toString() ?? "0", "MushCoin"),
        _buildStatItem(profile?['daily_scans_left']?.toString() ?? "0", "Haklar"),
      ],
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildAlbumGrid(List<Mushroom> history) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text("Henüz keşfedilmiş mantar yok.", style: TextStyle(color: Colors.grey)),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: history.length > 4 ? 4 : history.length,
      itemBuilder: (context, index) {
        final m = history[index];
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage(m.imageUrl), fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
        );
      },
    );
  }
}
