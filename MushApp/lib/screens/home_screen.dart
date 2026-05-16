import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mantar/providers/mushroom_provider.dart';
import 'package:mantar/screens/mushroom_detail_page.dart';
import 'package:mantar/screens/wiki_screen.dart';
import 'package:mantar/theme/mush_theme.dart';

class MushHomeScreen extends StatefulWidget {
  const MushHomeScreen({super.key});

  @override
  State<MushHomeScreen> createState() => _MushHomeScreenState();
}

class _MushHomeScreenState extends State<MushHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MushroomProvider>().fetchDailyMushroom();
      context.read<MushroomProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<MushroomProvider>().fetchDailyMushroom();
          await context.read<MushroomProvider>().fetchHistory();
        },
        color: const Color(0xFF1B3022),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Üst panelin arkasında kalmaması için ekstra boşluk
              _buildSearchBar(), // YENİ ARAMA ÇUBUĞU
              _buildMushroomOfDay(),
              _buildDailyScans(),
              _buildSectionHeader("Field Notes"),
              _buildFieldNotes(),
              _buildSectionHeader("Recent Discoveries", action: "View All"),
              _buildRecentDiscoveries(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          onSubmitted: (query) {
            if (query.trim().isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MushWikiScreen(searchQuery: query.trim()),
                ),
              );
            }
          },
          decoration: const InputDecoration(
            hintText: "Mantar türü veya isim ara...",
            border: InputBorder.none,
            icon: Icon(Icons.search, color: MushTheme.primaryGreen),
          ),
        ),
      ),
    );
  }

  Widget _buildMushroomOfDay() {
    return Consumer<MushroomProvider>(
      builder: (context, provider, child) {
        final daily = provider.dailyMushroom;
        if (daily == null) {
          return Container(height: 300, margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(24)));
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MushroomDetailPage(mushroom: daily)));
          },
          child: Container(
            margin: const EdgeInsets.all(16),
            height: 300,
            decoration: BoxDecoration(
              color: MushTheme.primaryGreen, // RESİM YÜKLENEMEZSE BU RENK GÖRÜNECEK
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    "assets/images/mushrooms/${daily.latinName.toLowerCase().replaceAll(' ', '_')}.png",
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.darken,
                    color: Colors.black.withOpacity(0.4),
                    errorBuilder: (context, error, stackTrace) => Image.network(
                      daily.imageUrl,
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black.withOpacity(0.4),
                      errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: daily.toxicity == "Yenen" ? Colors.green : const Color(0xFFD97D54),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      daily.toxicity,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        daily.latinName.toUpperCase(),
                        style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1.2),
                      ),
                      Text(
                        daily.name,
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyScans() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Günlük Tarama Hakları", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("3 / 5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const LinearProgressIndicator(value: 0.6, backgroundColor: Color(0xFFE0E0E0), color: Color(0xFF1B3022), minHeight: 8),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF0F0F0),
              elevation: 0,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Sınırsız Pakete Geç", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B3022))),
          if (action != null) Text(action, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFieldNotes() {
    return Row(
      children: [
        _buildNoteCard("Spore Prints", const Color(0xFF1B3022), 'assets/images/logo.png'),
        _buildNoteCard("Lookalikes", const Color(0xFFD97D54), Icons.warning),
      ],
    );
  }

  Widget _buildNoteCard(String title, Color color, dynamic iconOrPath) {
    return Expanded(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (iconOrPath is IconData)
              Icon(iconOrPath, color: Colors.white)
            else
              Image.asset(iconOrPath, width: 24, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentDiscoveries() {
    return Consumer<MushroomProvider>(
      builder: (context, provider, child) {
        if (provider.history.isEmpty) {
          return const Padding(padding: EdgeInsets.all(16.0), child: Text("Henüz keşif yok."));
        }
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final mushroom = provider.history[index];
              return _buildDiscoveryCard(mushroom);
            },
          ),
        );
      },
    );
  }

  Widget _buildDiscoveryCard(dynamic mushroom) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MushroomDetailPage(mushroom: mushroom)));
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/images/mushrooms/${mushroom.latinName.toLowerCase().replaceAll(' ', '_')}.png",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    mushroom.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (c, e, s) => Container(color: Colors.grey[300]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(mushroom.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Text("Yeni Keşif", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
