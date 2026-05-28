import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../core/services/event_service.dart';
import '../widgets/event_map.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Event>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = EventService.fetchEvents();
  }

  void refreshMap() {
    setState(() {
      eventsFuture = EventService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshMap,
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
                'Could not load map events.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final List<Event> events = snapshot.data ?? [];

          return EventMap(
            events: events,
            height: double.infinity,
          );
        },
      ),
    );
  }
}