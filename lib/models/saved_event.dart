class SavedEvent {
  final String id;
  final String eventId;

  const SavedEvent({
    required this.id,
    required this.eventId,
  });

  factory SavedEvent.fromJson(Map<String, dynamic> json) {
    return SavedEvent(
      id: json['id'].toString(),
      eventId: json['event_id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
    };
  }
}