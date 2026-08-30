import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_resource.dart';

class AppButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const AppButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode
              ? theme.colorScheme.primary
              : Colors.black87,
            foregroundColor: isDarkMode
              ? theme.colorScheme.onPrimary
              : Colors.white,
          elevation: 2,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: AppSize.text16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(label),
      ),
    );
  }
}
