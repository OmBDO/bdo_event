import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/category_event_page.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/my_event_screen.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_section_header.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_group.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_tile.dart';
import 'package:bdo_event/features/watcher_screen/presentation/pages/watcher_scan_screen.dart';
import 'package:flutter/material.dart';

class ProfileOrganizerToolsSection extends StatelessWidget {
  const ProfileOrganizerToolsSection({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileSectionHeader(AppText.organizerTools),
      ProfileSettingsGroup(children: [
        ProfileSettingsTile(
          icon: Icons.add_business_outlined,
          color: Colors.green,
          title: AppText.createEvent,
          subtitle: AppText.bringPeopleTogether,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CategoryEventPage()),
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.event_note_outlined,
          color: Colors.blue,
          title: AppText.manageMyEvents,
          subtitle: AppText.myEvents,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyEventScreen()),
          ),
        ),
        if (user.hasPermission(UserPermission.scanRegistrations))
          ProfileSettingsTile(
            icon: Icons.qr_code_scanner_outlined,
            color: Colors.deepPurple,
            title: AppText.scanRegistration,
            subtitle: AppText.scanRegistrationPrompt,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WatcherScanScreen()),
            ),
          ),
      ]),
    ],
  );
}
