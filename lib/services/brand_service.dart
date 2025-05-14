import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Brand.dart';  // Model cho Brand

class BrandService {
  static const String apiUrl = 'http://localhost:8080/api/v1/brand';  // API lấy danh sách brands

  static Future<List<Brand>> fetchBrands() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Brand.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }
}
