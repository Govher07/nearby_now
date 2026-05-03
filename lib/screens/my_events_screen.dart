import 'package:flutter/material.dart';

import '../data/business_events.dart';
import '../widgets/business_event_card.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  void refreshEvents() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posted Events'),
      ),
      body: businessEvents.isEmpty
          ? const Center(
              child: Text(
                'No posted events yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: businessEvents.length,
              itemBuilder: (context, index) {
                return BusinessEventCard(
                  event: businessEvents[index],
                  onDeleted: refreshEvents,
                );
              },
            ),
    );
  }
}