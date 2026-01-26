import 'package:flutter/material.dart';
import 'package:miniduyuru/services/auth_service.dart';
import 'package:miniduyuru/services/fcm_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FcmService _fcmService = FcmService();

  bool isLoading = false;
  String? errorMessage;
  String? userRole;

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = await _authService.signIn(email, password);
      if (user == null) {
        errorMessage = 'Giriş başarısız';
        return;
      }
      userRole = await _authService.getUserRole(user.uid);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
    await _fcmService.initFCM();
  }
}
