import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/features/event_screen/presentation/pages/create_event_page.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Define a structured model for Categories

class CategoryEventPage extends StatefulWidget {
  const CategoryEventPage({super.key});

  @override
  State<CategoryEventPage> createState() => _CategoryEventPageState();
}

class _CategoryEventPageState extends State<CategoryEventPage> {
  final List<EventCategory> _categories = EventCategory.defaults;

  // 3. Helper method to open a filtered view of events when a category is tapped
  void _onCategoryTap(EventCategory category) {
    final allEvents = context.read<EventScreenCubit>().state.events;

    // Filter events by checking if the category name matches (assuming event.category exists)
    // If your Event model doesn't have a category field yet, this will pass allEvents or can be adapted
    allEvents.where((event) {
      // replace with your model's exact field, e.g., event.category == category.name
      return true;
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEventPage(catagory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.eventCategories),
        centerTitle: true,
      ),
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
                      color: category.color.withValues(alpha: 0.15),
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
