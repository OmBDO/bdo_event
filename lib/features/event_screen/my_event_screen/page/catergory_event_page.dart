import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/features/event_screen/my_event_screen/page/create_event_page.dart';
import 'package:bdo_event/features/event_screen/my_event_screen/page/my_event_page.dart';
import 'package:bdo_event/features/event_screen/repo/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';

// 1. Define a structured model for Categories

class CatergoryEventPage extends StatefulWidget {
  const CatergoryEventPage({super.key}); // Fixed the invalid 'const new' syntax

  @override
  State<CatergoryEventPage> createState() => _CatergoryEventPageState();
}

class _CatergoryEventPageState extends State<CatergoryEventPage> {
  // 2. Define the static list of hardcoded categories
  final List<EventCategory> _categories = const [
    EventCategory(
      name: 'Sports',
      icon: Icons.sports_soccer,
      color: Colors.orange,
    ),
    EventCategory(name: 'Festival', icon: Icons.festival, color: Colors.purple),
    EventCategory(
      name: 'Food Event',
      icon: Icons.restaurant,
      color: Colors.red,
    ),
    EventCategory(
      name: 'Game Event',
      icon: Icons.sports_esports,
      color: Colors.blue,
    ),
    EventCategory(name: 'Music', icon: Icons.music_note, color: Colors.green),
    EventCategory(
      name: 'Business',
      icon: Icons.business_center,
      color: Colors.teal,
    ),
  ];

  // 3. Helper method to open a filtered view of events when a category is tapped
  void _onCategoryTap(EventCategory category) {
    // Read the static listedEvents value from MyEventScreen
    final allEvents = EventRepository.listedEvents.value;

    // Filter events by checking if the category name matches (assuming event.category exists)
    // If your Event model doesn't have a category field yet, this will pass allEvents or can be adapted
    final filteredEvents = allEvents.where((event) {
      // replace with your model's exact field, e.g., event.category == category.name
      return true;
    }).toList();

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => CreateEventPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Categories'), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1, // Aspect ratio for card shapes
        ),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _onCategoryTap(category),
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: category.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, size: 36, color: category.color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
