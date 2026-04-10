import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthViewModel() {
    _repository.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          _currentUser = await _repository.getUserData(user.uid);
          notifyListeners();
        } catch (e) {
          _currentUser = null;
          notifyListeners();
        }
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _error = null;
      _currentUser = await _repository.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signup(String email, String password, String username) async {
    try {
      _setLoading(true);
      _error = null;
      _currentUser = await _repository.signup(email, password, username);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _repository.logout();
    _currentUser = null;
    _setLoading(false);
  }

  Future<void> updateProfilePhoto(String newUrl) async {
    if (_currentUser == null) return;
    try {
      _setLoading(true);
      await _repository.updateProfilePhoto(_currentUser!.id, newUrl);
      // Yerel cache'i güncelle
      _currentUser = UserModel(
        id: _currentUser!.id,
        email: _currentUser!.email,
        username: _currentUser!.username,
        profilePhotoUrl: newUrl,
        favoriteGenres: _currentUser!.favoriteGenres,
        followersCount: _currentUser!.followersCount,
        followingCount: _currentUser!.followingCount,
        streakDays: _currentUser!.streakDays,
        lastActiveDate: _currentUser!.lastActiveDate,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
