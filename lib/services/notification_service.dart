import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isEmpty) return [];

    final response = await _apiService.get(
      '/notifications',
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final List raw = response.data['data'];
      return raw.map((n) => NotificationModel.fromJson(n)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
