class Review {
  final String id;
  final String eventId;
  final int rating;
  final String comment;

  const Review({
    required this.id,
    required this.eventId,
    required this.rating,
    required this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
    };
  }
}