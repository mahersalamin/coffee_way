import 'item_size.dart';
import 'category.dart';

class Item {
  final int id;
  final String name;
  final String description;
  final String? imagePath;
  final int categoryId;
  final Category category;
  final List<ItemSize> sizes;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.categoryId,
    required this.category,
    required this.sizes,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imagePath: json['image_path'],
      categoryId: json['category_id'],
      category: Category.fromJson(json['category']),
      sizes: (json['sizes'] as List).map((e) => ItemSize.fromJson(e)).toList(),
    );
  }
}
