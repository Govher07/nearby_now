import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../core/services/saved_event_service.dart';
import '../widgets/event_card.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late Future<List<Event>> savedEventsFuture;

  @override
  void initState() {
    super.initState();
    savedEventsFuture = fetchSavedEventDetails();
  }

  Future<List<Event>> fetchSavedEventDetails() async {
    return SavedEventService.fetchSavedEvents();
  }

  void refreshSavedEvents() {
    setState(() {
      savedEventsFuture = fetchSavedEventDetails();
    });
  }

  DateTime? parseEventDate(String date) {
    return DateTime.tryParse(date.trim());
  }

  bool isPastEvent(Event event) {
    final DateTime? eventDate = parseEventDate(event.date);

    if (eventDate == null) {
      return false;
    }

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return eventDate.isBefore(today);
  }

  List<Widget> buildEventSection({
    required String title,
    required List<Event> events,
    required bool useGrid,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Chip(
                label: Text('${events.length}'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
      if (events.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
            child: Text(
              title == 'Upcoming Events'
                  ? 'No upcoming saved events'
                  : 'No past saved events',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        )
      else if (useGrid)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              return EventCard(event: events[index]);
            }, childCount: events.length),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 420,
              mainAxisExtent: 410,
              crossAxisSpacing: 18,
              mainAxisSpacing: 18,
            ),
          ),
        )
      else
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return EventCard(event: events[index]);
          }, childCount: events.length),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh saved events',
            onPressed: refreshSavedEvents,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: savedEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load saved events.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final List<Event> savedEvents = snapshot.data ?? [];
          final List<Event> upcomingEvents =
              savedEvents.where((event) => !isPastEvent(event)).toList()
                ..sort((first, second) {
                  final DateTime? firstDate = parseEventDate(first.date);
                  final DateTime? secondDate = parseEventDate(second.date);

                  if (firstDate == null || secondDate == null) {
                    return 0;
                  }

                  return firstDate.compareTo(secondDate);
                });

          final List<Event> pastEvents = savedEvents.where(isPastEvent).toList()
            ..sort((first, second) {
              final DateTime? firstDate = parseEventDate(first.date);
              final DateTime? secondDate = parseEventDate(second.date);

              if (firstDate == null || secondDate == null) {
                return 0;
              }

              // Most recently finished events first.
              return secondDate.compareTo(firstDate);
            });

          if (savedEvents.isEmpty) {
            return const Center(
              child: Text(
                'No saved events yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool useGrid = constraints.maxWidth >= 700;

              return RefreshIndicator(
                onRefresh: () async {
                  refreshSavedEvents();
                  await savedEventsFuture;
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    ...buildEventSection(
                      title: 'Upcoming Events',
                      events: upcomingEvents,
                      useGrid: useGrid,
                    ),
                    ...buildEventSection(
                      title: 'Past Events',
                      events: pastEvents,
                      useGrid: useGrid,
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 30)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
