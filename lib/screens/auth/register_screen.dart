import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_date_picker.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';

/// Register Screen
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedRole;
  TimeOfDay? _preferredContactTime;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      Helpers.showSnackBar(context, 'Please select a role', isError: true);
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      role: _selectedRole!,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
    );

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(
        context,
        'Account created successfully!',
        isSuccess: true,
      );

      final user = authController.user;
      if (user != null) {
        switch (user.role) {
          case 'admin':
            Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
            break;
          case 'seller':
            Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
            break;
          default:
            Navigator.pushReplacementNamed(context, AppRoutes.buyerHome);
        }
      }
    } else {
      Helpers.showSnackBar(
        context,
        authController.error ?? 'Registration failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.1),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: () => Navigator.pop(context),
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Header
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign up to get started',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Name Field
                        CustomTextField(
                          controller: _nameController,
                          labelText: 'Full Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline,
                          validator: Validators.name,
                        ),
                        const SizedBox(height: 16),
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 16),
                        // Role Dropdown
                        RoleDropdown(
                          value: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Phone Field
                        CustomTextField(
                          controller: _phoneController,
                          labelText: 'Phone Number (Optional)',
                          hintText: 'Enter your phone number',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.phone,
                        ),
                        const SizedBox(height: 16),
                        // Address Field
                        CustomTextField(
                          controller: _addressController,
                          labelText: 'Address (Optional)',
                          hintText: 'Enter your address',
                          prefixIcon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        // Preferred Contact Time (Optional)
                        CustomTimePicker(
                          selectedTime: _preferredContactTime,
                          labelText: 'Preferred Contact Time (Optional)',
                          hintText: 'Select preferred contact time',
                          prefixIcon: Icons.access_time_outlined,
                          onTimeSelected: (time) {
                            setState(() {
                              _preferredContactTime = time;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password Field
                        CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Create a password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: Validators.password,
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password Field
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) => Validators.confirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          onSubmitted: (_) => _handleRegister(),
                        ),
                        const SizedBox(height: 32),
                        // Register Button
                        Consumer<AuthController>(
                          builder: (context, auth, _) => PrimaryButton(
                            text: 'Create Account',
                            onPressed: _handleRegister,
                            isLoading: auth.isLoading,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

