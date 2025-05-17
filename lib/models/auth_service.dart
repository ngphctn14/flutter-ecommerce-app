import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:8080/api/v1';

  /// Đăng nhập
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // {token, user}
    } else {
      throw Exception('Đăng nhập thất bại: ${response.body}');
    }
  }

  /// Đăng ký (có thể kèm ảnh)
  static Future<void> register({
    required String email,
    required String fullName,
    required String password,
    File? imageFile, required address,
  }) async {
    final uri = Uri.parse('$baseUrl/register/user/');
    final request = http.MultipartRequest('POST', uri);

    request.fields['userCreate'] = jsonEncode({
      'email': email,
      'fullName': fullName,
      'password': password,
    });

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      throw Exception('Đăng ký thất bại: $respStr');
    }
  }

  /// Lấy profile người dùng từ token
  static Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/user'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải thông tin người dùng: ${response.body}');
    }
  }

  /// Đổi mật khẩu
  static Future<void> changePassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change-password/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Đổi mật khẩu thất bại: ${response.body}');
    }
  }

  /// Gửi mã OTP quên mật khẩu
  static Future<void> sendRecoveryOTP(String email) async {
    final uri = Uri.parse('$baseUrl/recovery/password?email=$email');
    final response = await http.post(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể gửi OTP: ${response.body}');
    }
  }

  /// Reset mật khẩu bằng OTP
  static Future<void> resetPasswordByOTP({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
        'otp': otp,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Reset mật khẩu thất bại: ${response.body}');
    }
  }
}
