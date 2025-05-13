import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Product.dart';

class ProductService {
  static Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse(
        'http://localhost:8080/api/v1/products?page=0&sortBy=price&direction=asc'));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      return _extractProducts(data);
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse(
        'http://localhost:8080/api/v1/category/products/$categoryId?page=0&sortBy=price&direction=asc'));

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      return _extractProducts(data);
    } else {
      throw Exception('Failed to load products for the category');
    }
  }

  static List<Product> _extractProducts(dynamic json) {
    if (json is List) {
      return json.map((e) => Product.fromJson(e)).toList();
    } else if (json is Map<String, dynamic> && json.containsKey('content')) {
      return (json['content'] as List).map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Invalid product data format');
    }
  }
}
