import 'package:flutter/material.dart';

import '../data/business_events.dart';
import '../widgets/business_event_card.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  void refreshDashboard() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final int totalEvents = businessEvents.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Dashboard',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage and promote your local events.',
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: Text('$totalEvents Posted Events'),
                subtitle: const Text('Events you created for nearby users'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Views Coming Soon'),
                subtitle: Text('Track how many users viewed your events'),
              ),
            ),

            const Card(
              child: ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Saves Coming Soon'),
                subtitle: Text('Track how many users saved your events'),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Posted Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: businessEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'No events posted yet',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: businessEvents.length,
                      itemBuilder: (context, index) {
                        return BusinessEventCard(
                          event: businessEvents[index],
                          onDeleted: refreshDashboard,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}