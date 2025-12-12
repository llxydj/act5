import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

/// Buyer Profile Screen
class BuyerProfileScreen extends StatefulWidget {
  const BuyerProfileScreen({super.key});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = context.read<AuthController>().user;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthController>().updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isEditing = false;
      });
      Helpers.showSnackBar(
        context,
        'Profile updated successfully',
        isSuccess: true,
      );
    } else {
      Helpers.showSnackBar(
        context,
        context.read<AuthController>().error ?? 'Failed to update profile',
        isError: true,
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await Helpers.showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDestructive: true,
    );

    if (confirm) {
      await context.read<AuthController>().logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email (non-editable)
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Profile Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          prefixIcon: Icons.person_outline,
                          enabled: _isEditing,
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          enabled: _isEditing,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          labelText: 'Address',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                          enabled: _isEditing,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing) ...[
                    PrimaryButton(
                      text: 'Save Changes',
                      isLoading: auth.isLoading,
                      onPressed: _handleSave,
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () {
                        _loadUserData();
                        setState(() {
                          _isEditing = false;
                        });
                      },
                    ),
                  ] else ...[
                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Order History',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.orderHistory),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Helpers.showSnackBar(context, 'Coming soon!');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'SwiftCart',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2024 SwiftCart',
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Logout',
                      icon: Icons.logout,
                      backgroundColor: AppTheme.errorColor,
                      onPressed: _handleLogout,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _isEditing ? null : _buildBottomNav(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: false,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.buyerHome,
                  (route) => false,
                ),
              ),
              _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                label: 'Cart',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                isSelected: false,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.orderHistory),
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: true,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

