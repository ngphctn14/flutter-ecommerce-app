import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/controllers/auth_controller.dart';
import 'package:flutter_ecommerce_app/models/address_dto.dart';
import 'package:flutter_ecommerce_app/utils/app_textstyles.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();

  List<Map<String, dynamic>> _provinces = [], _districts = [], _wards = [];
  Map<String, dynamic>? _selectedProvince, _selectedDistrict, _selectedWard;

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    final String response = await rootBundle.loadString('assets/db/provinces.json');
    final data = await json.decode(response);
    setState(() {
      _provinces = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> _loadDistricts(String provinceCode) async {
    final String response = await rootBundle.loadString('assets/db/districts.json');
    final data = await json.decode(response);
    setState(() {
      _districts = List<Map<String, dynamic>>.from(data)
          .where((d) => d['province_code'] == provinceCode)
          .toList();
      _selectedDistrict = null;
      _wards = [];
      _selectedWard = null;
    });
  }

  Future<void> _loadWards(String districtCode) async {
    final String response = await rootBundle.loadString('assets/db/wards.json');
    final data = await json.decode(response);
    setState(() {
      _wards = List<Map<String, dynamic>>.from(data)
          .where((w) => w['district_code'] == districtCode)
          .toList();
      _selectedWard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  controller: _fullNameController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter your name' : null,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Email',
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Invalid email';
                    }
                    return null;
                  },
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password',
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  controller: _passwordController,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter password' : null,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  onChanged: (_) {},
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedProvince?['code']?.toString(),
                  decoration: const InputDecoration(labelText: 'Province'),
                  items: _provinces.map((e) => DropdownMenuItem<String>(
                    value: e['code'].toString(),
                    child: Text(e['full_name'].toString()),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedProvince =
                          _provinces.firstWhere((e) => e['code'].toString() == val);
                    });
                    _loadDistricts(val!);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDistrict?['code']?.toString(),
                  decoration: const InputDecoration(labelText: 'District'),
                  items: _districts.map((e) => DropdownMenuItem<String>(
                    value: e['code'].toString(),
                    child: Text(e['full_name'].toString()),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDistrict =
                          _districts.firstWhere((e) => e['code'].toString() == val);
                    });
                    _loadWards(val!);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedWard?['code']?.toString(),
                  decoration: const InputDecoration(labelText: 'Ward'),
                  items: _wards.map((e) => DropdownMenuItem<String>(
                    value: e['code'].toString(),
                    child: Text(e['full_name'].toString()),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedWard =
                          _wards.firstWhere((e) => e['code'].toString() == val);
                    });
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Specific Address',
                  prefixIcon: Icons.home,
                  controller: _addressController,
                  validator: (value) =>
                  value!.isEmpty ? 'Enter specific address' : null,
                  onChanged: (_) {},
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('Register'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    final authController = Get.find<AuthController>();

    if (_formKey.currentState!.validate()) {
      final address = AddressDTO(
        province: _selectedProvince?['full_name'],
        provinceCode: _selectedProvince?['code'],
        district: _selectedDistrict?['full_name'],
        districtCode: _selectedDistrict?['code'],
        ward: _selectedWard?['full_name'],
        wardCode: _selectedWard?['code'],
        specificAddress: _addressController.text.trim(),
      );

      await authController.register(
        email: _emailController.text.trim(),
        fullName: _fullNameController.text.trim(),
        password: _passwordController.text.trim(),
        address: address,
      );
    }
  }
}
