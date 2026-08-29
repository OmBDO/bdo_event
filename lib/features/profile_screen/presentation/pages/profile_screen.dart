import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/features/auth_screen/presentation/cubit/auth_screen_cubit.dart';
import 'package:bdo_event/features/calendar_screen/presentation/pages/calendar_screen.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileScreenView();
  }
}

class _ProfileScreenView extends StatelessWidget {
  const _ProfileScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileScreenCubit, ProfileScreenState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      builder: (context, state) {
        final user = state.user;
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: const Color(0xFFE96B47)
                                .withValues(alpha: 0.1),
                            child: const CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                AppAssets.defaultAvatarUrl,
                              ),
                            ),
                          ),
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFFE96B47),
                            child: Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      const Gap(16),
                      Text(
                        user?.displayName ?? 'Profile unavailable',
                        style: const TextStyle(
                          color: Color(0xFF2D0C57),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: Color(0xFF9586A8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(10),
                _sectionHeader(AppText.accountSettings),
                _settingsGroup([
                  _settingsTile(
                    icon: Icons.person_outline_rounded,
                    color: Colors.blue,
                    title: AppText.editProfile,
                    subtitle: AppText.changeProfileDetails,
                    onTap: () => _showInfoDialog(
                      context,
                      title: AppText.profileDetails,
                      message:
                          'Your signed-in name is ${user?.displayName ?? 'not available'} and the email is ${user?.email ?? 'not available'}.',
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.calendar_month_outlined,
                    color: Colors.orange,
                    title: AppText.myEventRegistrations,
                    subtitle: AppText.viewTicketsAndFestivals,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CalendarScreen()),
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.payment_rounded,
                    color: Colors.green,
                    title: AppText.paymentMethods,
                    subtitle: AppText.linkedPaymentMethods,
                    onTap: () => _showInfoDialog(
                      context,
                      title: AppText.paymentMethods,
                      message: AppText.paymentMethodsInfo,
                    ),
                  ),
                ]),
                const Gap(16),
                _sectionHeader(AppText.preferences),
                _settingsGroup([
                  _settingsToggle(
                    icon: Icons.notifications_none_rounded,
                    color: Colors.deepPurple,
                    title: AppText.pushNotifications,
                    subtitle: AppText.festivalUpdateAlerts,
                    value: state.isNotificationEnabled,
                    onChanged: context
                        .read<ProfileScreenCubit>()
                        .updateNotificationPreference,
                  ),
                  _settingsToggle(
                    icon: Icons.dark_mode_outlined,
                    color: Colors.blueGrey,
                    title: AppText.darkThemeMode,
                    subtitle: AppText.darkModeInterface,
                    value: state.isDarkModeEnabled,
                    onChanged: context
                        .read<ProfileScreenCubit>()
                        .toggleDarkMode,
                  ),
                  _settingsTile(
                    icon: Icons.language_rounded,
                    color: Colors.teal,
                    title: AppText.appLanguage,
                    subtitle: AppText.englishIndia,
                    onTap: () => _showInfoDialog(
                      context,
                      title: AppText.appLanguage,
                      message: AppText.onlyAvailableLanguage,
                    ),
                  ),
                ]),
                const Gap(16),
                _sectionHeader(AppText.supportLegal),
                _settingsGroup([
                  _settingsTile(
                    icon: Icons.help_outline_rounded,
                    color: Colors.indigo,
                    title: AppText.helpCenterFaq,
                    subtitle: AppText.troubleshootingHelp,
                    onTap: () => _showInfoDialog(
                      context,
                      title: AppText.helpCenterFaq,
                      message: AppText.eventHelp,
                    ),
                  ),
                  _settingsTile(
                    icon: Icons.shield_outlined,
                    color: Colors.amber,
                    title: AppText.privacyPolicy,
                    subtitle: AppText.termsAndSecurity,
                    onTap: () => _showInfoDialog(
                      context,
                      title: AppText.privacyPolicy,
                      message: AppText.supabaseDataPolicy,
                    ),
                  ),
                ]),
                const Gap(24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () => _logout(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: const Color(0xFFB1D4FA)
                          .withValues(alpha: 0.6),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      AppText.logout,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                ValueListenableBuilder<double>(
                  valueListenable: FooterHeightTracker.heightNotifier,
                  builder: (context, dynamicHeight, child) =>
                      SizedBox(height: dynamicHeight + 24),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthScreenCubit>().logout();
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
}

Widget _sectionHeader(String title) => Container(
  padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
  child: Text(
    title,
    style: const TextStyle(
      color: Colors.black,
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  ),
);

Widget _settingsGroup(List<Widget> children) => Container(
  margin: const EdgeInsets.symmetric(horizontal: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.02),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Material(
      color: Colors.transparent,
      child: Column(children: children),
    ),
  ),
);

Widget _settingsTile({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) => ListTile(
  onTap: onTap,
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  leading: _settingsIcon(icon, color),
  title: _settingsTitle(title),
  subtitle: _settingsSubtitle(subtitle),
  trailing: const Icon(
    Icons.arrow_forward_ios_rounded,
    color: Colors.black26,
    size: 14,
  ),
);

Widget _settingsToggle({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
  required bool value,
  required ValueChanged<bool> onChanged,
}) => ListTile(
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  leading: _settingsIcon(icon, color),
  title: _settingsTitle(title),
  subtitle: _settingsSubtitle(subtitle),
  trailing: Switch.adaptive(
    value: value,
    onChanged: onChanged,
    // ignore: deprecated_member_use
    activeColor: const Color(0xFFE96B47),
  ),
);

Widget _settingsIcon(IconData icon, Color color) => Container(
  padding: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: color.withValues(alpha: 0.1),
    shape: BoxShape.circle,
  ),
  child: Icon(icon, color: color, size: 20),
);

Widget _settingsTitle(String title) => Text(
  title,
  style: const TextStyle(
    color: Color(0xFF2D0C57),
    fontWeight: FontWeight.w600,
    fontSize: 15,
  ),
);

Widget _settingsSubtitle(String subtitle) => Text(
  subtitle,
  style: const TextStyle(
    color: Color(0xFF9586A8),
    fontSize: 12,
    fontWeight: FontWeight.w400,
  ),
);
