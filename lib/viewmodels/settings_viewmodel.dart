import 'package:flutter/material.dart';
import '../services/key_storage_service.dart';
import '../utils/constants.dart';

class SettingsViewModel extends ChangeNotifier {
  final KeyStorageService _keyStorage;

  ThemeMode _themeMode = ThemeMode.dark;
  bool _fingerprintEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get fingerprintEnabled => _fingerprintEnabled;

  SettingsViewModel(this._keyStorage) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeStr = await _keyStorage.read(AppConstants.themeModeKey);
    if (themeStr != null) {
      _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    }

    final fingerStr = await _keyStorage.read(AppConstants.fingerprintEnabledKey);
    if (fingerStr != null) {
      _fingerprintEnabled = fingerStr == 'true';
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _keyStorage.write(AppConstants.themeModeKey, isDark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setFingerprintEnabled(bool enabled) async {
    _fingerprintEnabled = enabled;
    await _keyStorage.write(AppConstants.fingerprintEnabledKey, enabled.toString());
    notifyListeners();
  }
}
