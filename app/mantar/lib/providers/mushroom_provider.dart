import 'package:flutter/material.dart';
import 'package:mantar/models/mushroom.dart';
import 'package:mantar/services/api_service.dart';

class MushroomProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Mushroom> _mushrooms = [];
  List<Mushroom> _history = [];
  bool _isLoading = false;

  List<Mushroom> get mushrooms => _mushrooms;
  List<Mushroom> get history => _history;
  bool get isLoading => _isLoading;

  Future<void> fetchMushrooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      // For now using mock data if error occurs or while developing
      // final response = await _apiService.getMushrooms();
      // _mushrooms = (response.data as List).map((i) => Mushroom.fromJson(i)).toList();

      // FALLBACK TO MOCK FOR NOW
      _mushrooms = mockMushrooms;
    } catch (e) {
      print("Error fetching mushrooms: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      // final response = await _apiService.getScannedHistory();
      // _history = ...
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
