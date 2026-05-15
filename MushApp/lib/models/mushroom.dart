// lib/models/mushroom.dart

class Mushroom {
  final int? id;
  final String name;
  final String latinName;
  final String description;
  final String toxicity;
  final String habitat;
  final String season;
  final String imageUrl;
  final String sourceUrl;

  Mushroom({
    this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.toxicity,
    required this.habitat,
    required this.season,
    required this.imageUrl,
    required this.sourceUrl,
  });

  factory Mushroom.fromJson(Map<String, dynamic> json) {
    return Mushroom(
      id: json['id'],
      name: json['name'] ?? '',
      latinName: json['latin_name'] ?? '',
      description: json['description'] ?? '',
      toxicity: json['toxicity'] ?? '',
      habitat: json['habitat'] ?? '',
      season: json['season'] ?? '',
      imageUrl: json['image_url'] ?? '',
      sourceUrl: json['source_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latin_name': latinName,
      'description': description,
      'toxicity': toxicity,
      'habitat': habitat,
      'season': season,
      'image_url': imageUrl,
      'source_url': sourceUrl,
    };
  }
}

// SAHTE VERİ LİSTESİ (Mock Data) - Silmiyorum, fallback olarak kalabilir
final List<Mushroom> mockMushrooms = [
  Mushroom(
    id: 1,
    name: "Kanlıca Mantarı",
    latinName: "Lactarius deliciosus",
    imageUrl: "https://images.unsplash.com/photo-1597349803159-d8916d820461?q=80&w=2070&auto=format&fit=crop",
    toxicity: "Yenen",
    description: "Çam ormanlarında yetişen, turuncu renkli lezzetli bir mantar.",
    habitat: "Çam ormanları",
    season: "Sonbahar",
    sourceUrl: "",
  ),
];