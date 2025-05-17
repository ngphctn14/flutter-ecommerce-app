import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/address_dto.dart';
import '../models/auth_service.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final _storage = GetStorage();

  final RxBool _isFirstTime = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<Map<String, dynamic>> user = Rx<Map<String, dynamic>>({});

  String? token;

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialState();

    if (_isLoggedIn.value) {
      token = _storage.read('token');
      fetchUserProfile();
    }
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void loginLocal(String token) {
    this.token = token;
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
    _storage.write('token', token);
  }

  void logout() {
    token = null;
    user.value = {};
    _isLoggedIn.value = false;
    _storage.remove('token');
    _storage.write('isLoggedIn', false);
    Get.offAllNamed('/sigin');
  }

  Future<void> fetchUserProfile() async {
    if (token == null) return;

    try {
      final userData = await AuthService.getUserProfile(token!);
      user.value = userData;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải thông tin người dùng');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final data = await AuthService.login(email: email, password: password);
      final String receivedToken = data['accessToken'] ?? '';

      if (receivedToken.isEmpty) {
        throw Exception('Token không hợp lệ!');
      }
      loginLocal(receivedToken);
      await fetchUserProfile();

      Get.offAllNamed('/');
    } catch (e) {
      Get.snackbar('Lỗi đăng nhập', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    required AddressDTO address,
    File? imageFile,
  }) async {
    try {
      await AuthService.register(
        email: email,
        fullName: fullName,
        password: password,
        address: address,
        imageFile: imageFile,
      );

      Get.snackbar('Thành công', 'Đăng ký thành công. Vui lòng đăng nhập.');
      Get.toNamed('/login');
    } catch (e) {
      Get.snackbar('Lỗi đăng ký', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateUserProfileFromUI({
    required String fullName,
    required String shippingAddress,
  }) async {
    final userId = getUserIdFromToken(token!); // 👈 lấy từ token luôn
    final uri = Uri.parse('http://localhost:8080/api/v1/users/$userId');

    final body = jsonEncode({
      'fullName': fullName,
      'shippingAddress': shippingAddress,
    });

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Cập nhật thất bại: ${response.body}');
    }

    await fetchUserProfile();
  }


  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Token không hợp lệ');
    }

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final payloadMap = json.decode(utf8.decode(base64Url.decode(normalized)));

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('Không thể giải mã payload');
    }

    return payloadMap;
  }
  int getUserIdFromToken(String token) {
    final payload = parseJwt(token);
    final userId = payload['payload']?['userId'];

    if (userId == null) {
      throw Exception('Token không chứa userId');
    }

    return userId;
  }

}
