import 'package:bdo_event/core/util/event_resource.dart';
import 'package:bdo_event/features/calendar_screen/presentation/pages/calendar_screen.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/saved_events_page.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_section_header.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_group.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_tile.dart';
import 'package:flutter/material.dart';

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({
    required this.onEditProfile,
    required this.onChangePassword,
    super.key,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileSectionHeader(AppText.accountSettings),
      ProfileSettingsGroup(children: [
        ProfileSettingsTile(
          icon: Icons.person_outline_rounded,
          color: Colors.blue,
          title: AppText.editProfile,
          subtitle: AppText.changeProfileDetails,
          onTap: onEditProfile,
        ),
        ProfileSettingsTile(
          icon: Icons.lock_outline_rounded,
          color: Colors.deepOrange,
          title: AppText.changePassword,
          subtitle: AppText.changePasswordDescription,
          onTap: onChangePassword,
        ),
        ProfileSettingsTile(
          icon: Icons.calendar_month_outlined,
          color: Colors.orange,
          title: AppText.myEventRegistrations,
          subtitle: AppText.viewTicketsAndFestivals,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const Scaffold(body: CalendarScreen()),
            ),
          ),
        ),
        ProfileSettingsTile(
          icon: Icons.bookmark_outline_rounded,
          color: Colors.indigo,
          title: AppText.savedEvents,
          subtitle: 'Events you want to revisit',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SavedEventsPage()),
          ),
        ),
      ]),
    ],
  );
}
