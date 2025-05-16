import 'package:flutter/material.dart';
import 'package:flutter_ecommerce_app/controllers/auth_controller.dart';
import 'package:flutter_ecommerce_app/controllers/theme_controller.dart';
import 'package:flutter_ecommerce_app/view/cart_screen.dart';
import 'package:flutter_ecommerce_app/view/my_orders_screen.dart';
import 'package:flutter_ecommerce_app/view/widgets/category_chips.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_search_bar.dart';
import 'package:flutter_ecommerce_app/view/widgets/product_grid.dart';
import 'package:flutter_ecommerce_app/view/widgets/sale_banner.dart';
import 'package:flutter_ecommerce_app/view/settings_screen.dart';
import 'package:get/get.dart';

import '../models/Category.dart';
import '../models/Product.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  int selectedCategoryId = 0;
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = authController.user.value;
    print('User Data: $userData');
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
                        'Hello ${userData['fullName'] ?? 'User'}',
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
                    onPressed: () => Get.toNamed('/my-orders'),
                    icon: Icon(Icons.notifications),
                  ),
                  //cart button
                  IconButton(
                    onPressed: () => Get.toNamed('/my-cart'),
                    icon: Icon(Icons.shopping_cart_outlined),
                  ),
                  //chat button
                  IconButton(
                    onPressed: () => Get.toNamed('/my-cart'),
                    icon: Icon(Icons.chat_bubble),
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
                  // GestureDetector(
                  //   onTap: () {},
                  //   child: Text(
                  //     'See All',
                  //     style: TextStyle(color: Theme.of(context).primaryColor),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
