import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // Not: iOS simülatörü için 127.0.0.1, Android emülatörü için 10.0.2.2 kullanılır.
      // Her ikisinde de çalışması için bilgisayarın yerel IP'sini yazmak en iyisidir.
      baseUrl: 'http://127.0.0.1:8000/api', 
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
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
      ),
    );
  }

  // --- MUSHROOM WIKI ---
  Future<Response> getWikiList() async {
    return await _dio.get('/wiki/');
  }

  Future<Response> getDailyMushroom() async {
    return await _dio.get('/daily/');
  }

  // --- COLLECTION (GEÇMİŞ) ---
  Future<Response> getCollection() async {
    return await _dio.get('/collection/');
  }

  // --- AI PREDICTION ---
  Future<Response> predictMushroom(String imagePath) async {
    String fileName = imagePath.split('/').last;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });
    return await _dio.post('/predict/', data: formData);
  }

  // --- AUTH (İleride gerekirse) ---
  Future<Response> login(String username, String password) async {
    return await _dio.post('/token/', data: {'username': username, 'password': password});
  }
}
