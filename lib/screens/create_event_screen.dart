import 'package:flutter/material.dart';
import '../data/mock_events.dart';
import '../data/business_events.dart';
import '../models/event.dart';

class CreateEventScreen extends StatefulWidget {
  final VoidCallback? onEventPosted;

  const CreateEventScreen({
    super.key,
    this.onEventPosted,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String selectedDate = 'Today';
  String selectedCategory = 'Music';

  void postEvent() {
  if (titleController.text.isEmpty ||
      descriptionController.text.isEmpty ||
      locationController.text.isEmpty ||
      timeController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill in all fields')),
    );
    return;
  }

  final newEvent = Event(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: titleController.text,
    description: descriptionController.text,
    location: locationController.text,
    category: selectedCategory,
    date: selectedDate,
    time: timeController.text,
    distance: 0.5,
  );

  mockEvents.add(newEvent);
  businessEvents.add(newEvent);

  titleController.clear();
  descriptionController.clear();
  locationController.clear();
  timeController.clear();

  setState(() {
    selectedDate = 'Today';
    selectedCategory = 'Music';
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Event posted successfully')),
  );

  widget.onEventPosted?.call();
}

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 12),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time, e.g. 6:00 PM',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Now', child: Text('Now')),
                DropdownMenuItem(value: 'Today', child: Text('Today')),
                DropdownMenuItem(value: 'Tomorrow', child: Text('Tomorrow')),
                DropdownMenuItem(value: 'This Week', child: Text('This Week')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDate = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Music', child: Text('Music')),
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Art', child: Text('Art')),
                DropdownMenuItem(value: 'Community', child: Text('Community')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: postEvent,
                child: const Text('Post Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}