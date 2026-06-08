import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_now/core/models/event.dart';

void main() {
  group('Event model', () {
    test('creates Event from JSON with all fields', () {
      final Map<String, dynamic> json = {
        'id': 'event-1',
        'title': 'Jazz Night',
        'description': 'Live jazz event',
        'category': 'Music',
        'date': '2026-06-03',
        'time': '9:00 PM',
        'distance': 2.5,
        'location': 'Seattle',
        'address_line': '901 12th Ave',
        'city': 'Seattle',
        'state': 'WA',
        'country': 'USA',
        'zip_code': '98122',
        'latitude': 47.6101,
        'longitude': -122.3182,
        'owner_id': 'owner-1',
        'image_url': 'https://example.com/image.jpg',
        'source': 'local',
        'views': 5,
      };

      final Event event = Event.fromJson(json);

      expect(event.id, 'event-1');
      expect(event.title, 'Jazz Night');
      expect(event.description, 'Live jazz event');
      expect(event.category, 'Music');
      expect(event.date, '2026-06-03');
      expect(event.time, '9:00 PM');
      expect(event.distance, 2.5);
      expect(event.location, 'Seattle');
      expect(event.addressLine, '901 12th Ave');
      expect(event.city, 'Seattle');
      expect(event.state, 'WA');
      expect(event.country, 'USA');
      expect(event.zipCode, '98122');
      expect(event.latitude, 47.6101);
      expect(event.longitude, -122.3182);
      expect(event.ownerId, 'owner-1');
      expect(event.imageUrl, 'https://example.com/image.jpg');
      expect(event.source, 'local');
    });

    test('fullAddress uses address fields when available', () {
      final Event event = Event(
        id: 'event-1',
        title: 'Kids Dance',
        description: 'Dance event',
        category: 'Family',
        date: '2026-06-03',
        time: '6:00 PM',
        distance: 1.0,
        location: 'Old location',
        latitude: 47.5301,
        longitude: -122.0326,
        ownerId: 'owner-1',
        imageUrl: null,
        source: 'local',
        addressLine: '1801 12th Ave',
        city: 'Issaquah',
        state: 'WA',
        country: 'USA',
        zipCode: '98029',
      );

      expect(
        event.fullAddress,
        contains('1801 12th Ave'),
      );
      expect(
        event.fullAddress,
        contains('Issaquah'),
      );
    });

    test('fullAddress falls back to location when address fields are empty', () {
      final Event event = Event(
        id: 'event-1',
        title: 'Jazz',
        description: 'Music event',
        category: 'Music',
        date: '2026-06-03',
        time: '8:00 PM',
        distance: 1.0,
        location: 'Seattle',
        latitude: 47.6062,
        longitude: -122.3321,
        ownerId: 'owner-1',
        imageUrl: null,
        source: 'local',
      );

      expect(event.fullAddress, 'Seattle');
    });
  });
}