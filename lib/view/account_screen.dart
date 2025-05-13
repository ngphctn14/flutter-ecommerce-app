import 'package:flutter/material.dart';
import '../../utils/app_textstyles.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Thêm dữ liệu mặc định cho tên và địa chỉ
    _nameController.text = "John Doe"; // Ví dụ
    _addressController.text = "123 Main St"; // Ví dụ
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Thực hiện đăng xuất ở đây
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
            // Thay đổi chế độ sáng/tối
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // Đổi theme tại đây, bạn cần cập nhật trạng thái ứng dụng ngoài màn hình này
                  // Để thay đổi theme t  oàn bộ ứng dụng, bạn cần thực hiện trong MaterialApp ở widget gốc
                },
              ),
            ),
            const SizedBox(height: 20),
            // Nút lưu thay đổi
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
