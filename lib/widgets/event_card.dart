import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../core/util/category_image_picker.dart';
import '../screens/event_details_screen.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  bool get isExternal {
    return event.source == 'ticketmaster';
  }

  Widget buildEventImage() {
    final String imagePath = CategoryImagePicker.imageForEvent(
      eventId: event.id,
      category: event.category,
      imageUrl: event.imageUrl,
    );

    if (CategoryImagePicker.isNetworkImage(imagePath)) {
      return Image.network(
        imagePath,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildImageFallback();
        },
      );
    }

    return Image.asset(
      imagePath,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return buildImageFallback();
      },
    );
  }

  Widget buildImageFallback() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 36,
          ),
          SizedBox(height: 6),
          Text('Image not available'),
        ],
      ),
    );
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
            buildEventImage(),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text(event.category),
                        visualDensity: VisualDensity.compact,
                      ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          '${event.date} • ${event.time}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 17),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  if (event.distance > 0)
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, size: 17),
                        const SizedBox(width: 6),
                        Text('${event.distance.toStringAsFixed(1)} miles away'),
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