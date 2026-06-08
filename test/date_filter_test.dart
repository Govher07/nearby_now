import 'package:flutter_test/flutter_test.dart';

DateTime dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime? parseEventDate(String value, DateTime now) {
  final String cleanedValue = value.trim();

  if (cleanedValue.isEmpty) {
    return null;
  }

  final DateTime today = dateOnly(now);

  if (cleanedValue.toLowerCase() == 'today') {
    return today;
  }

  if (cleanedValue.toLowerCase() == 'tomorrow') {
    return today.add(const Duration(days: 1));
  }

  try {
    return DateTime.parse(cleanedValue);
  } catch (_) {
    return null;
  }
}

bool matchesSelectedTime({
  required String selectedTime,
  required String eventDateValue,
  required DateTime now,
}) {
  final DateTime? eventDate = parseEventDate(eventDateValue, now);

  if (eventDate == null) {
    return false;
  }

  final DateTime today = dateOnly(now);
  final DateTime eventDay = dateOnly(eventDate);
  final DateTime tomorrow = today.add(const Duration(days: 1));
  final DateTime endOfThisWeek = today.add(const Duration(days: 7));

  switch (selectedTime) {
    case 'Now':
      return eventDay == today;

    case 'Today':
      return eventDay == today;

    case 'Tomorrow':
      return eventDay == tomorrow;

    case 'This Week':
      return eventDay.isAtSameMomentAs(today) ||
          eventDay.isAtSameMomentAs(endOfThisWeek) ||
          eventDay.isAfter(today) && eventDay.isBefore(endOfThisWeek);

    default:
      return true;
  }
}

void main() {
  group('Date filter logic', () {
    final DateTime fakeNow = DateTime(2026, 6, 3);

    test('Today matches today date', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'Today',
        eventDateValue: '2026-06-03',
        now: fakeNow,
      );

      expect(result, true);
    });

    test('Tomorrow matches tomorrow date', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'Tomorrow',
        eventDateValue: '2026-06-04',
        now: fakeNow,
      );

      expect(result, true);
    });

    test('This Week matches date within 7 days', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'This Week',
        eventDateValue: '2026-06-08',
        now: fakeNow,
      );

      expect(result, true);
    });

    test('This Week does not match far future date', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'This Week',
        eventDateValue: '2026-07-01',
        now: fakeNow,
      );

      expect(result, false);
    });

    test('invalid date does not match', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'Today',
        eventDateValue: 'bad-date',
        now: fakeNow,
      );

      expect(result, false);
    });

    test('All always matches valid date', () {
      final bool result = matchesSelectedTime(
        selectedTime: 'All',
        eventDateValue: '2026-07-01',
        now: fakeNow,
      );

      expect(result, true);
    });
  });
}