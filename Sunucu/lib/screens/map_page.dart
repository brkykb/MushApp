import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mantar/services/location_service.dart';

class HaritaSayfasi extends StatefulWidget {
  const HaritaSayfasi({super.key});

  @override
  State<HaritaSayfasi> createState() => _HaritaSayfasiState();
}

class _HaritaSayfasiState extends State<HaritaSayfasi> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LatLng _currentLocation = const LatLng(41.2008, 32.6281); // Karabük Default
  bool _isMapLoading = true;

  @override
  void initState() {
    super.initState();
    _moveToCurrentLocation();
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isMapLoading = false;
        });
        _mapController.move(_currentLocation, 14.0);
      } else {
        setState(() {
          _isMapLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isMapLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isMapLoading
              ? const Center(child: CircularProgressIndicator())
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 10.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.berkay.mushapp',
                    ),
                    MarkerLayer(
                      markers: [
                        // User Current Location Marker
                        Marker(
                          point: _currentLocation,
                          width: 60,
                          height: 60,
                          child: Icon(
                            Icons.my_location,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),
                        // Mock Mushroom Marker
                        Marker(
                          point: LatLng(
                            _currentLocation.latitude + 0.01,
                            _currentLocation.longitude + 0.01,
                          ),
                          width: 80,
                          height: 80,
                          child: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 40,
                              ),
                              const Text(
                                "Mantar!",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

          // Search Bar Placeholder
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Bölge ara...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          // Location Button
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: _moveToCurrentLocation,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.gps_fixed,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          // Info Card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.nature_people,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Yakınlardaki Mantarlar",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text("Şu anki konumuna yakın 3 potansiyel alan var."),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _mantarBadge("Kanlıca 🍄"),
                          _mantarBadge("Kuzu Göbeği 🍄"),
                          _mantarBadge("Sığır Dili 🍄"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mantarBadge(String isim) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        isim,
        style: TextStyle(
          color: Colors.green.shade900,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
