import 'package:flutter/material.dart';
import '../data/saved_events.dart';
import '../widgets/event_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
      ),
      body: savedEvents.isEmpty
          ? const Center(
              child: Text(
                'No saved events yet',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: savedEvents.length,
              itemBuilder: (context, index) {
                return EventCard(event: savedEvents[index]);
              },
            ),
    );
  }
}