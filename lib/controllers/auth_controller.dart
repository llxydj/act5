import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Auth Controller for state management
class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';
  bool get isSeller => _user?.role == 'seller';
  bool get isBuyer => _user?.role == 'buyer';

  /// Initialize - check for stored user
  Future<bool> initialize() async {
    _isLoading = true;
    notifyListeners();

    final hasUser = await _authService.checkStoredUser();
    if (hasUser) {
      _user = _authService.currentUser;
    }

    _isLoading = false;
    notifyListeners();
    return hasUser;
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.register(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
      address: address,
    );

    _isLoading = false;

    if (result.success) {
      _user = result.user;
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result.success) {
      _user = result.user;
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.sendPasswordResetEmail(email);

    _isLoading = false;

    if (!result.success) {
      _error = result.message;
    }

    notifyListeners();
    return result.success;
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  /// Update profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.updateProfile(
      name: name,
      phone: phone,
      address: address,
      profileImage: profileImage,
    );

    _isLoading = false;

    if (result.success) {
      _user = result.user;
      notifyListeners();
      return true;
    } else {
      _error = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

