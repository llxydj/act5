import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/helpers.dart';

/// Manage Users Screen for Admin
class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UserModel> _allUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _allUsers = await UserService().getAllUsers();
    setState(() => _isLoading = false);
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    final result = await UserService().updateUserRole(
      userId: userId,
      role: newRole,
    );

    if (mounted) {
      if (result.success) {
        Helpers.showSnackBar(
          context,
          'User role updated successfully',
          isSuccess: true,
        );
        _loadUsers();
      } else {
        Helpers.showSnackBar(
          context,
          result.message ?? 'Failed to update role',
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Delete User',
      message:
          'Are you sure you want to delete this user? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirm) {
      final result = await UserService().deleteUser(userId);

      if (mounted) {
        if (result.success) {
          Helpers.showSnackBar(
            context,
            'User deleted successfully',
            isSuccess: true,
          );
          _loadUsers();
        } else {
          Helpers.showSnackBar(
            context,
            result.message ?? 'Failed to delete user',
            isError: true,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Admins'),
            Tab(text: 'Sellers'),
            Tab(text: 'Buyers'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading users...')
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(_allUsers),
                _buildUserList(
                    _allUsers.where((u) => u.role == 'admin').toList()),
                _buildUserList(
                    _allUsers.where((u) => u.role == 'seller').toList()),
                _buildUserList(
                    _allUsers.where((u) => u.role == 'buyer').toList()),
              ],
            ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    if (users.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Users Found',
        subtitle: 'No users in this category',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(UserModel user) {
    final roleColor = _getRoleColor(user.role);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteUser(user.id);
                  } else {
                    _updateUserRole(user.id, value);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.admin_panel_settings,
                            color: AppTheme.accentColor, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Admin'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'seller',
                    child: Row(
                      children: [
                        Icon(Icons.store, color: AppTheme.successColor, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Seller'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'buyer',
                    child: Row(
                      children: [
                        Icon(Icons.person,
                            color: AppTheme.primaryColor, size: 20),
                        SizedBox(width: 8),
                        Text('Set as Buyer'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                        SizedBox(width: 8),
                        Text('Delete User',
                            style: TextStyle(color: AppTheme.errorColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (user.phone != null || user.address != null) ...[
            const Divider(height: 24),
            if (user.phone != null)
              _buildInfoRow(Icons.phone_outlined, user.phone!),
            if (user.address != null)
              _buildInfoRow(Icons.location_on_outlined, user.address!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppTheme.accentColor;
      case 'seller':
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

