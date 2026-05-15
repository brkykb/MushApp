import 'package:flutter/material.dart';
import 'package:mantar/models/mushroom.dart';
import 'package:mantar/services/api_service.dart';

class MushroomProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Mushroom> _mushrooms = [];
  List<Mushroom> _history = [];
  Mushroom? _dailyMushroom;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  List<Mushroom> get mushrooms => _mushrooms;
  List<Mushroom> get history => _history;
  Mushroom? get dailyMushroom => _dailyMushroom;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile() async {
    try {
      final response = await _apiService.getProfile();
      if (response.statusCode == 200) {
        _userProfile = response.data;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> fetchDailyMushroom() async {
    try {
      final response = await _apiService.getDailyMushroom();
      if (response.statusCode == 200) {
        _dailyMushroom = Mushroom.fromJson(response.data);
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching daily mushroom: $e");
    }
  }

  Future<void> fetchMushrooms() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getWikiList();
      if (response.statusCode == 200) {
        _mushrooms = (response.data as List)
            .map((i) => Mushroom.fromJson(i))
            .toList();
      }
    } catch (e) {
      print("Error fetching mushrooms: $e");
      // Fallback to mock if API fails
      _mushrooms = mockMushrooms;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getCollection();
      if (response.statusCode == 200) {
        _history = (response.data as List)
            .map((i) => Mushroom.fromJson(i['mushroom_details'] ?? i))
            .toList();
      }
    } catch (e) {
      print("Error fetching history: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
