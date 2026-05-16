import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
    baseUrl: 'https://mushapp.dev/api', 
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Doğru anahtar: 'auth_token'
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // AUTH
  Future<Response> firebaseAuth(String idToken) async {
    final response = await _dio.post(
      '/auth/firebase/',
      data: {'idToken': idToken},
    );
    
    // Gelen token'ı kaydet (Eğer backend'den bir token dönüyorsa)
    if (response.statusCode == 200 && response.data['token'] != null) {
      await _storage.write(key: 'auth_token', value: response.data['token']);
    } else {
      // Eğer backend token dönmüyorsa direkt Firebase idToken'ını kullan
      await _storage.write(key: 'auth_token', value: idToken);
    }
    
    return response;
  }

  // PROFILE
  Future<Response> getProfile() async {
    return await _dio.get('/profile/');
  }

  // MUSHROOM WIKI & SUGGESTION
  Future<Response> getWikiList() async {
    return await _dio.get('/wiki/');
  }

  Future<Response> getDailyMushroom() async {
    return await _dio.get('/daily/');
  }

  // AI SCANNER
  Future<Response> predictMushroom(String imagePath) async {
    String fileName = imagePath.split('/').last;
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imagePath, filename: fileName),
    });
    return await _dio.post('/predict/', data: formData);
  }

  // USER COLLECTION
  Future<Response> getCollection() async {
    return await _dio.get('/collection/');
  }
}
