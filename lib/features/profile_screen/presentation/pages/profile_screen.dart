import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/notifications/event_reminder_notification_service.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/cubit/calendar_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/account_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/organizer_tools_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/preferences_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/profile_header_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/support_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/sections/watcher_settings_section.dart';
import 'package:bdo_event/features/profile_screen/presentation/pages/profile_details_page.dart';
import 'package:bdo_event/features/watcher_screen/presentation/cubit/watcher_scan_cubit.dart';
import 'package:bdo_event/core/common/profile_image/profile_image_picker.dart';
import 'package:bdo_event/core/common/profile_image/profile_image_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.imagePicker,
    this.storeImage,
    this.deleteImage,
  });

  final ProfileImagePicker? imagePicker;
  final StoreProfileImage? storeImage;
  final DeleteProfileImage? deleteImage;

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ProfileScreenCubit, ProfileScreenState>(
    listenWhen: (previous, current) =>
        previous.errorMessage != current.errorMessage &&
        current.errorMessage != null,
    listener: (context, state) =>
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!))),
    builder: (context, state) {
      final theme = Theme.of(context);
      final isDarkMode = theme.brightness == Brightness.dark;
      final user = state.user;
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(AppSpace.space30),
              ProfileHeaderSection(user: user),
              const Gap(AppSpace.space10),
              ProfileAccountSection(
                onEditProfile: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileDetailsPage(
                      user: user,
                      imagePicker: imagePicker,
                      storeImage: storeImage,
                      deleteImage: deleteImage,
                    ),
                  ),
                ),
                onChangePassword: () => _showChangePasswordDialog(context),
              ),
              const Gap(AppSpace.space16),
              ProfilePreferencesSection(
                state: state,
                onReminderLeadTime: (minutes) =>
                    _showReminderLeadTimeDialog(context, minutes),
                onShowLanguageInfo: () => _showInfoDialog(
                  context,
                  title: AppText.appLanguage,
                  message: AppText.onlyAvailableLanguage,
                ),
              ),
              if (user?.hasPermission(UserPermission.scanRegistrations) ??
                  false) ...[
                const Gap(AppSpace.space16),
                ProfileWatcherSettingsSection(state: state),
              ],
              if (user?.hasPermission(UserPermission.createEvents) ??
                  false) ...[
                const Gap(AppSpace.space16),
                ProfileOrganizerToolsSection(user: user!),
              ],
              const Gap(AppSpace.space16),
              ProfileSupportSection(
                onShowInfo: ({required title, required message}) =>
                    _showInfoDialog(context, title: title, message: message),
                onSignOutEverywhere: () => _signOutEverywhere(context),
              ),
              const Gap(AppSpace.space24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextButton.icon(
                  onPressed: () => _logout(context),
                  style: TextButton.styleFrom(
                    foregroundColor: isDarkMode
                        ? theme.colorScheme.onSurface
                        : Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: isDarkMode
                        ? theme.colorScheme.surfaceContainerHighest
                        : const Color(0xFFB1D4FA).withValues(alpha: 0.6),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    AppText.logout,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize.text15,
                    ),
                  ),
                ),
              ),
              ValueListenableBuilder<double>(
                valueListenable: FooterHeightTracker.heightNotifier,
                builder: (context, dynamicHeight, child) =>
                    SizedBox(height: dynamicHeight + AppSpace.space24),
              ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthScreenCubit>().logout();
    if (!context.mounted) return;
    context.read<WatcherScanCubit>().clearState();
  }

  Future<void> _signOutEverywhere(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppText.signOutEverywhereQuestion),
        content: const Text(AppText.signOutEverywhereWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppText.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(AppText.signOutEverywhere),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final error = await context.read<AuthScreenCubit>().logoutEverywhere();
    if (!context.mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    context.read<WatcherScanCubit>().clearState();
    context.read<CalendarScreenCubit>().clearState();
    context.read<ProfileScreenCubit>().clearState();
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppText.close),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    var isSaving = false;
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text(AppText.changePassword),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: AppText.newPassword,
                  ),
                  validator: (value) => (value?.length ?? 0) < 8
                      ? AppText.useAtLeastEightCharacters
                      : null,
                ),
                const Gap(AppSpace.space12),
                TextFormField(
                  controller: confirmationController,
                  obscureText: true,
                  enabled: !isSaving,
                  decoration: const InputDecoration(
                    labelText: AppText.confirmNewPassword,
                  ),
                  validator: (value) => value != passwordController.text
                      ? AppText.passwordsDoNotMatch
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving
                  ? null
                  : () => Navigator.of(dialogContext).pop(false),
              child: const Text(AppText.cancel),
            ),
            FilledButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => isSaving = true);
                      final error = await context
                          .read<ProfileScreenCubit>()
                          .changePassword(passwordController.text);
                      if (!dialogContext.mounted) return;
                      if (error != null) {
                        setState(() => isSaving = false);
                        ScaffoldMessenger.of(dialogContext)
                            .showSnackBar(SnackBar(content: Text(error)));
                        return;
                      }
                      Navigator.of(dialogContext).pop(true);
                    },
              child: const Text(AppText.savePassword),
            ),
          ],
        ),
      ),
    );
    passwordController.dispose();
    confirmationController.dispose();
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppText.passwordChanged)));
    }
  }

  Future<void> _showReminderLeadTimeDialog(
    BuildContext context,
    int selectedMinutes,
  ) async {
    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text(AppText.reminderLeadTime),
        children: [
          for (final minutes
              in EventReminderNotificationService.reminderLeadTimeOptions)
            RadioListTile<int>(
              value: minutes,
              // ignore: deprecated_member_use
              groupValue: selectedMinutes,
              title: Text(AppText.reminderLeadTimeLabel(minutes)),
              // ignore: deprecated_member_use
              onChanged: (value) => Navigator.of(dialogContext).pop(value),
            ),
        ],
      ),
    );
    if (selected != null && context.mounted) {
      await context.read<ProfileScreenCubit>().updateEventReminderLeadTime(
        selected,
      );
    }
  }
}
