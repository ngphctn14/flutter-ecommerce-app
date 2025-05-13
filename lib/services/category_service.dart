import 'dart:convert';

import '../models/Category.dart';
import "package:http/http.dart" as http show get;
import '../models/Product.dart';

class CategoryService {
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/v1/category'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
