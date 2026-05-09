import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../widgets/business_event_card.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  late Future<List<Event>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = EventService.fetchEvents();
  }

  void refreshDashboard() {
    setState(() {
      eventsFuture = EventService.fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        final List<Event> events = snapshot.data ?? [];
        final int totalEvents = events.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Business Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refreshDashboard,
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Dashboard',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Manage and promote your local events.',
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text('$totalEvents Posted Events'),
                    subtitle: const Text('Events you created for nearby users'),
                  ),
                ),

                const Card(
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('Views Coming Soon'),
                    subtitle: Text('Track how many users viewed your events'),
                  ),
                ),

                const Card(
                  child: ListTile(
                    leading: Icon(Icons.bookmark),
                    title: Text('Saves Coming Soon'),
                    subtitle: Text('Track how many users saved your events'),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Recent Posted Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Expanded(
                  child: _buildEventsSection(
                    isLoading: isLoading,
                    snapshot: snapshot,
                    events: events,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsSection({
    required bool isLoading,
    required AsyncSnapshot<List<Event>> snapshot,
    required List<Event> events,
  }) {
    if (isLoading) {
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

    if (events.isEmpty) {
      return const Center(
        child: Text(
          'No events posted yet',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return BusinessEventCard(
          event: events[index],
          onDeleted: refreshDashboard,
        );
      },
    );
  }
}