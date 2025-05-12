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

final List<Product> products = [
  const Product(
    name: 'Product 1',
    category: 'Category 1',
    price: 14999999,
    oldPrice: 39999,
    imageUrl: 'assets/images/shoe.jpg',
    desciption: 'Description of Product 1',
  ),
  const Product(
    name: 'Product 1',
    category: 'Category 1',
    price: 14999999,
    oldPrice: 39999,
    isFavorite: true,
    imageUrl: 'assets/images/shoe.jpg',
    desciption: 'Description of Product 1',
  ),
  const Product(
    name: 'Product 1',
    category: 'Category 1',
    price: 29999,
    oldPrice: 39999,
    isFavorite: true,
    imageUrl: 'assets/images/shoe.jpg',
    desciption: 'Description of Product 1',
  ),
];
