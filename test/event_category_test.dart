import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_now/core/constants/event_categories.dart';

void main() {
  group('EventCategories', () {
    test('filters include All', () {
      expect(EventCategories.filters.contains('All'), true);
    });

    test('eventTypes does not include All', () {
      expect(EventCategories.eventTypes.contains('All'), false);
    });

    test('important categories are available', () {
      expect(EventCategories.eventTypes.contains('Music'), true);
      expect(EventCategories.eventTypes.contains('Sports'), true);
      expect(EventCategories.eventTypes.contains('Food'), true);
      expect(EventCategories.eventTypes.contains('Business'), true);
      expect(EventCategories.eventTypes.contains('Education'), true);
      expect(EventCategories.eventTypes.contains('Community'), true);
    });
  });
}