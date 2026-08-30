import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_state.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_section_header.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_group.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_slider.dart';
import 'package:bdo_event/features/profile_screen/presentation/widgets/profile_settings_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileWatcherSettingsSection extends StatelessWidget {
  const ProfileWatcherSettingsSection({required this.state, super.key});

  final ProfileScreenState state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ProfileSectionHeader(AppText.watcherSettings),
      ProfileSettingsGroup(children: [
        ProfileSettingsToggle(
          icon: Icons.volume_off_outlined,
          color: Colors.redAccent,
          title: AppText.muteScanningVoice,
          subtitle: AppText.muteScanningVoiceDescription,
          value: state.isWatcherVoiceMuted,
          onChanged: context.read<ProfileScreenCubit>().toggleWatcherVoiceMuted,
        ),
        ProfileSettingsToggle(
          icon: Icons.vibration_outlined,
          color: Colors.orange,
          title: AppText.scanVibration,
          subtitle: AppText.scanVibrationDescription,
          value: state.isWatcherVibrationEnabled,
          onChanged: context.read<ProfileScreenCubit>().toggleWatcherVibration,
        ),
        ProfileSettingsSlider(
          icon: Icons.volume_up_outlined,
          color: Colors.blue,
          title: AppText.scannerSoundVolume,
          subtitle: AppText.scannerSoundVolumeDescription,
          value: state.watcherSoundVolume,
          onChanged: context.read<ProfileScreenCubit>().updateWatcherSoundVolume,
        ),
        ProfileSettingsToggle(
          icon: Icons.skip_next_outlined,
          color: Colors.indigo,
          title: AppText.autoOpenNextAttendee,
          subtitle: AppText.autoOpenNextAttendeeDescription,
          value: state.isWatcherAutoOpenNextEnabled,
          onChanged: context.read<ProfileScreenCubit>().toggleWatcherAutoOpenNext,
        ),
        ProfileSettingsToggle(
          icon: Icons.history_outlined,
          color: Colors.deepOrange,
          title: AppText.keepHistoryVisibleAfterCheckIn,
          subtitle: AppText.keepHistoryVisibleAfterCheckInDescription,
          value: state.isWatcherKeepHistoryVisibleAfterCheckIn,
          onChanged: context.read<ProfileScreenCubit>().toggleWatcherKeepHistoryVisibleAfterCheckIn,
        ),
      ]),
    ],
  );
}
