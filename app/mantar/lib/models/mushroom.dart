// lib/models/mushroom.dart

class Mushroom {
  final String id;
  final String name;
  final String imagePath; // İnternet linki olacak şimdilik
  final String category; // "Yenen" veya "Zehirli"
  final String description;

  Mushroom({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.category,
    required this.description,
  });
}

// SAHTE VERİ LİSTESİ (Mock Data)
// API gelene kadar bunları kullanacağız
final List<Mushroom> mockMushrooms = [
  Mushroom(
    id: "1",
    name: "Kanlıca Mantarı",
    imagePath: "https://images.unsplash.com/photo-1597349803159-d8916d820461?q=80&w=2070&auto=format&fit=crop",
    category: "Yenen",
    description: "Çam ormanlarında yetişen, turuncu renkli lezzetli bir mantar.",
  ),
  Mushroom(
    id: "2",
    name: "Sinek Mantarı",
    imagePath: "https://images.unsplash.com/photo-1535498730771-e735b998cd64?q=80&w=1887&auto=format&fit=crop",
    category: "Zehirli",
    description: "Kırmızı şapkalı, beyaz benekli, masallardaki o meşhur zehirli mantar.",
  ),
  Mushroom(
    id: "3",
    name: "Kuzugöbeği",
    imagePath: "https://images.unsplash.com/photo-1616688758880-9c2401bc775e?q=80&w=2070&auto=format&fit=crop",
    category: "Yenen",
    description: "Ekonomik değeri yüksek, petek görünümlü bir mantar.",
  ),
  Mushroom(
    id: "4",
    name: "Köygöçüren",
    imagePath: "https://images.unsplash.com/photo-1627806505707-440409a47321?q=80&w=2070&auto=format&fit=crop",
    category: "Ölümcül",
    description: "En tehlikeli mantarlardan biridir. Asla dokunulmamalı.",
  ),
];