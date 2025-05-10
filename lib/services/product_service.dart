// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Product.dart';

class ProductService {
  static Future<List<Product>> fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/v1/products?page=0&sortBy=price&direction=asc'),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final List<dynamic> productList = jsonBody['content'];
      return productList.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
