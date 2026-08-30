import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/cubit/event_detail_cubit.dart';
import 'package:bdo_event/features/event_detail_screen/presentation/pages/event_detail_screen.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_state.dart';
import 'package:bdo_event/features/event_screen/presentation/widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavedEventsPage extends StatelessWidget {
  const SavedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved events')),
      body: BlocBuilder<EventScreenCubit, EventScreenState>(
        builder: (context, state) {
          final savedEvents = state.events
              .where((event) => state.savedEventIds.contains(event.id))
              .toList();

          if (savedEvents.isEmpty) {
            return const Center(
              child: Text('You have not saved any events yet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: savedEvents.length,
            itemBuilder: (context, index) {
              final event = savedEvents[index];
              return EventCard(
                event: event,
                isSaved: true,
                onSave: () => context
                    .read<EventScreenCubit>()
                    .toggleSavedEvent(event),
                onTap: (_) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => getIt<EventDetailCubit>(),
                        child: EventDetailPage(event: event),
                      ),
                    ),
                  );
                  if (context.mounted) {
                    await context.read<EventScreenCubit>().load(force: true);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
