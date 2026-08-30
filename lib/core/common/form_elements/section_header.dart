import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SectionHeader extends StatelessWidget {
  final String subtitle;
  final String title;
  final String description;

  const SectionHeader({
    super.key,
    required this.subtitle,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: AppSize.text12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const Gap(AppSpace.space10),
        Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: AppSize.text30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Gap(AppSpace.space8),
        Text(
          description,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: AppSize.text15,
          ),
        ),
      ],
    );
  }
}
