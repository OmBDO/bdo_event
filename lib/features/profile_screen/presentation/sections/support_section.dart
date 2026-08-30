import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_section_header.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_group.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_tile.dart';
import 'package:flutter/material.dart';

class ProfileSupportSection extends StatelessWidget {
  const ProfileSupportSection({
    required this.onShowInfo,
    required this.onSignOutEverywhere,
    super.key,
  });

  final void Function({required String title, required String message})
      onShowInfo;
  final VoidCallback onSignOutEverywhere;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileSectionHeader(AppText.supportLegal),
      ProfileSettingsGroup(children: [
        ProfileSettingsTile(
          icon: Icons.help_outline_rounded,
          color: Colors.indigo,
          title: AppText.helpCenterFaq,
          subtitle: AppText.troubleshootingHelp,
          onTap: () => onShowInfo(
            title: AppText.helpCenterFaq,
            message: AppText.eventHelp,
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.shield_outlined,
          color: Colors.amber,
          title: AppText.privacyPolicy,
          subtitle: AppText.termsAndSecurity,
          onTap: () => onShowInfo(
            title: AppText.privacyPolicy,
            message: AppText.supabaseDataPolicy,
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.info_outline_rounded,
          color: Colors.teal,
          title: AppText.appVersion,
          subtitle: AppText.appVersionValue,
          onTap: () => onShowInfo(
            title: AppText.appVersion,
            message: AppText.appVersionValue,
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.menu_book_outlined,
          color: Colors.blueGrey,
          title: AppText.licenses,
          subtitle: AppText.termsAndSecurity,
          onTap: () => showLicensePage(
            context: context,
            applicationName: AppText.appName,
            applicationVersion: AppText.appVersionValue,
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.devices_outlined,
          color: Colors.redAccent,
          title: AppText.signOutEverywhere,
          subtitle: AppText.signOutEverywhereDescription,
          onTap: onSignOutEverywhere,
        ),
      ]),
    ],
  );
}
