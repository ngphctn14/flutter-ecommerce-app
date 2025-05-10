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
    return Product(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      image: json['image'],
      description: json['description'],
      specs: json['specs'],
      categoryName: json['categoryName'],
      brandName: json['brandName'],
    );
  }
}
