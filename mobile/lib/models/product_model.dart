class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  final int quantity;
  final String provider;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.quantity,
    required this.provider,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      provider: json['provider'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'quantity': quantity,
      'provider': provider,
    };
  }
}
