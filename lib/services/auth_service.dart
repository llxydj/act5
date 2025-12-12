import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Authentication Service using Firebase Auth
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = ApiService();

  UserModel? _currentUser;

  // Get current Firebase user
  User? get firebaseUser => _auth.currentUser;

  // Get current app user
  UserModel? get currentUser => _currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null && _currentUser != null;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register new user with email and password
  Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      // Create Firebase account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(success: false, message: 'Failed to create account');
      }

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Save user to MySQL database
      final response = await _api.post(
        '${AppConstants.usersEndpoint}/register.php',
        body: {
          'firebase_uid': credential.user!.uid,
          'email': email,
          'name': name,
          'role': role,
          'phone': phone,
          'address': address,
        },
      );

      if (!response.success) {
        // Rollback Firebase account if MySQL fails
        await credential.user!.delete();
        return AuthResult(
          success: false,
          message: response.message ?? 'Failed to save user data',
        );
      }

      // Create user model
      _currentUser = UserModel(
        id: response.data['id']?.toString() ?? '',
        firebaseUid: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        phone: phone,
        address: address,
        createdAt: DateTime.now(),
      );

      // Save to shared preferences
      await _saveUserToPrefs();

      return AuthResult(success: true, user: _currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return AuthResult(success: false, message: 'Login failed');
      }

      // Get user from MySQL database
      final response = await _api.get(
        '${AppConstants.usersEndpoint}/get_user.php',
        queryParams: {'firebase_uid': credential.user!.uid},
      );

      if (!response.success || response.data == null) {
        await _auth.signOut();
        return AuthResult(
          success: false,
          message: response.message ?? 'User not found',
        );
      }

      // Create user model
      _currentUser = UserModel.fromJson(response.data);

      // Save to shared preferences
      await _saveUserToPrefs();

      return AuthResult(success: true, user: _currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult(
        success: true,
        message: 'Password reset email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, message: _getFirebaseError(e.code));
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    await _clearUserFromPrefs();
  }

  /// Check and load stored user
  Future<bool> checkStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(AppConstants.prefIsLoggedIn) ?? false;

    if (!isLoggedIn || firebaseUser == null) {
      return false;
    }

    // Get user from database
    final response = await _api.get(
      '${AppConstants.usersEndpoint}/get_user.php',
      queryParams: {'firebase_uid': firebaseUser!.uid},
    );

    if (response.success && response.data != null) {
      _currentUser = UserModel.fromJson(response.data);
      return true;
    }

    return false;
  }

  /// Update user profile
  Future<AuthResult> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? profileImage,
  }) async {
    if (_currentUser == null) {
      return AuthResult(success: false, message: 'User not logged in');
    }

    try {
      final response = await _api.put(
        '${AppConstants.usersEndpoint}/update_user.php',
        body: {
          'id': _currentUser!.id,
          'name': name ?? _currentUser!.name,
          'phone': phone ?? _currentUser!.phone,
          'address': address ?? _currentUser!.address,
          'profile_image': profileImage ?? _currentUser!.profileImage,
        },
      );

      if (response.success) {
        _currentUser = _currentUser!.copyWith(
          name: name,
          phone: phone,
          address: address,
          profileImage: profileImage,
        );
        await _saveUserToPrefs();
        return AuthResult(success: true, user: _currentUser);
      }

      return AuthResult(
        success: false,
        message: response.message ?? 'Failed to update profile',
      );
    } catch (e) {
      return AuthResult(success: false, message: e.toString());
    }
  }

  // Save user to shared preferences
  Future<void> _saveUserToPrefs() async {
    if (_currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefIsLoggedIn, true);
    await prefs.setString(AppConstants.prefUserId, _currentUser!.id);
    await prefs.setString(AppConstants.prefUserRole, _currentUser!.role);
    await prefs.setString(AppConstants.prefUserEmail, _currentUser!.email);
  }

  // Clear user from shared preferences
  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.prefIsLoggedIn);
    await prefs.remove(AppConstants.prefUserId);
    await prefs.remove(AppConstants.prefUserRole);
    await prefs.remove(AppConstants.prefUserEmail);
  }

  // Get Firebase error message
  String _getFirebaseError(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

/// Authentication Result wrapper
class AuthResult {
  final bool success;
  final UserModel? user;
  final String? message;

  AuthResult({
    required this.success,
    this.user,
    this.message,
  });
}

