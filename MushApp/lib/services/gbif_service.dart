import 'dart:convert';
import 'package:http/http.dart' as http;

class GbifOccurrence {
  final double latitude;
  final double longitude;
  final String scientificName;
  final String? eventDate;

  GbifOccurrence({
    required this.latitude,
    required this.longitude,
    required this.scientificName,
    this.eventDate,
  });

  factory GbifOccurrence.fromJson(Map<String, dynamic> json) {
    return GbifOccurrence(
      latitude: json['decimalLatitude'] != null ? (json['decimalLatitude'] as num).toDouble() : 0.0,
      longitude: json['decimalLongitude'] != null ? (json['decimalLongitude'] as num).toDouble() : 0.0,
      scientificName: json['species'] ?? json['scientificName'] ?? 'Bilinmeyen Tür',
      eventDate: json['eventDate'],
    );
  }
}

class GbifService {
  static const String _baseUrl = 'https://api.gbif.org/v1';
  static const int _fungiTaxonKey = 5; // Fungi krallığı

  // Belirli bir koordinat kutusu (Bounding Box) içindeki mantarları getirir
  Future<List<GbifOccurrence>> fetchNearbyMushrooms(
      double minLat, double maxLat, double minLng, double maxLng) async {
    try {
      final url = Uri.parse(
          '$_baseUrl/occurrence/search?taxonKey=$_fungiTaxonKey&hasCoordinate=true&decimalLatitude=$minLat,$maxLat&decimalLongitude=$minLng,$maxLng&limit=50');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results
            .where((item) => item['decimalLatitude'] != null && item['decimalLongitude'] != null)
            .map((item) => GbifOccurrence.fromJson(item))
            .toList();
      } else {
        print('GBIF API hatası: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('GBIF fetch hatası: $e');
      return [];
    }
  }
}
