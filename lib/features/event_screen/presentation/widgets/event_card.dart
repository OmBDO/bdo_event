import 'package:flutter/material.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:gap/gap.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Function(BuildContext)? onTap;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onSave;
  final bool isSaved;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onUpdate,
    this.onDelete,
    this.onSave,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = context.watch<ProfileScreenCubit>().state.dateFormat;
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
      width: MediaQuery.sizeOf(context).width,
      height: 310, // Increased slightly by 10px to accommodate bottom margins beautifully
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Image section with floating badges
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: event.imageUrl.isNotEmpty
                    ? Hero(
                        tag: event.id,
                        child: EventImage(
                          path: event.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder(context);
                          },
                        ),
                      )
                    : _buildImagePlaceholder(context),
              ),

              // Floating Date Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xCC111827),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    formatEventDate(event.date, dateFormat),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppSize.text12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              if (onSave != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: isSaved ? 'Remove saved event' : 'Save event',
                      onPressed: onSave,
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),

              if (event.attendeeCount > 0)
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xCC111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    child: Text(
                      '${event.attendeeCount} attending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSize.text12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // 2. Bottom Text Content Section
          Padding(
            padding: const EdgeInsets.only(
              top: 28.0,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 1, // Restricting to 1 line limits height spillover bugs
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppSize.text18,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const Gap(AppSpace.space10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.language,
                              size: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const Gap(AppSpace.space8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                                fontSize: AppSize.text13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Gap(AppSpace.space16),

                // Diagonal Arrow Circular Button
                GestureDetector(
                  onTap: () => onTap?.call(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? theme.colorScheme.primary
                          : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.north_east,
                      color: isDarkMode
                          ? theme.colorScheme.onPrimary
                          : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to cleanly format fallback images
  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        size: 50,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
