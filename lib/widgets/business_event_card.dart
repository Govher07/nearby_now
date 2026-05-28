import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../screens/event_details_screen.dart';
import '../core/services/event_service.dart';

class BusinessEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onDeleted;

  const BusinessEventCard({
    super.key,
    required this.event,
    required this.onDeleted,
  });

  Future<void> deleteEvent(BuildContext context) async {
    try {
      await EventService.deleteEvent(event.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event deleted'),
        ),
      );

      onDeleted();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not delete event: $error'),
        ),
      );
    }
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
          '${event.date} • ${event.time}\n${event.location} • ${event.category}',
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        trailing: IconButton(
          tooltip: 'Delete event',
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            confirmDelete(context);
          },
        ),
      ),
    );
  }
}