import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Rating.dart';

class RatingService {
  static const String _baseUrl = 'http://localhost:8080/api/v1';

  static Future<List<Rating>> fetchRatings(int productId) async {
    final url = Uri.parse('$_baseUrl/ratings/$productId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch ratings');
    }
  }
}
