import 'Product.dart';

class Brand {
  final int id;
  final String name;
  final List<Product> products;

  Brand({
    required this.id,
    required this.name,
    required this.products,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      products: (json['products'] as List)
          .map((e) => Product.fromJson(e)) // Assuming you have Product model
          .toList(),
    );
  }
}
