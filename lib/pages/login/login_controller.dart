import 'package:conference/core/storage/storage.dart';
import 'package:conference/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/api_exception.dart';
import '../../services/http_service.dart';

class LoginController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _storage = StorageService.instance;

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  void togglePasswordVisibility() =>
      obscurePassword.value = !obscurePassword.value;

  Future<void> signIn() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // HttpService now returns only the ResponseBody on success,
      // or throws ApiException on failure.
      final responseBody = await HttpService.instance.login(
        'auth/authenticateUser',
        body: {
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text.trim(),
        },
      );

      if (responseBody != null) {
        _storage.setValue('user', responseBody);
        debugPrint('Login success: $responseBody');
        Get.offAllNamed('/home');
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Unable to connect. Please check your network.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFF6B6B),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(
        Icons.error_outline_rounded,
        color: Colors.white,
        size: 20,
      ),
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onInit() {
    super.onInit();
    emailCtrl.text = 'kumarvivek1502@gmail.com';
    passwordCtrl.text = 'vivekkr';
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
