import 'package:bdo_event/core/util/resource/app_other.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_section_header.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_group.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_tile.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/features/profile_screen/domain/entities/profile_visibility.dart';
import 'package:gap/gap.dart';

class ProfilePreferencesSection extends StatelessWidget {
  const ProfilePreferencesSection({
    required this.state,
    required this.onReminderLeadTime,
    required this.onShowLanguageInfo,
    super.key,
  });

  final ProfileScreenState state;
  final ValueChanged<int> onReminderLeadTime;
  final VoidCallback onShowLanguageInfo;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileSectionHeader(AppText.preferences),
      ProfileSettingsGroup(
        children: [
          ProfileSettingsToggle(
            icon: Icons.notifications_none_rounded,
            color: Colors.deepPurple,
            title: AppText.pushNotifications,
            subtitle: AppText.festivalUpdateAlerts,
            value: state.isNotificationEnabled,
            onChanged: context
                .read<ProfileScreenCubit>()
                .updateNotificationPreference,
          ),
          ProfileSettingsToggle(
            icon: Icons.event_available_outlined,
            color: Colors.green,
            title: AppText.eventReminders,
            subtitle: AppText.eventRemindersDescription,
            value: state.isEventRemindersEnabled,
            onChanged: context.read<ProfileScreenCubit>().toggleEventReminders,
          ),
          ProfileSettingsTile(
            icon: Icons.schedule_outlined,
            color: Colors.orange,
            title: AppText.reminderLeadTime,
            subtitle:
                '${AppText.reminderLeadTimeDescription} • ${AppText.reminderLeadTimeLabel(state.eventReminderLeadTimeMinutes)}',
            onTap: () => onReminderLeadTime(state.eventReminderLeadTimeMinutes),
          ),
          ProfileSettingsToggle(
            icon: Icons.dark_mode_outlined,
            color: Colors.blueGrey,
            title: AppText.darkThemeMode,
            subtitle: AppText.darkModeInterface,
            value: state.isDarkModeEnabled,
            onChanged: context.read<ProfileScreenCubit>().toggleDarkMode,
          ),
          ProfileSettingsToggle(
            icon: Icons.format_size_outlined,
            color: Colors.pink,
            title: AppText.largerText,
            subtitle: AppText.largerTextDescription,
            value: state.isLargeTextEnabled,
            onChanged: context.read<ProfileScreenCubit>().toggleLargeText,
          ),
          ProfileSettingsToggle(
            icon: Icons.contrast_outlined,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            title: AppText.highContrast,
            subtitle: AppText.highContrastDescription,
            value: state.isHighContrastEnabled,
            onChanged: context.read<ProfileScreenCubit>().toggleHighContrast,
          ),
          ProfileSettingsTile(
            icon: Icons.language_rounded,
            color: Colors.teal,
            title: AppText.appLanguage,
            subtitle: AppText.englishIndia,
            onTap: onShowLanguageInfo,
          ),
          ProfileSettingsTile(
            icon: Icons.calendar_month_outlined,
            color: Colors.indigo,
            title: 'Date format',
            subtitle: state.dateFormat,
            onTap: () => _showDateFormatDialog(context, state.dateFormat),
          ),
          ProfileSettingsToggle(
            icon: Icons.fingerprint_rounded,
            color: Colors.deepOrange,
            title: 'Biometric lock',
            subtitle: 'Protect the app when it is reopened',
            value: state.isBiometricLockEnabled,
            onChanged: (enabled) async {
              final changed = await context
                  .read<ProfileScreenCubit>()
                  .toggleBiometricLock(enabled);
              if (!changed && enabled && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppText.biometricAuthenticationUnavailable),
                  ),
                );
              }
            },
          ),
          ProfileSettingsTile(
            icon: Icons.visibility_outlined,
            color: Colors.blue,
            title: 'Profile visibility',
            subtitle: state.profileVisibility.label,
            onTap: () =>
                _showProfileVisibilityDialog(context, state.profileVisibility),
          ),
          ProfileSettingsTile(
            icon: Icons.assignment_ind_outlined,
            color: Colors.cyan,
            title: 'Registration visibility',
            subtitle: state.registrationVisibility.label,
            onTap: () => _showRegistrationVisibilityDialog(
              context,
              state.registrationVisibility,
            ),
          ),
        ],
      ),
    ],
  );

  Future<void> _showDateFormatDialog(
    BuildContext context,
    String currentFormat,
  ) async {
    final format = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text(AppText.dateFormat),
        children: [
          for (final value in const [
            AppDateFormats.dayMonthYear,
            AppDateFormats.monthDayYear,
            AppDateFormats.yearMonthDay,
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(value),
              child: Row(
                children: [
                  if (value == currentFormat)
                    const Icon(Icons.check_rounded, size: 18)
                  else
                    const Gap(AppSpace.space18),
                  const Gap(AppSpace.space8),
                  Text(value),
                ],
              ),
            ),
        ],
      ),
    );
    if (format != null && context.mounted) {
      context.read<ProfileScreenCubit>().updateDateFormat(format);
    }
  }

  Future<void> _showProfileVisibilityDialog(
    BuildContext context,
    ProfileVisibility current,
  ) async {
    final selected = await showDialog<ProfileVisibility>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text(AppText.profileVisibility),
        children: [
          for (final value in ProfileVisibility.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(value),
              child: _visibilityOption(value.label, value == current),
            ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      context.read<ProfileScreenCubit>().updateVisibility(
        profileVisibility: selected,
      );
    }
  }

  Future<void> _showRegistrationVisibilityDialog(
    BuildContext context,
    RegistrationVisibility current,
  ) async {
    final selected = await showDialog<RegistrationVisibility>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text(AppText.registrationVisibility),
        children: [
          for (final value in RegistrationVisibility.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(value),
              child: _visibilityOption(value.label, value == current),
            ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      context.read<ProfileScreenCubit>().updateVisibility(
        registrationVisibility: selected,
      );
    }
  }

  Widget _visibilityOption(String label, bool selected) => Row(
    children: [
      if (selected)
        const Icon(Icons.check_rounded, size: 18)
      else
        const Gap(AppSpace.space18),
      const Gap(AppSpace.space8),
      Text(label),
    ],
  );
}
