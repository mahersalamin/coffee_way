import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    BaseOptions options = BaseOptions(
      baseUrl: /*dotenv.env['API_BASE_URL'] ??*/ 'http://192.168.1.3:8000/api',
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
      headers: {
        'Accept': 'application/json',
      },
    );
    _dio = Dio(options);
  }

  Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  Future<Response> post(String endpoint, dynamic data) async {
    print(data);
    return await _dio.post(endpoint, data: data);
  }

  Future<Response> patch(String endpoint, dynamic data) async {
    return await _dio.patch(endpoint, data: data);
  }
}
