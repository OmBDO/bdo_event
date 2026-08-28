import 'package:bdo_event/features/event_screen/my_event_screen/page/catergory_event_page.dart';
import 'package:bdo_event/features/event_screen/my_event_screen/page/create_event_page.dart';
import 'package:bdo_event/features/event_screen/repo/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';

class MyEventScreen extends StatefulWidget {
  const MyEventScreen({super.key});

  @override
  State<MyEventScreen> createState() => _MyEventScreenState();
}

class _MyEventScreenState extends State<MyEventScreen> {
  // 2. Define the Future object
  Future<List<Event>>? _eventsFuture;

  // 3. Define the ValueNotifier to hold the list state across transitions
  static final ValueNotifier<List<Event>> listedEvents =
      ValueNotifier<List<Event>>([]);

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load initial data when screen opens
  }

  // 4. Fetch the events, assign the future, and sync data into the ValueNotifier
  void _loadEvents() {
    setState(() {
      // Replace 'fetchUserEvents()' with the actual method name in your EventRepository
      _eventsFuture = EventRepository.getEvent().then((events) {
        listedEvents.value = events; // Sync data to the notifier once available
        return events;
      });
    });
  }

  // 5. Trigger a reload when coming back from Create/Edit screen
  Future<void> _navigateToCreateOrEdit([Event? event]) async {
    if (event != null) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => CreateEventPage(event: event)));
    } else {
      await Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => CatergoryEventPage()));
    }
    _loadEvents(); // Refresh data from backend when user navigates back
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.only(top: 90),
          decoration: BoxDecoration(color: Colors.white60),
          child: FutureBuilder<List<Event>>(
            future: _eventsFuture, // 6. Hook up the local future tracking the request
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Error loading events: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              // 7. Read standard data directly from ValueNotifier for UI rendering
              final events = listedEvents.value;

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No events created yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the + button below to create your first event.',
                        style: TextStyle(color: Colors.grey),
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
                  return Card(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.date,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
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
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
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
          child: FloatingActionButton(
            onPressed: () => _navigateToCreateOrEdit(),
            backgroundColor: Colors.black87,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
