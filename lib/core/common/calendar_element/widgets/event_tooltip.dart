import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EventTooltip extends StatelessWidget {
  const EventTooltip({
    super.key,
    required this.event,
    required this.onDismiss,
    required this.onOpen,
  });

  final Event event;
  final VoidCallback onDismiss;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        EventTooltipPointer(color: surfaceColor),
        Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                onDismiss();
                await onOpen();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow
                          .withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: EventImage(
                          path: event.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Gap(AppSpace.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: AppSize.text16,
                            ),
                          ),
                          const Gap(AppSpace.space5),
                          Text(
                            event.description.trim().isEmpty
                                ? 'View event details'
                                : event.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(height: 1.3),
                          ),
                          const Gap(AppSpace.space7),
                          Text(
                            'Open event',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventTooltipPointer extends StatelessWidget {
  const EventTooltipPointer({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 9),
      painter: _TooltipPointerPainter(color: color),
    );
  }
}

class _TooltipPointerPainter extends CustomPainter {
  const _TooltipPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TooltipPointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
