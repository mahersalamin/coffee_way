// models/notification_model.dart

class NotificationModel {
  final String id;
  // final String title;
  // final String body;
  final String orderId;
  final String status;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    // required this.title,
    // required this.body,
    required this.orderId,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      orderId: json['data']['order_id'].toString(),
      status: json['data']['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
