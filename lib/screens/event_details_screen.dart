import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/event.dart';
import '../core/models/review.dart';
import '../core/services/event_service.dart';
import '../core/services/review_service.dart';
import '../core/services/saved_event_service.dart';
import '../core/data/current_user.dart';
import 'edit_event_screen.dart';
import '../core/services/directions_service.dart';
import '../widgets/event_map.dart';

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
  late Future<List<Review>> reviewsFuture;
  bool isEventSaved = false;

  bool get isSaved => isEventSaved;

  @override
  void initState() {
    super.initState();
    reviewsFuture = ReviewService.fetchReviews(widget.event.id);
  }

  void refreshReviews() {
    setState(() {
      reviewsFuture = ReviewService.fetchReviews(widget.event.id);
    });
  }

  double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) {
      return 0;
    }

    final int total = reviews.fold<int>(
      0,
      (sum, review) => sum + review.rating,
    );

    return total / reviews.length;
  }

  Future<void> toggleSave() async {
    final bool wasSaved = isSaved;
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      if (wasSaved) {
        await SavedEventService.removeSavedEvent(widget.event.id);
      } else {
        await SavedEventService.saveEvent(widget.event.id);
      }

      if (!mounted) return;

      setState(() {
        isEventSaved = !wasSaved;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            wasSaved ? 'Event removed from saved' : 'Event saved',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not update saved event: $error'),
        ),
      );
    }
  }

  Future<void> deleteEvent() async {
    final NavigatorState navigator = Navigator.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await EventService.deleteEvent(widget.event.id);

      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Event deleted'),
        ),
      );

      navigator.pop();
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not delete event: $error'),
        ),
      );
    }
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
                  onPressed: () async {
                    final String comment = reviewController.text.trim();

                    final Review newReview = Review(
                      id: '',
                      eventId: widget.event.id,
                      rating: selectedRating,
                      comment: comment.isEmpty
                          ? 'No written review'
                          : comment,
                    );

                    final NavigatorState navigator =
                        Navigator.of(dialogContext);
                    final ScaffoldMessengerState messenger =
                        ScaffoldMessenger.of(context);

                    try {
                      await ReviewService.createReview(
                        eventId: widget.event.id,
                        review: newReview,
                      );

                      if (!context.mounted) return;

                      reviewController.dispose();
                      navigator.pop();

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Rating submitted'),
                        ),
                      );

                      refreshReviews();
                    } catch (error) {
                      if (!context.mounted) return;

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Could not submit rating: $error'),
                        ),
                      );
                    }
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
      body: FutureBuilder<List<Review>>(
        future: reviewsFuture,
        builder: (context, snapshot) {
          final bool isLoading =
              snapshot.connectionState == ConnectionState.waiting;
          final List<Review> eventReviews = snapshot.data ?? [];
          final double averageRating = calculateAverageRating(eventReviews);

          return SingleChildScrollView(
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
                _buildRatingSummary(
                  isLoading: isLoading,
                  snapshot: snapshot,
                  eventReviews: eventReviews,
                  averageRating: averageRating,
                ),
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
                _buildReviewsSection(
                  isLoading: isLoading,
                  snapshot: snapshot,
                  eventReviews: eventReviews,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

 Widget _buildMapPlaceholder() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: EventMap(
      events: [widget.event],
      height: 200,
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
        Text(event.fullAddress),
      ],
    );
  }

  Widget _buildRatingSummary({
    required bool isLoading,
    required AsyncSnapshot<List<Review>> snapshot,
    required List<Review> eventReviews,
    required double averageRating,
  }) {
    if (isLoading) {
      return const Text('Loading ratings...');
    }

    if (snapshot.hasError) {
      return const Text('Could not load ratings');
    }

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
    if (currentUser?.role == 'business_owner') {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions),
        label: const Text('Get Directions'),
        onPressed: () async {
          try {
            await DirectionsService.openDirectionsToAddress(
              destinationAddress: widget.event.location,
            );
          } catch (error) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open directions: $error'),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    if (currentUser?.role == 'business_owner') {
      return _buildBusinessOwnerActions();
    }

    return _buildEventSeekerActions();
  }

  Widget _buildEventSeekerActions() {
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

  Widget _buildBusinessOwnerActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            tooltip: 'Edit event',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final bool? wasUpdated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(event: widget.event),
                ),
              );

              if (wasUpdated == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            tooltip: 'Delete event',
            icon: const Icon(Icons.delete_outline),
            onPressed: deleteEvent,
          ),
          IconButton(
            tooltip: 'View reviews',
            icon: const Icon(Icons.reviews_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reviews are shown below.'),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}


  Widget _buildReviewsSection({
    required bool isLoading,
    required AsyncSnapshot<List<Review>> snapshot,
    required List<Review> eventReviews,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return const Text('Could not load reviews.');
    }

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