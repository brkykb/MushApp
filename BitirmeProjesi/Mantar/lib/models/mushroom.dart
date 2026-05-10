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

  Mushroom({
    this.id,
    required this.name,
    required this.latinName,
    required this.description,
    required this.toxicity,
    required this.habitat,
    required this.season,
    required this.imageUrl,
  });

  factory Mushroom.fromJson(Map<String, dynamic> json) {
    return Mushroom(
      id: json['id'],
      name: json['name'] ?? '',
      latinName: json['latin_name'] ?? '',
      description: json['description'] ?? '',
      toxicity: json['toxicity'] ?? 'Bilinmiyor',
      habitat: json['habitat'] ?? '',
      season: json['season'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class UserScan {
  final int id;
  final int? mushroomId;
  final String mushroomName;
  final String imageUrl;
  final double confidence;
  final DateTime scannedAt;
  final Mushroom? mushroomDetails;

  UserScan({
    required this.id,
    this.mushroomId,
    required this.mushroomName,
    required this.imageUrl,
    required this.confidence,
    required this.scannedAt,
    this.mushroomDetails,
  });

  factory UserScan.fromJson(Map<String, dynamic> json) {
    return UserScan(
      id: json['id'],
      mushroomId: json['mushroom'],
      mushroomName: json['mushroom_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      scannedAt: DateTime.parse(json['scanned_at']),
      mushroomDetails: json['mushroom_details'] != null 
          ? Mushroom.fromJson(json['mushroom_details']) 
          : null,
    );
  }
}