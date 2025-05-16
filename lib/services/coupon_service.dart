import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Coupon.dart';

class CouponService {
  static Future<List<Coupon>> getCoupons() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/v1/coupon'));
    if (response.statusCode == 200) {
      final List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Coupon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coupons');
    }
  }
}

