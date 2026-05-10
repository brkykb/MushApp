import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api', // Emulator local address
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          // Handle global errors like 401 Unauthorized
          if (e.response?.statusCode == 401) {
            // Trigger logout or token refresh
          }
          return handler.next(e);
        },
      ),
    );
  }

  // AUTH
  Future<Response> login(String username, String password) async {
    return await _dio.post(
      '/token/',
      data: {'username': username, 'password': password},
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/register/', data: data);
  }

  // MUSHROOMS
  Future<Response> getMushrooms() async {
    return await _dio.get('/mushrooms/');
  }

  Future<Response> getNearbyMushrooms(double lat, double lng) async {
    return await _dio.get(
      '/mushrooms/nearby/',
      queryParameters: {'lat': lat, 'lng': lng},
    );
  }

  // AI SCANNER
  Future<Response> predictMushroom(String imagePath) async {
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath),
    });
    return await _dio.post('/mushrooms/predict/', data: formData);
  }

  // HISTORY
  Future<Response> getScannedHistory() async {
    return await _dio.get('/mushrooms/history/');
  }
}
