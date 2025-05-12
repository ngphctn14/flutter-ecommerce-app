import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_ecommerce_app/utils/app_textstyles.dart';
import 'package:flutter_ecommerce_app/view/signin_screen.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_textfield.dart';
import 'package:get/get.dart';
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  int _currentStep = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // User Info Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Address Info
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _wards = [];

  Map<String, dynamic>? _selectedProvince;
  Map<String, dynamic>? _selectedDistrict;
  Map<String, dynamic>? _selectedWard;

  final TextEditingController _specificAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/db/provinces.json',
      );
      final data = await json.decode(response);
      setState(() {
        _provinces = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load provinces: $e');
    }
  }

  Future<void> _loadDistricts() async {
    if (_selectedProvince == null) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/db/districts.json',
      );
      final allDistricts = List<Map<String, dynamic>>.from(
        json.decode(response),
      );

      setState(() {
        _districts =
            allDistricts
                .where(
                  (district) =>
                      district['province_code'] == _selectedProvince!['code'],
                )
                .toList();
        _selectedDistrict = null;
        _wards = [];
        _selectedWard = null;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load districts: $e');
    }
  }

  Future<void> _loadWards() async {
    if (_selectedDistrict == null) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/db/wards.json',
      );
      final allWards = List<Map<String, dynamic>>.from(json.decode(response));

      setState(() {
        _wards =
            allWards
                .where(
                  (ward) => ward['district_code'] == _selectedDistrict!['code'],
                )
                .toList();
        _selectedWard = null;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load wards: $e');
    }
  }

  void _continueStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedProvince != null &&
          _selectedDistrict != null &&
          _selectedWard != null &&
          _specificAddressController.text.isNotEmpty) {
        // All address fields are filled
        _handleSignUp();
      } else {
        Get.snackbar('Error', 'Please complete your address information');
      }
    }
  }

  void _cancelStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: AppTextStyle.withColor(
            AppTextStyle.h1,
            Theme.of(context).textTheme.bodyLarge!.color!,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _continueStep,
        onStepCancel: _cancelStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(
                      'Back',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final querySnapshot =
                        await _firestore
                            .collection('users')
                            .where(
                              'email',
                              isEqualTo: _emailController.text.trim(),
                            )
                            .limit(1)
                            .get();

                    if (querySnapshot.docs.isNotEmpty) {
                      Get.snackbar('Error', 'This email is already registered');
                      return;
                    } else {
                      details.onStepContinue!();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep < 1 ? 'Next' : 'Finish',
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: Text(
              'Account',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodySmall!.color!,
              ),
            ),
            isActive: _currentStep >= 0,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Your account information',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyLarge,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    controller: _fullNameController,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Please enter your full name'
                                : null,
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
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
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator:
                        (value) => value!.isEmpty ? 'Enter password' : null,
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
                        return 'Confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    onChanged: (_) {},
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text(
              'Adddress',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodySmall!.color!,
              ),
            ),
            isActive: _currentStep >= 1,
            content: Column(
              children: [
                Text(
                  'Your address information so we can deliver your order',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Province',
                    labelStyle: AppTextStyle.withColor(
                      AppTextStyle.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedProvince?['code'] as String?,
                  items:
                      _provinces.map((province) {
                        return DropdownMenuItem<String>(
                          value: province['code'] as String,
                          child: Text(
                            province['full_name'] as String,
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodyMedium,
                              Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvince = _provinces.firstWhere(
                        (province) => province['code'] == value,
                      );
                    });
                    _loadDistricts();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'District',
                    labelStyle: AppTextStyle.withColor(
                      AppTextStyle.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedDistrict?['code'] as String?,
                  items:
                      _districts.map((district) {
                        return DropdownMenuItem<String>(
                          value: district['code'] as String,
                          child: Text(
                            district['full_name'] as String,
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodyMedium,
                              Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = _districts.firstWhere(
                        (district) => district['code'] == value,
                      );
                    });
                    _loadWards();
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Ward',
                    labelStyle: AppTextStyle.withColor(
                      AppTextStyle.labelMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: _selectedWard?['code'],
                  items:
                      _wards.map((ward) {
                        return DropdownMenuItem<String>(
                          value: ward['code'] as String,
                          child: Text(
                            ward['full_name'] as String,
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodyMedium,
                              Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWard = _wards.firstWhere(
                        (ward) => ward['code'] == value,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Specific Address',
                  prefixIcon: Icons.home_outlined,
                  controller: _specificAddressController,
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Enter your specific address' : null,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // If email doesn't exist, proceed with registration
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid, // Store UID for easy reference
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(), // Add timestamp
          'address': {
            'province': _selectedProvince?['full_name'],
            'provinceCode': _selectedProvince?['code'],
            'district': _selectedDistrict?['full_name'],
            'districtCode': _selectedDistrict?['code'],
            'ward': _selectedWard?['full_name'],
            'wardCode': _selectedWard?['code'],
            'specificAddress': _specificAddressController.text.trim(),
          },
        });

        Get.snackbar('Success', 'Registration successful!');
        Get.offNamed('/signin');
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'An error occurred';
        if (e.code == 'email-already-in-use') {
          errorMessage = 'This email is already registered';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'The email address is not valid';
        }
        Get.snackbar('Error', errorMessage);
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred');
      }
    }
  }
}
