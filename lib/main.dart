import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_ecommerce_app/controllers/navigation_controller.dart';
import 'package:flutter_ecommerce_app/controllers/auth_controller.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:flutter_ecommerce_app/controllers/theme_controller.dart';
import 'package:flutter_ecommerce_app/firebase_options.dart';
import 'package:flutter_ecommerce_app/utils/app_themes.dart';
import 'package:flutter_ecommerce_app/view/cart_screen.dart';
import 'package:flutter_ecommerce_app/view/forgot_password_screen.dart';
import 'package:flutter_ecommerce_app/view/main_screen.dart';
import 'package:flutter_ecommerce_app/view/my_orders_screen.dart';
import 'package:flutter_ecommerce_app/view/onboarding_screen.dart';
import 'package:flutter_ecommerce_app/view/signin_screen.dart';
import 'package:flutter_ecommerce_app/view/signup_screen.dart';
import 'package:flutter_ecommerce_app/view/splash_screen.dart';
import 'package:flutter_ecommerce_app/view/shopping_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  usePathUrlStrategy();
  Get.put(ThemeController());
  Get.put(NavigationController());
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce App',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      initialRoute: '/splash', // Add a named route for SplashScreen
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/welcome', page: () => OnboardingScreen()),
        GetPage(name: '/signin', page: () => SignInScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/forgot-password', page: () => ForgotPasswordScreen()),
        GetPage(name: '/', page: () => MainScreen()),
        GetPage(name: '/my-cart', page: () => CartScreen()),
        GetPage(name: '/shopping', page: () => ShoppingScreen()),
        // GetPage(name: '/chat', page: () => ChatScreen()),
      ],
    );
  }
}
