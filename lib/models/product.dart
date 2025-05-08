class Product {
  final String name;
  final String category;
  final double price;
  final double? oldPrice;
  final String imageUrl;
  final bool isFavorite;
  final String desciption;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.desciption,
    this.oldPrice,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      category: json['category'],
      price: json['price'].toDouble(),
      oldPrice: json['oldPrice'] != null ? json['oldPrice'].toDouble() : null,
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? false,
      desciption: json['desciption'],
    );
  }
}
