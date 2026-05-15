import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mantar/theme/mush_theme.dart';
import 'package:mantar/services/gbif_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MushMapScreen extends StatefulWidget {
  const MushMapScreen({super.key});

  @override
  State<MushMapScreen> createState() => _MushMapScreenState();
}

class _MushMapScreenState extends State<MushMapScreen> {
  final MapController _mapController = MapController();
  final GbifService _gbifService = GbifService();
  final TextEditingController _searchController = TextEditingController();
  
  LatLng _centerLocation = const LatLng(41.0082, 28.9784); // Varsayılan: İstanbul
  bool _isLoadingLocation = true;
  bool _isLoadingMushrooms = false;
  List<GbifOccurrence> _occurrences = [];
  
  GbifOccurrence? _selectedMushroom;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() { _isLoadingLocation = true; });

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _fetchMushroomsForCurrentView();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _fetchMushroomsForCurrentView();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _fetchMushroomsForCurrentView();
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _centerLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_centerLocation, 13.0);
    } catch (e) {
      print("Konum alınamadı: $e");
    } finally {
      setState(() { _isLoadingLocation = false; });
      _fetchMushroomsForCurrentView();
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    // Klavyeyi kapat
    FocusManager.instance.primaryFocus?.unfocus();
    
    setState(() { _isLoadingLocation = true; });
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'MushApp/1.0 (com.example.mantar)',
        'Accept-Language': 'tr',
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          _centerLocation = LatLng(lat, lon); // Merkezi güncelle
          _mapController.move(_centerLocation, 13.0);
          _fetchMushroomsForCurrentView();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bölge bulunamadı.")));
        }
      }
    } catch (e) {
      print("Arama hatası: $e");
    } finally {
      setState(() { _isLoadingLocation = false; });
    }
  }

  Future<void> _fetchMushroomsForCurrentView() async {
    if (!mounted) return;
    setState(() { _isLoadingMushrooms = true; _selectedMushroom = null; });
    
    // Haritanın mevcut sınırlarını alıyoruz
    final bounds = _mapController.camera.visibleBounds;
    final minLat = bounds.south;
    final maxLat = bounds.north;
    final minLng = bounds.west;
    final maxLng = bounds.east;

    final results = await _gbifService.fetchNearbyMushrooms(minLat, maxLat, minLng, maxLng);
    
    if (mounted) {
      setState(() {
        _occurrences = results;
        _isLoadingMushrooms = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. HARİTA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centerLocation,
              initialZoom: 13.0,
              onMapEvent: (event) {
                // Sadece hareket bittiğinde veri çekerek işlemciyi yormuyoruz
                if (event is MapEventMoveEnd) {
                  _fetchMushroomsForCurrentView();
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.mantar',
                // Performans için tile cache ayarları
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(
                // Ekran dışındaki markerları çizme (Performans için kritik)
                markers: _occurrences.map((occ) {
                  return Marker(
                    point: LatLng(occ.latitude, occ.longitude),
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onTap: () {
                        setState(() { _selectedMushroom = occ; });
                      },
                      child: const Icon(
                        Icons.location_on,
                        color: MushTheme.accentToxic,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (!_isLoadingLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _centerLocation,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: MushTheme.primaryGreen.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.my_location, color: MushTheme.primaryGreen, size: 30),
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),

          // 2. ARAMA ÇUBUĞU (Üst)
          Positioned(
            top: 110, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9), 
                borderRadius: BorderRadius.circular(30), 
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
              ),
              child: TextField(
                controller: _searchController,
                onSubmitted: _searchLocation,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Bölge veya şehir ara...", 
                  border: InputBorder.none, 
                  icon: const Icon(Icons.location_city, color: MushTheme.primaryGreen),
                  suffixIcon: _isLoadingMushrooms 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: MushTheme.primaryGreen)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search, color: MushTheme.primaryGreen),
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            _searchLocation(_searchController.text.trim());
                          } else {
                            _fetchMushroomsForCurrentView();
                          }
                        },
                      ),
                ),
              ),
            ),
          ),

          // 3. KONUM BUTONU
          Positioned(
            top: 180, right: 16,
            child: FloatingActionButton(
              heroTag: 'location_btn',
              mini: true,
              backgroundColor: Colors.white.withOpacity(0.9),
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: MushTheme.primaryGreen),
            ),
          ),

          // 4. SEÇİLEN MANTAR BİLGİ KARTI (Alt)
          if (_selectedMushroom != null)
            Positioned(
              bottom: 120, left: 16, right: 16,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12), 
                    child: Container(
                      width: 60, height: 60, 
                      color: MushTheme.primaryGreen.withOpacity(0.1), 
                      child: const Icon(Icons.forest, color: MushTheme.primaryGreen, size: 30)
                    )
                  ),
                  title: Text(_selectedMushroom!.scientificName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text("Gözlem Tarihi: ${_selectedMushroom!.eventDate?.split('T')[0] ?? 'Bilinmiyor'}\nKonum: ${_selectedMushroom!.latitude.toStringAsFixed(4)}, ${_selectedMushroom!.longitude.toStringAsFixed(4)}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => setState(() { _selectedMushroom = null; }),
                  ),
                ),
              ),
            ),
            
          // Konum aranıyor uyarısı
          if (_isLoadingLocation)
            Positioned(
              bottom: 120, left: 16, right: 16,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: MushTheme.primaryGreen),
                      SizedBox(width: 16),
                      Text("Konum aranıyor...")
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
