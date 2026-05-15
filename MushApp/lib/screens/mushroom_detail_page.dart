import 'package:flutter/material.dart';
import 'package:mantar/models/mushroom.dart';

class MushroomDetailPage extends StatelessWidget {
  final Mushroom mushroom;

  const MushroomDetailPage({super.key, required this.mushroom});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Görüntü ve AppBar
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                "assets/images/mushrooms/${mushroom.latinName.toLowerCase().replaceAll(' ', '_')}.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    mushroom.imageUrl,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          // İçerik
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // İsim ve Latince İsim (Yeni Hiyerarşi)
                  Text(
                    mushroom.latinName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (mushroom.name.toLowerCase() != mushroom.latinName.toLowerCase())
                    Text(
                      mushroom.name,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Bilgi Kartları
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCard(
                        context,
                        mushroom.toxicity,
                        Icons.warning_amber_rounded,
                        mushroom.toxicity == "Yenen" ? Colors.green : Colors.red,
                      ),
                      _infoCard(context, mushroom.season, Icons.calendar_month, Colors.orange),
                      _infoCard(context, "Habitat", Icons.forest, Colors.brown),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Açıklama
                  const Text(
                    "Açıklama",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mushroom.description,
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),

                  // Detaylı Bilgi (Habitat vb.)
                  if (mushroom.habitat.isNotEmpty) ...[
                    const Text(
                      "Yaşam Alanı",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mushroom.habitat,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Kaynak Butonu
                  if (mushroom.sourceUrl.isNotEmpty)
                    OutlinedButton.icon(
                      onPressed: () {
                        // Wikipedia linkini açma işlemi buraya gelebilir
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text("Wikipedia'da Görüntüle"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context, String label, IconData icon, Color color) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
