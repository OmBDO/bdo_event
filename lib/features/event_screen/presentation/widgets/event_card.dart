import 'package:flutter/material.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Function(BuildContext)? onTap;
  final VoidCallback? onUpdate;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onUpdate,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 9),
      width: MediaQuery.sizeOf(context).width,
      height: 310, // Increased slightly by 10px to accommodate bottom margins beautifully
      decoration: BoxDecoration(
        color: Colors.white,
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
                            return _buildImagePlaceholder();
                          },
                        ),
                      )
                    : _buildImagePlaceholder(),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    event.date,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              if (onUpdate != null && onDelete != null)
                Positioned(
                  top: 54,
                  right: 12,
                  child: PopupMenuButton<String>(
                    tooltip: AppText.manageEvent,
                    onSelected: (value) {
                      if (value == 'update') onUpdate!();
                      if (value == 'delete') onDelete!();
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'update', child: Text(AppText.update)),
                      PopupMenuItem(value: 'delete', child: Text(AppText.delete)),
                    ],
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white70,
                      child: Icon(Icons.more_horiz, color: Colors.black87),
                    ),
                  ),
                ),

              // Floating Attending Avatars (Bottom Left Overlapping Border)
              Positioned(
                bottom: -16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 22,
                        width: (3 * 16.0) + 6.0,
                        child: Stack(
                          children: [
                            // 🚀 FIXED: Added valid endpoint URL paths instead of 'https://pravatar.cc'
                            Positioned(
                              left: 0,
                              child: _buildAvatar(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTqIGGrBSRv1I4gAHcESlYGtuN8r3SchvJZeoOMK6yDW23iC7BRAEfK0RE&s=10',
                              ),
                            ),
                            Positioned(
                              left: 16,
                              child: _buildAvatar(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRAfNQXtUUS81yEEeZXXvY4Ux-48HfUCGQq_E1x6PISTyzhVfeGMLtMWjYy&s=10',
                              ),
                            ),
                            Positioned(
                              left: 32,
                              child: _buildAvatar(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQMHIN_pWELurJc6QlHWpwVAQ47ADzg3MqBLRupl9r43wzqyIgbF0YeoSfj&s=10',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '99+',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.language,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Diagonal Arrow Circular Button
                GestureDetector(
                  onTap: () => onTap?.call(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.north_east,
                      color: Colors.white,
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
  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: const Color(0xFFE8E8F5),
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  // 🚀 FIXED: Completed the broken method implementation at the end of your snippet
  Widget _buildAvatar(String url) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 11,
        backgroundColor: Colors.grey[300],
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (exception, stackTrace) {
          // Silent catch for network dropping
        },
      ),
    );
  }
}
