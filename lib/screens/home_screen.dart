import 'package:flutter/material.dart';

import '../core/app_mode.dart' as app_mode;
import '../core/constants/event_categories.dart';
import '../core/data/current_user.dart';
import '../core/models/event.dart';
import '../core/services/event_service.dart';
import '../widgets/event_card.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedTime = 'All';
  String selectedCategory = 'All';
  String searchQuery = '';
  bool isSearchVisible = false;
  bool isWebFilterVisible = false;

  late Future<List<Event>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = EventService.fetchAllEvents();
  }

  void refreshEvents() {
    setState(() {
      eventsFuture = EventService.fetchAllEvents();
    });
  }

  List<Event> applyFilters(List<Event> events) {
    List<Event> filteredEvents = events;

    if (selectedTime != 'All') {
      filteredEvents = filteredEvents.where(matchesSelectedTime).toList();
    }

    if (selectedCategory != 'All') {
      filteredEvents = filteredEvents
          .where((event) => event.category == selectedCategory)
          .toList();
    }

    if (searchQuery.isNotEmpty) {
      final String query = searchQuery.toLowerCase();

      filteredEvents = filteredEvents.where((event) {
        return event.title.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.fullAddress.toLowerCase().contains(query);
      }).toList();
    }

    filteredEvents.sort(compareEventsByPriority);
    return filteredEvents;
  }

  bool matchesSelectedTime(Event event) {
    final DateTime? eventDate = parseEventDate(event.date);

    if (eventDate == null) {
      return false;
    }

    final DateTime today = dateOnly(DateTime.now());
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

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? parseEventDate(String value) {
    final String cleanedValue = value.trim();

    if (cleanedValue.isEmpty) {
      return null;
    }

    final DateTime today = dateOnly(DateTime.now());

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

  void openFilterSheet() {
    String tempTime = selectedTime;
    String tempCategory = selectedCategory;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.70,
              minChildSize: 0.45,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Events',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'When?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          buildSheetChip('All', tempTime, (value) {
                            setSheetState(() {
                              tempTime = value;
                            });
                          }),
                          buildSheetChip('Now', tempTime, (value) {
                            setSheetState(() {
                              tempTime = value;
                            });
                          }),
                          buildSheetChip('Today', tempTime, (value) {
                            setSheetState(() {
                              tempTime = value;
                            });
                          }),
                          buildSheetChip('Tomorrow', tempTime, (value) {
                            setSheetState(() {
                              tempTime = value;
                            });
                          }),
                          buildSheetChip('This Week', tempTime, (value) {
                            setSheetState(() {
                              tempTime = value;
                            });
                          }),
                        ],
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EventCategories.filters.map((category) {
                          return ChoiceChip(
                            label: Text(category),
                            selected: tempCategory == category,
                            onSelected: (_) {
                              setSheetState(() {
                                tempCategory = category;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedTime = tempTime;
                              selectedCategory = tempCategory;
                            });

                            Navigator.pop(context);
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              selectedTime = 'All';
                              selectedCategory = 'All';
                            });

                            Navigator.pop(context);
                          },
                          child: const Text('Clear Filters'),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildSheetChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == label,
      onSelected: (_) {
        onSelected(label);
      },
    );
  }

  Widget buildGuestAuthBanner() {
    if (currentUser != null) {
      return const SizedBox.shrink();
    }

    final bool isBusinessMode = app_mode.selectedAppRole == 'business_owner';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  isBusinessMode
                      ? 'Sign in or register to manage your business events.'
                      : 'Browse events as a guest, or sign in to save events.',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: openLoginScreen,
                child: const Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: openRegisterScreen,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildWebAuthActions() {
    if (currentUser != null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        TextButton(
          onPressed: openLoginScreen,
          child: const Text('Sign In'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: openRegisterScreen,
          child: const Text('Register'),
        ),
      ],
    );
  }

  void openLoginScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  void openRegisterScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterScreen(
          selectedRole: app_mode.selectedAppRole,
        ),
      ),
    );
  }

  String get activeFilterText {
    if (selectedTime == 'All' && selectedCategory == 'All') {
      return 'All events';
    }

    if (selectedTime != 'All' && selectedCategory != 'All') {
      return '$selectedTime • $selectedCategory';
    }

    if (selectedTime != 'All') {
      return selectedTime;
    }

    return selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: isWebLayout
          ? null
          : AppBar(
              title: const Text('Nearby Now'),
              actions: [
                IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      isSearchVisible = !isSearchVisible;
                    });
                  },
                ),
                IconButton(
                  tooltip: 'Filter',
                  icon: const Icon(Icons.tune),
                  onPressed: openFilterSheet,
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: refreshEvents,
                ),
              ],
            ),
      body: isWebLayout ? buildWebBody() : buildMobileBody(),
    );
  }

  Widget buildMobileBody() {
    return Column(
      children: [
        if (isSearchVisible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      isSearchVisible = false;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          child: Row(
            children: [
              Text(
                activeFilterText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        //buildGuestAuthBanner(),

        Expanded(
          child: buildEventsList(),
        ),
      ],
    );
  }

  Widget buildEventsList() {
    return FutureBuilder<List<Event>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load events.\n${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        final List<Event> events = snapshot.data ?? [];
        final List<Event> filteredEvents = applyFilters(events);

        if (filteredEvents.isEmpty) {
          return const Center(
            child: Text('No events found.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            return EventCard(event: filteredEvents[index]);
          },
        );
      },
    );
  }

  Widget buildWebBody() {
    return Column(
      children: [
        Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              const Text(
                'Nearby Now',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 32),

              const Text(
                'Discover events near you',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),

              const Spacer(),

              IconButton(
                tooltip: isWebFilterVisible ? 'Hide filters' : 'Show filters',
                icon: Icon(
                  isWebFilterVisible
                      ? Icons.filter_alt_off_outlined
                      : Icons.tune,
                ),
                onPressed: () {
                  setState(() {
                    isWebFilterVisible = !isWebFilterVisible;
                  });
                },
              ),

              const SizedBox(width: 12),

              SizedBox(
                width: 320,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search events...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    isDense: true,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              buildWebAuthActions(),

              // Space for the floating profile button from MainNavigationScreen.
              const SizedBox(width: 72),
            ],
          ),
        ),

        Expanded(
          child: Row(
            children: [
              if (isWebFilterVisible) buildWebFilterPanel(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: FutureBuilder<List<Event>>(
                    future: eventsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Could not load events.\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final List<Event> events = snapshot.data ?? [];
                      final List<Event> filteredEvents = applyFilters(events);

                      if (filteredEvents.isEmpty) {
                        return const Center(
                          child: Text('No events found.'),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeFilterText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Expanded(
                            child: GridView.builder(
                              itemCount: filteredEvents.length,
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 420,
                                mainAxisExtent: 380,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                              ),
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: SingleChildScrollView(
                                    child: EventCard(
                                      event: filteredEvents[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildWebFilterPanel() {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.3),
          ),
        ),
      ),
      child: ListView(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close filters',
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    isWebFilterVisible = false;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'When?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              buildWebChip('All', selectedTime, (value) {
                setState(() {
                  selectedTime = value;
                });
              }),
              buildWebChip('Now', selectedTime, (value) {
                setState(() {
                  selectedTime = value;
                });
              }),
              buildWebChip('Today', selectedTime, (value) {
                setState(() {
                  selectedTime = value;
                });
              }),
              buildWebChip('Tomorrow', selectedTime, (value) {
                setState(() {
                  selectedTime = value;
                });
              }),
              buildWebChip('This Week', selectedTime, (value) {
                setState(() {
                  selectedTime = value;
                });
              }),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EventCategories.filters.map((category) {
              return ChoiceChip(
                label: Text(category),
                selected: selectedCategory == category,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          OutlinedButton(
            onPressed: () {
              setState(() {
                selectedTime = 'All';
                selectedCategory = 'All';
                searchQuery = '';
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget buildWebChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedValue == label,
      onSelected: (_) {
        onSelected(label);
      },
    );
  }
DateTime? parseEventStartDateTime(String dateValue, String timeValue) {
  try {
    final DateTime? parsedDate = parseEventDate(dateValue);

    if (parsedDate == null) {
      return null;
    }

    final String cleanedTime = timeValue.trim().toUpperCase();

    if (cleanedTime.isEmpty || cleanedTime == 'UNKNOWN TIME') {
      return null;
    }

    // Supports: 9:00 PM, 09:00 PM, 18:00, 18:00:00
    final RegExp amPmPattern = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
    );

    final RegExp twentyFourHourPattern = RegExp(
      r'^(\d{1,2}):(\d{2})(?::\d{2})?$',
    );

    int hour;
    int minute;

    final Match? amPmMatch = amPmPattern.firstMatch(cleanedTime);

    if (amPmMatch != null) {
      hour = int.parse(amPmMatch.group(1)!);
      minute = int.parse(amPmMatch.group(2)!);

      final String period = amPmMatch.group(3)!;

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }
    } else {
      final Match? twentyFourHourMatch =
          twentyFourHourPattern.firstMatch(cleanedTime);

      if (twentyFourHourMatch == null) {
        return null;
      }

      hour = int.parse(twentyFourHourMatch.group(1)!);
      minute = int.parse(twentyFourHourMatch.group(2)!);
    }

    return DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
      hour,
      minute,
    );
  } catch (_) {
    return null;
  }
}

int eventPriority(Event event) {
  final DateTime now = DateTime.now();

  final DateTime? eventStart = parseEventStartDateTime(
    event.date,
    event.time,
  );

  final bool isVeryClose = event.distance <= 2.0;
  final bool isNearby = event.distance <= 10.0;

  bool isStartingSoon = false;
  bool isToday = false;

  if (eventStart != null) {
    final int minutesUntilStart = eventStart.difference(now).inMinutes;

    isStartingSoon = minutesUntilStart >= 0 && minutesUntilStart <= 60;

    isToday = dateOnly(eventStart) == dateOnly(now);
  }

  // Top group: very close and happening soon.
  if (isVeryClose && isStartingSoon) {
    return 0;
  }

  // Middle group: nearby or happening today.
  if (isNearby && isToday) {
    return 1;
  }

  // End group: everything else.
  return 2;
}

int compareEventsByPriority(Event first, Event second) {
  final int firstPriority = eventPriority(first);
  final int secondPriority = eventPriority(second);

  if (firstPriority != secondPriority) {
    return firstPriority.compareTo(secondPriority);
  }

  final DateTime? firstStart = parseEventStartDateTime(
    first.date,
    first.time,
  );

  final DateTime? secondStart = parseEventStartDateTime(
    second.date,
    second.time,
  );

  if (firstStart != null && secondStart != null) {
    final int timeCompare = firstStart.compareTo(secondStart);

    if (timeCompare != 0) {
      return timeCompare;
    }
  }

  return first.distance.compareTo(second.distance);
}

}