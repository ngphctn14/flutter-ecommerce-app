import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce_app/view/main_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool _isFirstTime = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<User?> user = Rx<User?>(null);

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    user.bindStream(_auth.authStateChanges());
    super.onInit();
    _loadInitialState();
  }

  void _loadInitialState() {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;
    _isLoggedIn.value = _storage.read('isLoggedIn') ?? false;
  }

  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  void login() {
    _isLoggedIn.value = true;
    _storage.write('isLoggedIn', true);
  }

  void logout() {
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => MainScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign In Failed',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
