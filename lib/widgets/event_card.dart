import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../../screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  String get fallbackImage {
    switch (event.category.toLowerCase()) {
      case 'music':
        return 'assets/images/music_event.jpg';
      case 'food':
        return 'assets/images/food_event.jpg';
      case 'art':
      case 'arts & theatre':
        return 'assets/images/art_event.jpg';
      default:
        return 'assets/images/default_event.jpg';
    }
  }

  bool get isExternal {
    return event.source == 'ticketmaster';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(event: event),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? Image.network(
                    event.imageUrl!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        fallbackImage,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.asset(
                    fallbackImage,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(event.category),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      if (isExternal)
                        const Chip(
                          label: Text('Ticketmaster'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text('${event.date} • ${event.time}'),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 17),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(event.fullAddress),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.directions_walk, size: 17),
                      const SizedBox(width: 6),
                      Text('${event.distance} miles away'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}