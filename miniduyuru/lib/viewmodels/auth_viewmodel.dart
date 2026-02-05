import 'package:flutter/material.dart';
import 'package:miniduyuru/services/auth_service.dart';
import 'package:miniduyuru/services/fcm_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FcmService _fcmService = FcmService();

  bool isLoading = false;
  String? errorMessage;
  String? userRole;

  AuthViewModel(){
    loadUserRole();
  }

  Future<void> loadUserRole() async{
    final user= _authService.currentUser;
    if (user == null) {
      isLoading = false;
      notifyListeners();
      return;
    }

       final isAdmin = await _authService.isAdmin(user.uid);
    userRole = isAdmin ? 'admin' : 'user';

    await _fcmService.initFCM();

    isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final user = await _authService.signIn(email, password);
      if (user == null) {
        errorMessage = 'Giriş başarısız';
        isLoading = false;
        notifyListeners();
        return;
      }

      final isAdmin=await _authService.isAdmin(user.uid);
      userRole=isAdmin ? 'admin' : 'user';

      await _fcmService.initFCM();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
  await _authService.signOut();
}

}
