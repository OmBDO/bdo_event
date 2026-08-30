import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';

class ProfileSectionHeader extends StatelessWidget {
  const ProfileSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
    child: Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: AppSize.text15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),
  );
}
