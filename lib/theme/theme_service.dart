import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/storage.dart';

class ThemeService extends GetxService {
  static ThemeService get instance => Get.find<ThemeService>();

  final _storage = StorageService.instance;
  final _themeMode = ThemeMode.light.obs; // Default to light mode

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  void _loadThemeFromStorage() {
    final savedTheme = _storage.getValue<String>('theme_mode');
    if (savedTheme == 'dark') {
      _themeMode.value = ThemeMode.dark;
    } else {
      _themeMode.value = ThemeMode.light;
    }
    // Apply the loaded theme immediately
    Get.changeThemeMode(_themeMode.value);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    Get.changeThemeMode(mode);
    await _storage.setValue(
      'theme_mode',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  void toggleTheme() {
    saveThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
  }
}
