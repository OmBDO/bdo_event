import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/theme/app_colors.dart';
import 'package:bdo_event/core/util/resource/app_assets.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({required this.user, super.key});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 54,
                backgroundColor:
                    (isDarkMode
                            ? AppColors.tertiaryDark
                            : AppColors.tertiaryLight)
                        .withValues(alpha: 0.1),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user?.photoUrl?.trim().isNotEmpty == true
                      ? NetworkImage(user!.photoUrl!)
                      : const NetworkImage(AppAssets.defaultAvatarUrl),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: isDarkMode
                    ? AppColors.primaryDark
                    : AppColors.tertiaryLight,
                child: Icon(
                  Icons.edit_rounded,
                  color: isDarkMode
                      ? theme.colorScheme.onPrimary
                      : Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const Gap(AppSpace.space16),
          Text(
            user?.displayName ?? AppText.profileUnavailable,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: AppSize.text22,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const Gap(AppSpace.space4),
          Text(
            user?.email ?? AppText.empty,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: AppSize.text14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
