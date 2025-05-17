import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ecommerce_app/controllers/auth_controller.dart';
import 'package:flutter_ecommerce_app/controllers/theme_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specificAddressController = TextEditingController();
  File? _selectedImage;

  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];

  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedWard;

  @override
  void initState() {
    super.initState();
    final userData = authController.user.value;
    _nameController.text = userData['fullName'] ?? '';
    if (userData['addresses'] != null && userData['addresses'].isNotEmpty) {
      final addr = userData['addresses'][0];
      _specificAddressController.text = addr['addressDetail'] ?? '';
    }
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final data = await rootBundle.loadString('assets/db/provinces.json');
    setState(() => _provinces = List<Map<String, dynamic>>.from(json.decode(data)));
  }

  Future<void> _loadDistricts(String provinceCode) async {
    final data = await rootBundle.loadString('assets/db/districts.json');
    final allDistricts = List<Map<String, dynamic>>.from(json.decode(data));
    setState(() => _districts = allDistricts.where((d) => d['province_code'] == provinceCode).toList());
  }

  Future<void> _loadWards(String districtCode) async {
    final data = await rootBundle.loadString('assets/db/wards.json');
    final allWards = List<Map<String, dynamic>>.from(json.decode(data));
    setState(() => _wards = allWards.where((w) => w['district_code'] == districtCode).toList());
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _saveChanges() async {
    if (_selectedProvince == null || _selectedDistrict == null || _selectedWard == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn đầy đủ địa chỉ');
      return;
    }

    final formattedAddress =
        '${_specificAddressController.text.trim()}, ${_selectedWard!['full_name']}, ${_selectedDistrict!['full_name']}, ${_selectedProvince!['full_name']}';
    print(formattedAddress);

    try {
      await authController.updateUserProfileFromUI(
        fullName: _nameController.text.trim(),
        shippingAddress: formattedAddress,
      );
      Get.snackbar('Thành công', 'Cập nhật thông tin thành công');
    } catch (e) {
      Get.snackbar('Lỗi', 'Cập nhật thất bại: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    final userData = authController.user.value;
    final imageUrl = userData['image'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Account Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (imageUrl != null ? NetworkImage(imageUrl) : null) as ImageProvider?,
                  child: _selectedImage == null && imageUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Province', border: OutlineInputBorder()),
              value: _selectedProvince?['code'],
              items: _provinces.map((province) {
                return DropdownMenuItem<String>(
                  value: province['code'],
                  child: Text(province['full_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProvince = _provinces.firstWhere((p) => p['code'] == value);
                  _selectedDistrict = null;
                  _selectedWard = null;
                  _districts.clear();
                  _wards.clear();
                });
                _loadDistricts(value!);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'District', border: OutlineInputBorder()),
              value: _selectedDistrict?['code'],
              items: _districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district['code'],
                  child: Text(district['full_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = _districts.firstWhere((d) => d['code'] == value);
                  _selectedWard = null;
                  _wards.clear();
                });
                _loadWards(value!);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Ward', border: OutlineInputBorder()),
              value: _selectedWard?['code'],
              items: _wards.map((ward) {
                return DropdownMenuItem<String>(
                  value: ward['code'],
                  child: Text(ward['full_name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedWard = _wards.firstWhere((w) => w['code'] == value));
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specificAddressController,
              decoration: const InputDecoration(labelText: 'Specific Address', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            GetBuilder<ThemeController>(
              builder: (controller) => ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: controller.isDarkMode,
                  onChanged: (bool value) => controller.toggleTheme(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

}

