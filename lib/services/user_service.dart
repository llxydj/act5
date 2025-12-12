import '../config/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// User Service for user management (admin functions)
class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiService _api = ApiService();

  /// Get all users (admin only)
  Future<List<UserModel>> getAllUsers({String? role}) async {
    try {
      final queryParams = <String, String>{};
      if (role != null) queryParams['role'] = role;

      final response = await _api.get(
        '${AppConstants.usersEndpoint}/get_all_users.php',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.success && response.data != null) {
        final List<dynamic> usersJson =
            response.data is List ? response.data : response.data['users'] ?? [];
        return usersJson.map((u) => UserModel.fromJson(u)).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _api.get(
        '${AppConstants.usersEndpoint}/get_user_by_id.php',
        queryParams: {'id': userId},
      );

      if (response.success && response.data != null) {
        return UserModel.fromJson(response.data);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Update user role (admin only)
  Future<UserResult> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _api.put(
        '${AppConstants.usersEndpoint}/update_user_role.php',
        body: {
          'id': userId,
          'role': role,
        },
      );

      if (response.success) {
        return UserResult(
          success: true,
          message: 'User role updated successfully',
        );
      }

      return UserResult(
        success: false,
        message: response.message ?? 'Failed to update user role',
      );
    } catch (e) {
      return UserResult(success: false, message: e.toString());
    }
  }

  /// Delete user (admin only)
  Future<UserResult> deleteUser(String userId) async {
    try {
      final response = await _api.delete(
        '${AppConstants.usersEndpoint}/delete_user.php?id=$userId',
      );

      if (response.success) {
        return UserResult(
          success: true,
          message: 'User deleted successfully',
        );
      }

      return UserResult(
        success: false,
        message: response.message ?? 'Failed to delete user',
      );
    } catch (e) {
      return UserResult(success: false, message: e.toString());
    }
  }

  /// Get admin statistics
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final response = await _api.get(
        '${AppConstants.usersEndpoint}/get_admin_stats.php',
      );

      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }

      return {
        'total_users': 0,
        'total_sellers': 0,
        'total_buyers': 0,
        'total_products': 0,
        'total_orders': 0,
        'total_revenue': 0.0,
      };
    } catch (e) {
      return {
        'total_users': 0,
        'total_sellers': 0,
        'total_buyers': 0,
        'total_products': 0,
        'total_orders': 0,
        'total_revenue': 0.0,
      };
    }
  }
}

/// User Result wrapper
class UserResult {
  final bool success;
  final String? message;
  final UserModel? user;

  UserResult({
    required this.success,
    this.message,
    this.user,
  });
}

