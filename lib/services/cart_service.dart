import '../models/item.dart';
import '../models/item_size.dart';

class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() => _instance;

  CartService._internal();

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addToCart(Item item, ItemSize size) {
    final existing = _items.firstWhere(
          (e) => e['item'].id == item.id && e['size'].id == size.id,
      orElse: () => {},
    );
    if (existing.isNotEmpty) {
      existing['quantity'] += 1;
    } else {
      _items.add({'item': item, 'size': size, 'quantity': 1});
    }
  }

  void removeFromCart(Item item, ItemSize size) {
    _items.removeWhere(
            (e) => e['item'].id == item.id && e['size'].id == size.id);
  }

  void clearCart() {
    _items.clear();
  }

  double get total => _items.fold(0.0, (sum, e) => sum + double.parse(e['size'].price) * e['quantity']);
}
