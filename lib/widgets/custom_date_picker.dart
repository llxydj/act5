import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

/// Custom Date Picker Widget
class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(DateTime?)? validator;
  final bool enabled;

  const CustomDatePicker({
    super.key,
    this.selectedDate,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: enabled
                  ? () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: firstDate ?? DateTime(1900),
                        lastDate: lastDate ?? DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppTheme.primaryColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: AppTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        onDateSelected(date);
                        state.didChange(date);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: state.hasError
                        ? AppTheme.errorColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (labelText != null && selectedDate != null)
                            Text(
                              labelText!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          Text(
                            selectedDate != null
                                ? DateFormat('MMMM dd, yyyy')
                                    .format(selectedDate!)
                                : hintText ?? labelText ?? 'Select Date',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedDate != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Custom Time Picker Widget
class CustomTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final void Function(TimeOfDay) onTimeSelected;
  final String? Function(TimeOfDay?)? validator;
  final bool enabled;

  const CustomTimePicker({
    super.key,
    this.selectedTime,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    required this.onTimeSelected,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<TimeOfDay>(
      initialValue: selectedTime,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: enabled
                  ? () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: selectedTime ?? TimeOfDay.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppTheme.primaryColor,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: AppTheme.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (time != null) {
                        onTimeSelected(time);
                        state.didChange(time);
                      }
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: state.hasError
                        ? AppTheme.errorColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        color: AppTheme.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (labelText != null && selectedTime != null)
                            Text(
                              labelText!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : hintText ?? labelText ?? 'Select Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedTime != null
                                  ? AppTheme.textPrimary
                                  : AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.access_time_outlined,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

