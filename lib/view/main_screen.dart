import 'package:flutter/material.dart';

import 'package:flutter_ecommerce_app/view/shopping_screen.dart';
import 'package:flutter_ecommerce_app/view/widgets/custom_bottoom_navbar.dart';
import 'package:flutter_ecommerce_app/view/wishlist_screen.dart';
import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/theme_controller.dart';
import 'account_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find<NavigationController>();

    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Obx(
                () => IndexedStack(
              key: ValueKey(navigationController.currentIndex.value),
              index: navigationController.currentIndex.value,
              children: const [
                HomeScreen(),
                ShoppingScreen(),
                WishlistScreen(),
                AccountScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNavbar(),
      ),
    );

  }
}
