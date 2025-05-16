class Coupon {
  final int id;
  final String code;
  final double discountPrice;
  final int quantity;
  final bool active;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPrice,
    required this.quantity,
    required this.active,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountPrice: (json['discountPrice'] ?? 0).toDouble(),
      quantity: json['quantity'],
      active: json['active'],
    );
  }
}
