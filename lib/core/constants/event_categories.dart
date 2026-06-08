class EventCategories {
  static const List<String> eventTypes = [
    'Music',
    'Sports',
    'Food',
    'Social',
    'Art',
    'Comedy',
    'Family',
    'Nightlife',
    'Outdoor',
    'Fitness',
    'Business',
    'Education',
    'Community',
    'Theater',
    'Market',
    'Charity',
  ];

  static const List<String> filters = [
    'All',
    'Popular',
    ...eventTypes,
  ];
}