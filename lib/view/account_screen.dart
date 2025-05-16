import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ecommerce_app/controllers/auth_controller.dart';
import 'package:flutter_ecommerce_app/controllers/theme_controller.dart';  // Import ThemeController

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    Map<String, dynamic> userData = authController.user.value;

    _nameController.text = userData['fullName'] ?? "John Doe";
    _addressController.text = formatAddress(userData['address']);
  }

  String formatAddress(Map<String, dynamic> address) {
    if (address != null) {
      return '${address['specificAddress']} ${address['ward']} ${address['district']} ${address['province']}';
    }
    return "TDTU";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Thực hiện đăng xuất
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Nhập tên
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Nhập địa chỉ
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Sử dụng GetBuilder để thay đổi chế độ sáng/tối
            GetBuilder<ThemeController>(
              builder: (controller) => ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: controller.isDarkMode,
                  onChanged: (bool value) {
                    controller.toggleTheme(); // Thay đổi chế độ theme
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text;
                final address = _addressController.text;
                print('Name: $name, Address: $address');
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
