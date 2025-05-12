import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/controllers/theme_controller.dart';
import 'package:flutter_ecommerce_app/view/cart_screen.dart';
import 'package:flutter_ecommerce_app/view/widgets/category_chips.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_search_bar.dart';
import 'package:flutter_ecommerce_app/view/widgets/product_grid.dart';
import 'package:flutter_ecommerce_app/view/widgets/sale_banner.dart';
import 'package:flutter_ecommerce_app/view/settings_screen.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            //header section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/avatar.jpg'),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello ALex',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        'Good Morning',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  //notification icon
                  IconButton(
                    onPressed: () => Get.to(() => SettingsScreen()),
                    icon: Icon(Icons.notifications),
                  ),
                  //cart button
                  IconButton(
                    onPressed: () => Get.to(() => CartScreen()),
                    icon: Icon(Icons.shopping_bag_outlined),
                  ),
                  //theme button
                  GetBuilder<ThemeController>(
                    builder:
                        (controller) => IconButton(
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
            //search bar
            const CustomSearchBar(),
            //category chips
            const CategoryChips(),
            //sale banner
            const SaleBanner(),
            //popular product
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            //product grid
            Expanded(
              child: FutureBuilder<List<Product>>(
                future: ProductService.fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No products available'));
                  } else {
                    return ProductGrid(products: snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
