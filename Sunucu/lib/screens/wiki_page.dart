import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mushroom_provider.dart';
import '../models/mushroom.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({super.key});

  @override
  State<WikiPage> createState() => _WikiPageState();
}

class _WikiPageState extends State<WikiPage> {
  String _searchQuery = "";
  String _selectedCategory = "Hepsi";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MushroomProvider>().fetchWiki();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Mantar Ansiklopedisi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: "Mantar ara...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),

          // Kategoriler
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: ["Hepsi", "Yenen", "Zehirli", "Ölümcül"].map((cat) {
                bool isActive = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isActive,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    selectedColor: Colors.green.shade100,
                    checkmarkColor: Colors.green,
                    backgroundColor: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 15),

          // Mantar Listesi
          Expanded(
            child: Consumer<MushroomProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.mushrooms.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final list = provider.mushrooms.where((m) {
                  bool matchesSearch = m.name.toLowerCase().contains(_searchQuery);
                  bool matchesCat = _selectedCategory == "Hepsi" || m.toxicity == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (list.isEmpty) {
                  return const Center(child: Text("Sonuç bulunamadı."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildMushroomCard(list[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMushroomCard(Mushroom mushroom) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                mushroom.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mushroom.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  mushroom.toxicity,
                  style: TextStyle(
                    color: mushroom.toxicity == "Yenen" ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
