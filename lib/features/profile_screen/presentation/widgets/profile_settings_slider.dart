import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';

import 'package:bdo_event/core/theme/app_colors.dart';

class ProfileSettingsSlider extends StatelessWidget {
  const ProfileSettingsSlider({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    leading: _settingsIcon(),
    title: _settingsTitle(context),
    subtitle: _settingsSubtitle(context),
    trailing: SizedBox(
      width: 132,
      child: Row(
        children: [
          Expanded(
            child: Slider(value: value, min: 0, max: 1, onChanged: onChanged),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${(value * 100).round()}%',
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: AppSize.text12),
            ),
          ),
        ],
      ),
    ),
  );

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
