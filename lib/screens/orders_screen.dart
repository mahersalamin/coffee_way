import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> orders = [];
  String token = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      try {
        final response = await ApiService().get(
          '/my-orders',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        if (response.statusCode == 200 && response.data['success'] == true) {
          setState(() {
            orders = response.data['data'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        debugPrint('Error fetching orders: $e');
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Widget buildOrderItem(Map<String, dynamic> order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          'الطلب رقم #${order['id']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الحالة: ${order['status']}'),
            Text('الإجمالي: \$${order['total_price']}'),
          ],
        ),
        children: (order['items'] as List).map((item) {
          final itemInfo = item['item'] ?? {};
          return ListTile(
            leading: const Icon(Icons.fastfood),
            title: Text(itemInfo['name'] ?? 'منتج غير معروف'),
            subtitle: Text('الحجم: ${item['size']} × ${item['quantity']}'),
            trailing: Text('\$${item['price']}'),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        backgroundColor: const Color(0xFFFFD700),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token.isEmpty
          ? const Center(
        child: Text(
          'يرجى تسجيل الدخول لعرض طلباتك.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : orders.isEmpty
          ? const Center(
        child: Text(
          'لا توجد طلبات حتى الآن.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return buildOrderItem(orders[index]);
        },
      ),
    );
  }
}
