import 'CartItemResponse.dart';

class CartResponse {
  final int id;
  final String? userId;
  final String? sessionId;
  final List<CartItemResponse> cartItemResponseList;
  final double totalPrice;

  CartResponse({
    required this.id,
    this.userId,
    this.sessionId,
    required this.cartItemResponseList,
    required this.totalPrice,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var list = json['cartItemResponseList'] as List;
    List<CartItemResponse> items = list.map((i) => CartItemResponse.fromJson(i)).toList();

    return CartResponse(
      id: json['id'],
      userId: json['userId'],
      sessionId: json['sessionId'],
      cartItemResponseList: items,
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }
}
