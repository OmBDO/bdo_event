import 'package:animations/animations.dart';
import 'package:bdo_event/core/common/app_scroll_tracker/app_scroll_tracker.dart';
import 'package:bdo_event/core/common/footer_height_tracker/footer_height_tracker.dart';
import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/create_event_page.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/event_card.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/event_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EventPageView();
  }
}

class _EventPageView extends StatefulWidget {
  const _EventPageView();

  @override
  State<_EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<_EventPageView> {
  @override
  void initState() {
    super.initState();
    context.read<EventScreenCubit>().load();
  }

  Future<void> _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppText.deleteEventQuestion),
        content: Text(
          AppText.deleteEventDescription.replaceFirst('{eventTitle}', event.title),
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
      builder: (context, state) {
        final currentTabList = state.currentTabEvents;

        return CustomScrollView(
          controller: AppScrollTracker.eventScrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: const Color.fromARGB(0, 255, 193, 7),
              flexibleSpace: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: Alignment.bottomLeft,
                child: EventTab(
                  titles: state.tabs,
                  onTap: (selectedTab) {
                    context.read<EventScreenCubit>().changeTab(selectedTab);
                  },
                  selectedTab: state.selectedTab,
                ),
              ),
            ),
            if (currentTabList.isEmpty)
              _buildEmptyState(state.selectedTab)
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cardData = currentTabList[index];

                  return OpenContainer(
                    transitionType: ContainerTransitionType.fade,
                    transitionDuration: const Duration(milliseconds: 350),
                    openColor: Colors.transparent,
                    closedColor: Colors.transparent,
                    closedElevation: 0,
                    openElevation: 0,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    openShape: const RoundedRectangleBorder(),
                    tappable: false,

                    openBuilder: (context, closeContainer) {
                      return BlocProvider(
                        create: (_) => getIt<EventDetailCubit>(),
                        child: EventDetailPage(event: cardData),
                      );
                    },

                    closedBuilder: (context, openContainer) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: openContainer,
                          child: EventCard(
                            event: cardData,
                            onUpdate: context.read<EventScreenCubit>().canUpdate(cardData)
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          CreateEventPage(event: cardData),
                                    ),
                                  )
                                : null,
                            onDelete: context.read<EventScreenCubit>().canDelete(cardData)
                                ? () => _confirmDelete(cardData)
                                : null,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: currentTabList.length),
              ),

            ValueListenableBuilder<double>(
              valueListenable: FooterHeightTracker.heightNotifier,
              builder: (context, dynamicHeight, child) {
                return SliverToBoxAdapter(
                  child: SizedBox(height: dynamicHeight),
                );
              },
            ),
          ],
        );
      },
    );
  }

  SliverToBoxAdapter _buildEmptyState(int selectedTab) {
    final tabTitle = switch (selectedTab) {
      1 => 'My Events',
      2 => 'Past Events',
      _ => 'Upcoming Events',
    };

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 80),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7F6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFDCE7E3)),
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEDE7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  size: 38,
                  color: Color(0xFF276653),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'A quiet moment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF173D34),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$tabTitle will appear here when there is something to explore.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667A74),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
