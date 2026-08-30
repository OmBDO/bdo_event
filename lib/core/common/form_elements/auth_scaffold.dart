import 'package:flutter/material.dart';

import 'package:bdo_event/core/theme/app_colors.dart';

class AuthScaffold extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;

  const AuthScaffold({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? const [
                    AppColors.shellStartDark,
                    AppColors.backgroundDark,
                    AppColors.shellEndDark,
                  ]
                : const [
                    AppColors.shellStartLight,
                    AppColors.backgroundLight,
                    AppColors.shellEndLight,
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(
                          alpha: isDarkMode ? 0.96 : 0.84,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: theme.colorScheme.surface),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDarkMode ? 0.35 : 0.12,
                            ),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: form,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
