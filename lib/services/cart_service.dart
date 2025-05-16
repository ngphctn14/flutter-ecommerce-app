import 'dart:convert';
import 'package:flutter_ecommerce_app/services/session_service.dart';
import 'package:http/http.dart' as http;
import '../models/CartResponse.dart';

class CartService {
  static const String _baseUrl = 'http://localhost:8080'; //
  static Future<CartResponse?> getCart() async {
    final sessionId = await SessionManager.getOrCreateSessionId();

    final url = Uri.parse('$_baseUrl/api/v1/cart?sessionId=$sessionId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return CartResponse.fromJson(json);
    } else {
      print('Get cart failed: ${response.body}');
      return null;
    }
  }
  static Future<bool> addToCart(int productId, int quantity) async {
    final url = Uri.parse('http://localhost:8080/api/v1/cart/add');
    final sessionId = await SessionManager.getOrCreateSessionId();

    final body = jsonEncode({
      'productVariantId': productId,
      'quantity': quantity,
      'sessionId': sessionId,  
    });

    print('🔹 Request JSON body: $body');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        //'sessionId': sessionId, // Không nên để sessionId ở header, backend đang lấy từ body
      },
      body: body,
    );

    print('🔹 Status: ${response.statusCode}');
    print('🔹 Body: ${response.body}');

    return response.statusCode == 200;
  }
  static Future<bool> updateQuantity(int cartItemId, int newQuantity) async {
    final sessionId = await SessionManager.getOrCreateSessionId();

    final url = Uri.parse('$_baseUrl/api/v1/cart/$cartItemId?sessionId=$sessionId');

    final body = jsonEncode({
      'quantity': newQuantity,
    });

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      print('✅ Updated quantity');
      return true;
    } else {
      print('❌ Failed to update quantity: ${response.body}');
      return false;
    }
  }
  static Future<bool> deleteItem(int cartItemId) async {
    final sessionId = await SessionManager.getOrCreateSessionId();

    final url = Uri.parse('$_baseUrl/api/v1/cart/$cartItemId?sessionId=$sessionId');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('🗑️ Deleted cart item');
      return true;
    } else {
      print('❌ Failed to delete cart item: ${response.body}');
      return false;
    }
  }



}
