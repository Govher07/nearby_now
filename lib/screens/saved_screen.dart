import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../services/saved_event_service.dart';
import '../widgets/event_card.dart';
import '../models/saved_event.dart';

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
    final List<SavedEvent> savedRecords =
        await SavedEventService.fetchSavedEvents();

    final List<Event> allEvents = await EventService.fetchEvents();

    final Set<String> savedEventIds = savedRecords
        .map((savedEvent) => savedEvent.eventId)
        .toSet();

    final List<Event> savedEvents = allEvents.where((event) {
      return savedEventIds.contains(event.id);
    }).toList();

    return savedEvents;
  }

  void refreshSavedEvents() {
    setState(() {
      savedEventsFuture = fetchSavedEventDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshSavedEvents,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: savedEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
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

          if (savedEvents.isEmpty) {
            return const Center(
              child: Text(
                'No saved events yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: savedEvents.length,
            itemBuilder: (context, index) {
              return EventCard(event: savedEvents[index]);
            },
          );
        },
      ),
    );
  }
}