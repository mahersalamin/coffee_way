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
        }
      } catch (e) {
        debugPrint('Error fetching orders: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : token.isEmpty
          ? const Center(child: Text('Please log in to view your orders.'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ExpansionTile(
              title: Text('Order #${order['id']} - ${order['status']}'),
              subtitle: Text('Total: \$${order['total_price']}'),
              children: (order['items'] as List).map((item) {
                final itemInfo = item['item'] ?? {};
                return ListTile(
                  title: Text('${itemInfo['name'] ?? 'Unnamed Item'}'),
                  subtitle: Text('Size: ${item['size']} x${item['quantity']}'),
                  trailing: Text('\$${item['price']}'),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

