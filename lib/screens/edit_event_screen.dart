import 'package:flutter/material.dart';

import '../core/models/event.dart';
import '../core/services/event_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({
    super.key,
    required this.event,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController timeController;

  late String selectedDate;
  late String selectedCategory;

  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.event.title);
    descriptionController =
        TextEditingController(text: widget.event.description);
    locationController = TextEditingController(text: widget.event.location);
    timeController = TextEditingController(text: widget.event.time);

    selectedDate = widget.event.date;
    selectedCategory = widget.event.category;
  }

  Future<void> updateEvent() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final Event updatedEvent = Event(
      id: widget.event.id,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      location: locationController.text.trim(),
      category: selectedCategory,
      date: selectedDate,
      time: timeController.text.trim(),
      distance: widget.event.distance,
      latitude: widget.event.latitude,
      longitude: widget.event.longitude,
      ownerId: widget.event.ownerId,
    );

    setState(() {
      isUpdating = true;
    });

    try {
      await EventService.updateEvent(
        eventId: widget.event.id,
        event: updatedEvent,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update event: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
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
        title: const Text('Edit Event'),
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
                onPressed: isUpdating ? null : updateEvent,
                child: Text(isUpdating ? 'Updating...' : 'Update Event'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}