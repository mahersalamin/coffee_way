class ItemSize{
  final int id;
  final int itemId;
  final String size;
  final double price;

  ItemSize({required this.id, required this.itemId, required this.size, required this.price});

  factory ItemSize.fromJson(Map<String, dynamic> json){
    return ItemSize(
        id: json['id'],
        itemId: json['itemId'],
        size: json['size'],
        price: json['price']
    );
  }
}