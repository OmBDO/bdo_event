import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'package:bdo_event/core/theme/app_colors.dart';

class ProfileSettingsTile extends StatelessWidget {
  const ProfileSettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _settingsIcon(),
      title: _settingsTitle(context),
      subtitle: _settingsSubtitle(context),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.26),
        size: 14,
      ),
    );
  }

  Widget _settingsIcon() => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: color, size: 20),
  );

  Widget _settingsTitle(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w600,
      fontSize: AppSize.text15,
    ),
  );

  Widget _settingsSubtitle(BuildContext context) => Text(
    subtitle,
    style: TextStyle(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.mutedTextDark
          : AppColors.profileSubtitleLight,
      fontSize: AppSize.text12,
      fontWeight: FontWeight.w400,
    ),
  );
}
