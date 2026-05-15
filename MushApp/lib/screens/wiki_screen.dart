import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mantar/providers/mushroom_provider.dart';
import 'package:mantar/screens/mushroom_detail_page.dart';
import 'package:mantar/theme/mush_theme.dart';

class MushWikiScreen extends StatefulWidget {
  final String? searchQuery;
  const MushWikiScreen({super.key, this.searchQuery});

  @override
  State<MushWikiScreen> createState() => _MushWikiScreenState();
}

class _MushWikiScreenState extends State<MushWikiScreen> {
  late TextEditingController _searchController;
  String _currentQuery = '';
  String _selectedCategory = ''; // YENİ: Seçili kategori

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.searchQuery ?? '';
    _searchController = TextEditingController(text: _currentQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MushroomProvider>().fetchMushrooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB), // Arkaplanla uyumlu renk
      body: Consumer<MushroomProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: MushTheme.primaryGreen));
          }

          // ARAMA VE KATEGORİ FİLTRESİ
          final filteredMushrooms = provider.mushrooms.where((m) {
            // 1. Kategori Filtresi
            bool matchesCategory = true;
            final tox = m.toxicity.toLowerCase();
            if (_selectedCategory == 'Yenilebilir') {
              matchesCategory = tox.contains('yenen') || tox.contains('yenilebilir');
            } else if (_selectedCategory == 'Zehirli') {
              matchesCategory = tox.contains('zehirli') || tox.contains('ölümcül') || tox.contains('toksik');
            } else if (_selectedCategory == 'Nadir') {
              matchesCategory = m.description.toLowerCase().contains('nadir') || m.habitat.toLowerCase().contains('nadir');
            }

            // 2. Metin Araması
            final q = _currentQuery.toLowerCase();
            final matchesQuery = q.isEmpty || m.name.toLowerCase().contains(q) || m.latinName.toLowerCase().contains(q);
            
            return matchesCategory && matchesQuery;
          }).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 110), // Global şeffaf AppBar'ın altına girmemesi için boşluk
              
              const Center(
                child: Text(
                  "MushWiki", 
                  style: TextStyle(
                    fontSize: 28, 
                    fontWeight: FontWeight.w800, 
                    color: MushTheme.primaryGreen,
                    letterSpacing: -0.5,
                  )
                ),
              ),
              const SizedBox(height: 16),
              
              // SAYFA İÇİ ARAMA ÇUBUĞU
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _currentQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Mantar türü veya isim ara...",
                  prefixIcon: const Icon(Icons.search, color: MushTheme.primaryGreen),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              _buildCategoryCard("Yenilebilir", "Culinary delights", Colors.green[100]!, "Yenilebilir"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildCategoryCard("Zehirli", "Stay away", Colors.red[100]!, "Zehirli")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildCategoryCard("Nadir", "Hidden gems", Colors.blue[100]!, "Nadir")),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Türler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MushTheme.primaryGreen)),
              const SizedBox(height: 10),
              
              if (filteredMushrooms.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("Sonuç bulunamadı.", style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredMushrooms.length,
                  itemBuilder: (context, index) {
                    final mushroom = filteredMushrooms[index];
                    return _buildWikiListItem(mushroom);
                  },
                ),
              const SizedBox(height: 100),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(String title, String subtitle, Color color, String categoryId) {
    final bool isSelected = _selectedCategory == categoryId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Eğer zaten seçiliyse kaldır (hepsini göster), değilse seç
          _selectedCategory = isSelected ? '' : categoryId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: MushTheme.primaryGreen, width: 2) : Border.all(color: Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? MushTheme.primaryGreen : Colors.black87)),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildWikiListItem(dynamic mushroom) {
    // Veritabanında Türkçe isim yerine doğrudan Latince isim girilmişse (veya isimler aynıysa) kontrol et
    final bool isSameName = mushroom.name.toLowerCase() == mushroom.latinName.toLowerCase();

    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MushroomDetailPage(mushroom: mushroom)));
      },
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          "assets/images/mushrooms/${mushroom.latinName.toLowerCase().replaceAll(' ', '_')}.png",
          width: 50, height: 50, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.network(
              mushroom.imageUrl, 
              width: 50, height: 50, fit: BoxFit.cover, 
              errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: Colors.grey[300])
            );
          },
        ),
      ),
      // Üstte Büyük Olarak Latince Adı
      title: Text(
        mushroom.latinName, 
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic, // Bilimsel ad her zaman italik olur
        )
      ),
      // Altta Ufak Olarak Türkçe (Halk) Adı
      subtitle: isSameName 
          ? null 
          : Text(mushroom.name, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      trailing: const Icon(Icons.bookmark_border),
    );
  }
}
