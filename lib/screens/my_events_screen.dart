import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/business_event_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  late Future<List<Event>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = EventService.fetchEvents();
  }

  void refreshEvents() {
    setState(() {
      eventsFuture = EventService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshEvents,
          ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Could not load events.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final List<Event> events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(
              child: Text(
                'No posted events yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              return BusinessEventCard(
                event: events[index],
                onDeleted: refreshEvents,
              );
            },
          );
        },
      ),
    );
  }
}