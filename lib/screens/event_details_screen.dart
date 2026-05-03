import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/reviews.dart';
import '../data/saved_events.dart';
import '../models/event.dart';
import '../models/review.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool get isSaved {
    return savedEvents.any(
      (savedEvent) => savedEvent.id == widget.event.id,
    );
  }

  List<Review> get eventReviews {
    return reviews
        .where((review) => review.eventId == widget.event.id)
        .toList();
  }

  double get averageRating {
    if (eventReviews.isEmpty) {
      return 0;
    }

    final int total = eventReviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / eventReviews.length;
  }

  void toggleSave() {
    final bool wasSaved = isSaved;

    setState(() {
      if (wasSaved) {
        savedEvents.removeWhere(
          (savedEvent) => savedEvent.id == widget.event.id,
        );
      } else {
        savedEvents.add(widget.event);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved ? 'Event removed from saved' : 'Event saved',
        ),
      ),
    );
  }

  void shareEvent() {
    final Event event = widget.event;

    final String shareText = '''
Check out this event on Nearby Now!

${event.title}
${event.date} at ${event.time}
Location: ${event.location}
Distance: ${event.distance} miles away

${event.description}
''';

    Clipboard.setData(
      ClipboardData(text: shareText),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event details copied to clipboard'),
      ),
    );
  }

  void openReviewDialog() {
    int selectedRating = 5;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Rate this event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Choose a rating'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final int starNumber = index + 1;

                      return IconButton(
                        icon: Icon(
                          starNumber <= selectedRating
                              ? Icons.star
                              : Icons.star_border,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = starNumber;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: 'Write a short review (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    reviewController.dispose();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String comment = reviewController.text.trim();

                    setState(() {
                      reviews.add(
                        Review(
                          eventId: widget.event.id,
                          rating: selectedRating,
                          comment: comment.isEmpty
                              ? 'No written review'
                              : comment,
                        ),
                      );
                    });

                    reviewController.dispose();
                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rating submitted'),
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Event event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapPlaceholder(),
            const SizedBox(height: 20),
            _buildEventTitle(event),
            const SizedBox(height: 8),
            _buildEventMeta(event),
            const SizedBox(height: 8),
            _buildRatingSummary(),
            const SizedBox(height: 20),
            Text(
              event.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            _buildDirectionsButton(),
            const SizedBox(height: 12),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text('Map / Event Image'),
      ),
    );
  }

  Widget _buildEventTitle(Event event) {
    return Text(
      event.title,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventMeta(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${event.date} at ${event.time}'),
        Text('${event.distance} miles away'),
        Text(event.location),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Row(
      children: [
        const Icon(Icons.star, size: 20),
        const SizedBox(width: 4),
        Text(
          eventReviews.isEmpty
              ? 'No ratings yet'
              : '${averageRating.toStringAsFixed(1)} (${eventReviews.length} reviews)',
        ),
      ],
    );
  }

  Widget _buildDirectionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions),
        label: const Text('Get Directions'),
        onPressed: () {},
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          tooltip: isSaved ? 'Remove from saved' : 'Save event',
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
          ),
          onPressed: toggleSave,
        ),
        IconButton(
          tooltip: 'Rate event',
          icon: const Icon(Icons.star_border),
          onPressed: openReviewDialog,
        ),
        IconButton(
          tooltip: 'Share event',
          icon: const Icon(Icons.share),
          onPressed: shareEvent,
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        eventReviews.isEmpty
            ? const Text(
                'No reviews yet. Be the first to rate this event.',
              )
            : Column(
                children: eventReviews.map((review) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text('${review.rating}/5 stars'),
                      subtitle: Text(review.comment),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}