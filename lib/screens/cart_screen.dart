import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartService = CartService();
  final apiService = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool isSubmitting = false;

  void submitOrder() async {
    setState(() {
      isSubmitting = true;
    });

    final orderItems = cartService.items.map((e) {
      print(e);
      return {
        'item_id': e['item'].id,
        'size': e['size'].size,
        'quantity': e['quantity'],
      };
    }).toList();

    final orderData = {
      'items': orderItems,
      'name': nameController.text.trim(),
      'mobile': mobileController.text.trim(),
      'note': noteController.text.trim(),
    };

    try {
      final res = await apiService.post('/orders', orderData);

      if (res.statusCode == 200 || res.statusCode == 201) {
        cartService.clearCart();
        nameController.clear();
        mobileController.clear();
        noteController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الطلب بنجاح!')),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting order: $e')),
      );
    }

    setState(() {
      isSubmitting = false;
    });
  }


  void showCustomerDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('معلومات الزبون'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'الإسم'),
              ),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                submitOrder(); // now uses controller values
              },
              child: const Text('طلب'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final items = cartService.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلتك', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFD700),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: items.isEmpty
          ? const Center(child: Text('السلة فارغة'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, index) {
                final entry = items[index];
                final item = entry['item'];
                final size = entry['size'];
                final qty = entry['quantity'];

                return ListTile(
                  title: Text('${item.name} (${size.size})'),
                  subtitle: Text('₪${size.price} x $qty'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        cartService.removeFromCart(item, size);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'المجموع: ${cartService.total.toStringAsFixed(2)}₪',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  onPressed: isSubmitting ? null : showCustomerDetailsDialog,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تقديم الطلب'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
