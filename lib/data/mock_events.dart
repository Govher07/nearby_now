import '../models/event.dart';

final List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Live Music in the Park',
    description: 'Enjoy live music from local artists in the park. Bring a blanket, relax with friends, and spend the evening outdoors nearby.',
    location: 'Central Park',
    category: 'Music',
    date: 'Today',
    time: '6:00 PM',
    distance: 0.4,
  ),
  Event(
    id: '2',
    title: 'Food Truck Festival',
    description: 'Try food from local vendors and enjoy a casual outdoor community event.',
    location: 'Downtown Plaza',
    category: 'Food',
    date: 'Tomorrow',
    time: '12:00 PM',
    distance: 1.2,
  ),
  Event(
    id: '3',
    title: 'Art Walk',
    description: 'Explore local art displays, small galleries, and creative pop-up booths.',
    location: 'Main Street',
    category: 'Art',
    date: 'This Week',
    time: '3:00 PM',
    distance: 0.8,
  ),
];