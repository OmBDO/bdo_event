import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EventTab extends StatelessWidget {
  final List<String> titles;
  final int selectedTab;
  final Function(int) onTap;

  const EventTab({
    super.key,
    required this.titles,
    required this.onTap,
    required this.selectedTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.maxFinite,
      height: 40,
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const Gap(AppSpace.space12);
        },
        scrollDirection: Axis.horizontal,
        itemCount: titles.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: selectedTab == index
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                titles[index],
                style: TextStyle(
                  color: selectedTab == index
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: AppSize.text14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
