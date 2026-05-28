import 'package:flutter/material.dart';

import '../core/data/current_user.dart';
import '../core/models/event.dart';
import '../core/services/event_service.dart';

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
  final TextEditingController addressLineController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String selectedDate = 'Today';
  String selectedCategory = 'Music';
  bool isPosting = false;

  String get fullAddress {
    return '${addressLineController.text.trim()}, '
        '${cityController.text.trim()}, '
        '${stateController.text.trim()}, '
        '${countryController.text.trim()} '
        '${zipCodeController.text.trim()}';
  }

  Future<void> postEvent() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        addressLineController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        zipCodeController.text.trim().isEmpty ||
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
      location: fullAddress,
      category: selectedCategory,
      date: selectedDate,
      time: timeController.text.trim(),
      distance: 0.5,
      latitude: 40.785091,
      longitude: -73.968285,
      ownerId: currentUser?.id,
      addressLine: addressLineController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      zipCode: zipCodeController.text.trim(),
    );

    setState(() {
      isPosting = true;
    });

    try {
      await EventService.createEvent(newEvent);

      if (!mounted) return;

      titleController.clear();
      descriptionController.clear();
      addressLineController.clear();
      cityController.clear();
      stateController.clear();
      countryController.clear();
      zipCodeController.clear();
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
      if (!mounted) return;

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
    addressLineController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipCodeController.dispose();
    timeController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
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
            buildTextField(
              controller: titleController,
              label: 'Event Name',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: descriptionController,
              label: 'Description',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: addressLineController,
              label: 'Address Line',
              hint: 'Example: 1738 16th Ave NE',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: cityController,
              label: 'City',
              hint: 'Example: Issaquah',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: stateController,
              label: 'State',
              hint: 'Example: WA',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: countryController,
              label: 'Country',
              hint: 'Example: United States',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: zipCodeController,
              label: 'ZIP Code',
              hint: 'Example: 98027',
            ),
            const SizedBox(height: 12),
            buildTextField(
              controller: timeController,
              label: 'Time, e.g. 6:00 PM',
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