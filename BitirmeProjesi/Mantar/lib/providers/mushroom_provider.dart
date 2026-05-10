import 'package:flutter/material.dart';
import 'package:mantar/models/mushroom.dart';
import 'package:mantar/services/api_service.dart';

class MushroomProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Mushroom> _mushrooms = [];
  List<UserScan> _collection = [];
  Mushroom? _dailyMushroom;
  bool _isLoading = false;

  List<Mushroom> get mushrooms => _mushrooms;
  List<UserScan> get collection => _collection;
  Mushroom? get dailyMushroom => _dailyMushroom;
  bool get isLoading => _isLoading;

  // --- WIKI ---
  Future<void> fetchWiki() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getWikiList();
      if (response.statusCode == 200) {
        _mushrooms = (response.data as List).map((i) => Mushroom.fromJson(i)).toList();
      }
    } catch (e) {
      print("Error fetching wiki: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- DAILY ---
  Future<void> fetchDaily() async {
    try {
      final response = await _apiService.getDailyMushroom();
      if (response.statusCode == 200) {
        _dailyMushroom = Mushroom.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching daily: $e");
    }
  }

  // --- COLLECTION ---
  Future<void> fetchCollection() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getCollection();
      if (response.statusCode == 200) {
        _collection = (response.data as List).map((i) => UserScan.fromJson(i)).toList();
      }
    } catch (e) {
      print("Error fetching collection: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- PREDICT ---
  Future<Map<String, dynamic>?> predictMushroom(String imagePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.predictMushroom(imagePath);
      if (response.statusCode == 200) {
        // Yeniden koleksiyonu çekelim ki yeni tarama görünsün
        fetchCollection();
        return response.data;
      }
    } catch (e) {
      print("Error in prediction: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }
}
