import 'dart:math';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/key_storage_service.dart';
import '../services/email_service.dart';
import '../utils/constants.dart';

class AuthViewModel extends ChangeNotifier {
  final KeyStorageService _keyStorage;
  final EmailService _emailService;
  final LocalAuthentication _auth = LocalAuthentication();
  
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _generatedOtp;
  String? _pendingEmail;
  String? _pendingPassword;

  String? get pendingEmail => _pendingEmail;
  String? get pendingPassword => _pendingPassword;

  AuthViewModel(this._keyStorage, this._emailService);

  Future<void> sendOtp(String email, [String? password]) async {
    _pendingEmail = email;
    _pendingPassword = password;
    
    // Generate 6-digit OTP
    _generatedOtp = (Random().nextInt(900000) + 100000).toString();
    
    // In a real app, you'd send the email here
    // For this demonstration, we'll print it to console too in case SMTP is not configured
    print('Generated OTP for $email: $_generatedOtp');
    
    await _emailService.sendOtpEmail(email, _generatedOtp!);
  }

  Future<void> setPendingPassword(String password) async {
    _pendingPassword = password;
  }

  Future<bool> register(String password) async {
    await _keyStorage.write(AppConstants.userPasswordKey, password);
    if (_pendingEmail != null) {
      await _keyStorage.write(AppConstants.userEmailKey, _pendingEmail!);
    }
    return true;
  }

  Future<bool> isEmailRegistered(String email) async {
    String? savedEmail = await _keyStorage.read(AppConstants.userEmailKey);
    return savedEmail == email;
  }

  Future<bool> verifyOtp(String otp) async {
    if (_generatedOtp != null && otp == _generatedOtp) {
      if (_pendingPassword != null) {
        await register(_pendingPassword!);
      }
      await _keyStorage.write(AppConstants.isUserRegisteredKey, 'true');
      _isAuthenticated = true;
      _generatedOtp = null; // Clear OTP after use
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login(String password) async {
    String? savedPassword = await _keyStorage.read(AppConstants.userPasswordKey);
    if (savedPassword == password) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      bool canCheckBiometrics = await _auth.canCheckBiometrics;
      if (!canCheckBiometrics) return false;

      bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to access CipherTask',
      );

      if (didAuthenticate) {
        _isAuthenticated = true;
        notifyListeners();
      }
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> isRegistered() async {
    String? registered = await _keyStorage.read(AppConstants.isUserRegisteredKey);
    return registered == 'true';
  }
}
