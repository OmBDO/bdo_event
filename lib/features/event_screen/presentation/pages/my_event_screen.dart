import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/category_event_page.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/create_event_page.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_attendees_page.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/event_analytics_page.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/event_invitation_page.dart';
import 'package:bdo_event/features/auth_screen/domain/repositories/auth_repository.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/util/event_date_formatter.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/common/loading_shimmer/loading_shimmer.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen> {
  Event? _eventBeingDragged;
  bool _isDeleteTargetHovered = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents({bool force = false}) {
    context.read<EventScreenCubit>().load(force: force);
  }

  // 5. Trigger a reload when coming back from Create/Edit screen
  Future<void> _navigateToCreateOrEdit([Event? event]) async {
    if (event != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
    } else {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CategoryEventPage()));
    }
    _loadEvents(force: true); // Refresh after a create/edit operation
  }

  Future<void> _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppText.deleteEventQuestion),
        content: Text(
          AppText.deleteEventDescription.replaceFirst(
            '{eventTitle}',
            event.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppText.keepEvent),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(AppText.delete),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    final error = await context.read<EventScreenCubit>().delete(event);
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventScreenCubit, EventScreenState>(
      builder: (context, state) => Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 90),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface
                  .withValues(alpha: 0.6),
            ),
            child: Builder(
              builder: (context) {
                if (state.isLoading) {
                  return const EventListShimmer();
                }

                if (state.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  );
                }

                final events = state.events;

                if (events.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppText.noEventsCreated,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppText.tapToCreateFirstEvent,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return LongPressDraggable<Event>(
                      data: event,
                      delay: const Duration(milliseconds: 250),
                      onDragStarted: () =>
                          setState(() => _eventBeingDragged = event),
                      onDraggableCanceled: (_, _) {
                        if (mounted) setState(() => _eventBeingDragged = null);
                      },
                      onDragEnd: (_) {
                        if (mounted) {
                          setState(() {
                            _eventBeingDragged = null;
                            _isDeleteTargetHovered = false;
                          });
                        }
                      },
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width - 32,
                          child: Card(
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _navigateToCreateOrEdit(event),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.65),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _navigateToCreateOrEdit(event),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: EventImage(
                                      path: event.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.65),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            formatEventDate(
                                              formatEventDate(
                                                event.date,
                                                context
                                                    .watch<ProfileScreenCubit>()
                                                    .state
                                                    .dateFormat,
                                              ),
                                              context
                                                  .watch<ProfileScreenCubit>()
                                                  .state
                                                  .dateFormat,
                                            ),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.65),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 14,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.65),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              event.location,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.65),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'View attendees',
                                  icon: const Icon(Icons.groups_outlined),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventAttendeesPage(event: event),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'View event analytics',
                                  icon: const Icon(Icons.analytics_outlined),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EventAnalyticsPage(event: event),
                                    ),
                                  ),
                                ),
                                if (getIt<AuthRepositoryContract>()
                                        .currentUser
                                        ?.isAdministrator ??
                                    false)
                                  IconButton(
                                    tooltip: 'Invite users',
                                    icon: const Icon(
                                      Icons.person_add_alt_1_outlined,
                                    ),
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            EventInvitationPage(event: event),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Positioned(
            bottom: 110,
            right: 20,
            child: DragTarget<Event>(
              onWillAcceptWithDetails: (details) {
                if (_eventBeingDragged == null) return false;
                setState(() => _isDeleteTargetHovered = true);
                return true;
              },
              onLeave: (_) {
                if (mounted) setState(() => _isDeleteTargetHovered = false);
              },
              onAcceptWithDetails: (details) async {
                final event = details.data;
                setState(() {
                  _eventBeingDragged = null;
                  _isDeleteTargetHovered = false;
                });
                await _confirmDelete(event);
              },
              builder: (context, candidateData, rejectedData) {
                final isDeleteMode = _eventBeingDragged != null;
                return FloatingActionButton(
                  onPressed: isDeleteMode
                      ? () async {
                          final event = _eventBeingDragged;
                          if (event == null) return;
                          setState(() {
                            _eventBeingDragged = null;
                            _isDeleteTargetHovered = false;
                          });
                          await _confirmDelete(event);
                        }
                      : () => _navigateToCreateOrEdit(),
                  backgroundColor: isDeleteMode
                      ? (_isDeleteTargetHovered
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.error)
                      : Colors.black,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    isDeleteMode ? Icons.delete_outline : Icons.add,
                    color: isDeleteMode
                        ? Theme.of(context).colorScheme.onError
                    : Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
