class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String? description;
  final String specs;
  final String categoryName;
  final String brandName;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.description,
    required this.specs,
    required this.categoryName,
    required this.brandName,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['id'],
        name: json['name'],
        price: _parsePrice(json['price']),
        image: json['image'],
        description: json['description'],
        specs: json['specs'],
        categoryName: json['categoryName'] ?? 'Unknown',
        brandName: json['brandName'] ?? 'Unknown',
      );
    } catch (e, stack) {
      print('Error parsing product: $e');
      print(stack);
      rethrow;
    }
  }



  // Hàm để xử lý giá trị price (xử lý dạng khoa học)
  static double _parsePrice(dynamic price) {
    if (price is num) {
      return price.toDouble();
    } else if (price is String) {
      try {
        return double.parse(price);
      } catch (e) {
        print('Error parsing price: $e');
        return 0.0; // Trả về 0 nếu không thể chuyển đổi
      }
    }
    return 0.0;
  }
}
