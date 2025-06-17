import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/item_size.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final CartService cartService = CartService();

  List<Category> categories = [];
  List<Item> items = [];
  int? selectedCategoryId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final catRes = await _apiService.get('/categories');
      final itemRes = await _apiService.get('/items');

      setState(() {
        categories = List<Category>.from(catRes.data['data'].map((c) => Category.fromJson(c)));
        items = List<Item>.from(itemRes.data['data'].map((i) => Item.fromJson(i)));
        selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  List<Item> get filteredItems {
    if (selectedCategoryId == null) return items;
    return items.where((i) => i.categoryId == selectedCategoryId).toList();
  }

  void addToCart(Item item, ItemSize size) {
    cartService.addToCart(item, size);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت الإضافة للسلة!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('كوفي وي - Coffee Way', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFD700),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],

      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((cat) {
                final isSelected = cat.id == selectedCategoryId;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCategoryId = cat.id;
                      });
                    },
                    child: Text(cat.name),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(item.description),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: item.sizes.map((size) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => addToCart(item, size),
                              child: Text('${size.size} - ${size.price} ₪'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
        },
        backgroundColor: const Color(0xFFD32F2F),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('السلة'),
      ),
    );
  }
}
