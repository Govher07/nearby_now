import 'package:flutter/material.dart';
import '../data/mock_events.dart';
import '../models/event.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedTime = 'All';
  String selectedCategory = 'All';
  String searchQuery = '';

  List<Event> get filteredEvents {
    List<Event> events = mockEvents;

    if (selectedTime != 'All') {
      events = events.where((event) => event.date == selectedTime).toList();
    }

    if (selectedCategory != 'All') {
      events = events
          .where((event) => event.category == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();

      events = events.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query);
      }).toList();
    }

    return events;
  }

  void openFilterSheet() {
    String tempTime = selectedTime;
    String tempCategory = selectedCategory;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Events',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'When?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: [
                      buildSheetChip('All', tempTime, (value) {
                        setSheetState(() {
                          tempTime = value;
                        });
                      }),
                      buildSheetChip('Now', tempTime, (value) {
                        setSheetState(() {
                          tempTime = value;
                        });
                      }),
                      buildSheetChip('Today', tempTime, (value) {
                        setSheetState(() {
                          tempTime = value;
                        });
                      }),
                      buildSheetChip('Tomorrow', tempTime, (value) {
                        setSheetState(() {
                          tempTime = value;
                        });
                      }),
                      buildSheetChip('This Week', tempTime, (value) {
                        setSheetState(() {
                          tempTime = value;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    children: [
                      buildSheetChip('All', tempCategory, (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      }),
                      buildSheetChip('Music', tempCategory, (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      }),
                      buildSheetChip('Food', tempCategory, (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      }),
                      buildSheetChip('Art', tempCategory, (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      }),
                      buildSheetChip('Community', tempCategory, (value) {
                        setSheetState(() {
                          tempCategory = value;
                        });
                      }),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTime = tempTime;
                          selectedCategory = tempCategory;
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedTime = 'All';
                          selectedCategory = 'All';
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSheetChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == label,
      onSelected: (_) {
        onSelected(label);
      },
    );
  }

  String get activeFilterText {
    if (selectedTime == 'All' && selectedCategory == 'All') {
      return 'All events';
    }

    if (selectedTime != 'All' && selectedCategory != 'All') {
      return '$selectedTime • $selectedCategory';
    }

    if (selectedTime != 'All') {
      return selectedTime;
    }

    return selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Now'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Find events near you',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Discover events happening now, today, tomorrow, and this week.',
              style: TextStyle(fontSize: 15),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by event, location, or category...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: openFilterSheet,
              icon: const Icon(Icons.tune),
              label: Text('Filter Events: $activeFilterText'),
            ),
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Nearby Events',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
                    child: Text('No events found.'),
                  )
                : ListView.builder(
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      return EventCard(event: filteredEvents[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}