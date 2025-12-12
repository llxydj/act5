import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Custom Dropdown Widget
class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool enabled;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textSecondary, size: 22)
            : null,
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      style: const TextStyle(
        fontSize: 16,
        color: AppTheme.textPrimary,
      ),
    );
  }
}

/// Role Dropdown for Registration
class RoleDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  const RoleDropdown({
    super.key,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomDropdown<String>(
      value: value,
      labelText: 'Select Role',
      prefixIcon: Icons.person_outline,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a role';
            }
            return null;
          },
      items: const [
        DropdownMenuItem(
          value: 'buyer',
          child: Text('Buyer'),
        ),
        DropdownMenuItem(
          value: 'seller',
          child: Text('Seller'),
        ),
        DropdownMenuItem(
          value: 'admin',
          child: Text('Admin'),
        ),
      ],
    );
  }
}

