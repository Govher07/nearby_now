import 'package:flutter/material.dart';

import '../data/business_events.dart';
import '../data/mock_events.dart';
import '../data/reviews.dart';
import '../data/saved_events.dart';
import '../models/event.dart';
import '../screens/event_details_screen.dart';

class BusinessEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onDeleted;

  const BusinessEventCard({
    super.key,
    required this.event,
    required this.onDeleted,
  });

  void deleteEvent(BuildContext context) {
    businessEvents.removeWhere((item) => item.id == event.id);
    mockEvents.removeWhere((item) => item.id == event.id);
    savedEvents.removeWhere((item) => item.id == event.id);
    reviews.removeWhere((review) => review.eventId == event.id);

    onDeleted();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event deleted'),
      ),
    );
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete event?'),
          content: Text(
            'Are you sure you want to delete "${event.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteEvent(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text(
          '${event.date} • ${event.time} • ${event.location}',
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            confirmDelete(context);
          },
        ),
      ),
    );
  }
}