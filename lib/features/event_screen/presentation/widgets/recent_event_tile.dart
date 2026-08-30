import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:gap/gap.dart';

class RecentEventTile extends StatelessWidget {
  const RecentEventTile({super.key, required this.event, required this.onTap});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = context.watch<ProfileScreenCubit>().state.dateFormat;
    return SizedBox(
      width: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 92,
                width: double.infinity,
                child: event.imageUrl.isEmpty
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.event_rounded,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                      )
                    : EventImage(
                        path: event.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.event_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(AppSpace.space4),
                    Text(
                      formatEventDate(event.date, dateFormat),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}