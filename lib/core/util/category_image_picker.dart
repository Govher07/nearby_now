import 'dart:math';

class CategoryImagePicker {
  static final Random _random = Random();

  static final Map<String, String> _eventImageCache = {};

  static const Map<String, List<String>> _imagesByCategory = {
    'Music': [
      'assets/images/music/music_1.jpg',
      'assets/images/music/music_2.jpg',
      'assets/images/music/music_3.jpg',
    ],
    'Sports': [
      'assets/images/sports/sports_1.jpg',
      'assets/images/sports/sports_2.jpg',
      'assets/images/sports/sports_3.jpg',
    ],
    'Food': [
      'assets/images/food/food_1.jpg',
      'assets/images/food/food_2.jpg',
      'assets/images/food/food_3.jpg',
    ],
    'Social': [
      'assets/images/social/social_1.jpg',
      'assets/images/social/social_2.jpg',
      'assets/images/social/social_3.jpg',
    ],
    'Art': [
      'assets/images/art/art_1.jpg',
      'assets/images/art/art_2.jpg',
      'assets/images/art/art_3.jpg',
    ],
    'Comedy': [
      'assets/images/comedy/comedy_1.jpg',
      'assets/images/comedy/comedy_2.jpg',
      'assets/images/comedy/comedy_3.jpg',
    ],
    'Family': [
      'assets/images/family/family_1.jpg',
      'assets/images/family/family_2.jpg',
      'assets/images/family/family_3.jpg',
    ],
    'Nightlife': [
      'assets/images/nightlife/nightlife_1.jpg',
      'assets/images/nightlife/nightlife_2.jpg',
      'assets/images/nightlife/nightlife_3.jpg',
    ],
    'Outdoor': [
      'assets/images/outdoor/outdoor_1.jpg',
      'assets/images/outdoor/outdoor_2.jpg',
      'assets/images/outdoor/outdoor_3.jpg',
    ],
    'Fitness': [
      'assets/images/fitness/fitness_1.jpg',
      'assets/images/fitness/fitness_2.jpg',
      'assets/images/fitness/fitness_3.jpg',
    ],
    'Business': [
      'assets/images/business/business_1.jpg',
      'assets/images/business/business_2.jpg',
      'assets/images/business/business_3.jpg',
    ],
    
    'Education': [
      'assets/images/education/education_1.jpg',
      'assets/images/education/education_2.jpg',
      'assets/images/education/education_3.jpg',
    ],
    'Community': [
      'assets/images/community/community_1.jpg',
      'assets/images/community/community_2.jpg',
      'assets/images/community/community_3.jpg',
    ],
    'Theater': [
      'assets/images/theater/theater_1.jpg',
      'assets/images/theater/theater_2.jpg',
      'assets/images/theater/theater_3.jpg',
    ],
    'Market': [
      'assets/images/market/market_1.jpg',
      'assets/images/market/market_2.jpg',
      'assets/images/market/market_3.jpg',
    ],
    'Charity': [
      'assets/images/charity/charity_1.jpg',
      'assets/images/charity/charity_2.jpg',
      'assets/images/charity/charity_3.jpg',
    ],
    'Default': [
      'assets/images/default/default_1.jpg',
      'assets/images/default/default_2.jpg',
      'assets/images/default/default_3.jpg',
    ],
  };

  static String imageForEvent({
    required String eventId,
    required String category,
    String? imageUrl,
    String? previousImagePath,
  }) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return imageUrl.trim();
    }

    if (_eventImageCache.containsKey(eventId)) {
      return _eventImageCache[eventId]!;
    }

    final List<String> categoryImages =
        _imagesByCategory[category] ?? _imagesByCategory['Default']!;

    List<String> availableImages = categoryImages;

    if (previousImagePath != null && categoryImages.length > 1) {
      availableImages = categoryImages
          .where((imagePath) => imagePath != previousImagePath)
          .toList();
    }

    final String selectedImage =
        availableImages[_random.nextInt(availableImages.length)];

    _eventImageCache[eventId] = selectedImage;

    return selectedImage;
  }

  static bool isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }
}