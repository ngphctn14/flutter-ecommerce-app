class CartItemResponse {
  final int id;
  final int productVariantId;
  final String productName;
  final String image;
  final int quantity;
  final double price;

  CartItemResponse({
    required this.id,
    required this.productVariantId,
    required this.productName,
    required this.image,
    required this.quantity,
    required this.price,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      id: json['id'] ?? 0, // hoặc ném lỗi nếu null
      productVariantId: json['productVariantId'] ?? 0,
      productName: json['productName'] ?? '',
      image: json['image'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
