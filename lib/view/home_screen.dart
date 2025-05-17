import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/Product.dart';
import '../models/Category.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import 'widgets/sale_banner.dart';
import 'widgets/ProductHorizontalList.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();

  late Future<List<Product>> _latestProductsFuture;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _latestProductsFuture = _getLatestProducts();
    _categoriesFuture = CategoryService.fetchCategories();
  }

  Future<List<Product>> _getLatestProducts() async {
    final allProducts = await ProductService.fetchAllProducts();
    allProducts.sort((a, b) => b.id.compareTo(a.id));
    return allProducts.take(5).toList();
  }

  Widget _buildProductSection(String title, Future<List<Product>> future, {int? categoryId}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ],
          ),
        ),
        FutureBuilder<List<Product>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                  height: 200, child: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return SizedBox(
                height: 100,
                child: Center(child: Text('Error: ${snapshot.error}')),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox(
                  height: 100, child: Center(child: Text('No products available')));
            }
            return ProductHorizontalList(products: snapshot.data!);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = authController.user.value;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ${userData['fullName'] ?? 'User'}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const Text(
                        'Good Morning',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.toNamed('/my-cart'),
                    icon: const Icon(Icons.shopping_cart_outlined),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed('/chat'),
                    icon: const Icon(Icons.chat_bubble),
                  ),
                  GetBuilder<ThemeController>(
                    builder: (controller) => IconButton(
                      onPressed: () => controller.toggleTheme(),
                      icon: Icon(
                        controller.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung chính
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SaleBanner(),

                    _buildProductSection('New Products', _latestProductsFuture),

                    FutureBuilder<List<Category>>(
                      future: _categoriesFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final categories = snapshot.data!;
                        return Column(
                          children: categories.take(5).map((Category cat) {
                            return _buildProductSection(
                              cat.name,
                              ProductService.fetchProductsByCategory(cat.id),
                              categoryId: cat.id,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
