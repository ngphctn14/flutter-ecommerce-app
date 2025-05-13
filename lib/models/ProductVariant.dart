import 'dart:convert';

class ProductVariant {
  final int id;
  final String variantName;
  final double priceDiff;
  final Map<String, dynamic> specs;
  final int quantity;
  final List<String> images;

  ProductVariant({
    required this.id,
    required this.variantName,
    required this.priceDiff,
    required this.specs,
    required this.quantity,
    required this.images,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'],
      variantName: json['variantName'],
      priceDiff: json['priceDiff']?.toDouble() ?? 0.0,
      specs: json['specs'] != null ? jsonDecode(json['specs']) : {},
      quantity: json['quantity'],
      images: List<String>.from(json['images']),
    );
  }
}
