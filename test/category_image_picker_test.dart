import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_now/core/util/category_image_picker.dart';

void main() {
  group('CategoryImagePicker', () {
    test('returns network image when imageUrl is provided', () {
      final String image = CategoryImagePicker.imageForEvent(
        eventId: 'event-1',
        category: 'Music',
        imageUrl: 'https://example.com/image.jpg',
      );

      expect(image, 'https://example.com/image.jpg');
      expect(CategoryImagePicker.isNetworkImage(image), true);
    });

    test('returns asset image when imageUrl is null', () {
      final String image = CategoryImagePicker.imageForEvent(
        eventId: 'event-2',
        category: 'Music',
        imageUrl: null,
      );

      expect(image.startsWith('assets/images/'), true);
      expect(CategoryImagePicker.isNetworkImage(image), false);
    });

    test('same event id returns same cached image', () {
      final String firstImage = CategoryImagePicker.imageForEvent(
        eventId: 'event-3',
        category: 'Music',
        imageUrl: null,
      );

      final String secondImage = CategoryImagePicker.imageForEvent(
        eventId: 'event-3',
        category: 'Music',
        imageUrl: null,
      );

      expect(firstImage, secondImage);
    });

    test('unknown category returns default image', () {
      final String image = CategoryImagePicker.imageForEvent(
        eventId: 'event-4',
        category: 'Unknown Category',
        imageUrl: null,
      );

      expect(image.startsWith('assets/images/default/'), true);
    });

    test('detects network images correctly', () {
      expect(
        CategoryImagePicker.isNetworkImage('https://example.com/image.jpg'),
        true,
      );

      expect(
        CategoryImagePicker.isNetworkImage('http://example.com/image.jpg'),
        true,
      );

      expect(
        CategoryImagePicker.isNetworkImage('assets/images/music/music_1.jpg'),
        false,
      );
    });
  });
}