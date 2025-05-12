import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ecommerce_app/view/main_screen.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final _storage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool _isFirstTime = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final Rx<User?> authUser = Rx<User?>(null);

  final Rx<Map<String, dynamic>> user = Rx<Map<String, dynamic>>({});

  bool get isFirstTime => _isFirstTime.value;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    authUser.bindStream(_auth.authStateChanges());

    ever(authUser, (User? user) {
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        this.user.value = {};
      }
    });

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

  void logout() async {
    await _auth.signOut();
    _isLoggedIn.value = false;
    _storage.write('isLoggedIn', false);
    user.value = {};
  }

  Future<void> fetchUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        user.value = userDoc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user data',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data after successful login
      if (userCredential.user != null) {
        await fetchUserData(userCredential.user!.uid);
        login(); // Update login state
        Get.offAll(() => MainScreen());
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Sign In Failed',
        e.message ?? 'An error occurred',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
