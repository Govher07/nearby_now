import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';

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
  bool isPosting = false;

  Future<void> postEvent() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final Event newEvent = Event(
      id: '',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      category: selectedCategory,
      date: selectedDate,
      time: timeController.text.trim(),
      distance: 0.5,
    );

    setState(() {
      isPosting = true;
    });

    try {
      await EventService.createEvent(newEvent);

      if (!mounted) return;

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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post event: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
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
                onPressed: isPosting ? null : postEvent,
                child: isPosting
                    ? const Text('Posting...')
                    : const Text('Post Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}