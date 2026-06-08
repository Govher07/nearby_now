import 'package:flutter/material.dart';

import '../core/constants/event_categories.dart';
import '../core/data/current_user.dart';
import '../core/models/event.dart';
import '../core/services/event_service.dart';
import '../core/services/geocoding_service.dart';

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

  DateTime? selectedDate;

  String selectedCategory = 'Music';
  bool isPosting = false;

  List<String> get availableCategories {
    return EventCategories.filters
        .where((category) => category != 'All' && category != 'Popular')
        .toList();
  }

  String get fullAddress {
    final List<String> parts = [
      addressLineController.text.trim(),
      cityController.text.trim(),
      stateController.text.trim(),
      countryController.text.trim(),
      zipCodeController.text.trim(),
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  String get formattedSelectedDate {
    if (selectedDate == null) {
      return 'Select date';
    }

    final DateTime date = selectedDate!;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> pickEventDate() async {
    final DateTime today = dateOnly(DateTime.now());

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 3),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  bool validateFields() {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        addressLineController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        zipCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all event details.'),
        ),
      );

      return false;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an event date.'),
        ),
      );

      return false;
    }

    if (timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an event time.'),
        ),
      );

      return false;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in as a business owner first.'),
        ),
      );

      return false;
    }

    return true;
  }

  Future<void> postEvent() async {
    if (!validateFields()) {
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      final geocodedLocation = await GeocodingService.geocodeAddress(fullAddress);

      final Event newEvent = Event(
        id: '',
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        location: fullAddress,
        category: selectedCategory,
        date: formattedSelectedDate,
        time: timeController.text.trim(),
        distance: 0.0,
        latitude: geocodedLocation.latitude,
        longitude: geocodedLocation.longitude,
        ownerId: currentUser!.id,
        imageUrl: null,
        source: 'local',
        addressLine: addressLineController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: countryController.text.trim(),
        zipCode: zipCodeController.text.trim(),
      );

      await EventService.createEvent(newEvent);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event posted successfully.'),
        ),
      );

      widget.onEventPosted?.call();

      if (!mounted) {
        return;
      }

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not post event. Please check the address and try again.\n$error',
          ),
        ),
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
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !isPosting,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildDatePickerField() {
    final bool hasDate = selectedDate != null;

    return InkWell(
      onTap: isPosting ? null : pickEventDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          formattedSelectedDate,
          style: TextStyle(
            color: hasDate
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).hintColor,
          ),
        ),
      ),
    );
  }

  Widget buildTimeTextField() {
    return TextField(
      controller: timeController,
      enabled: !isPosting,
      keyboardType: TextInputType.datetime,
      decoration: const InputDecoration(
        labelText: 'Time',
        hintText: 'Example: 9:00 PM',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.access_time),
      ),
    );
  }

  Widget buildCategoryDropdown() {
    final List<String> categories = availableCategories;

    if (!categories.contains(selectedCategory) && categories.isNotEmpty) {
      selectedCategory = categories.first;
    }

    return DropdownButtonFormField<String>(
      value: selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: isPosting
          ? null
          : (value) {
              if (value == null) {
                return;
              }

              setState(() {
                selectedCategory = value;
              });
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isWebLayout ? 760 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                isWebLayout ? 32 : 16,
                16,
                isWebLayout ? 32 : 16,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isWebLayout)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Text(
                        'Create a new event',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  buildTextField(
                    controller: titleController,
                    label: 'Event Name',
                    hint: 'Example: Jazz Night',
                  ),

                  const SizedBox(height: 12),

                  buildTextField(
                    controller: descriptionController,
                    label: 'Description',
                    hint: 'Describe your event',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 12),

                  buildTextField(
                    controller: addressLineController,
                    label: 'Address Line',
                    hint: 'Example: 901 12th Ave',
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: cityController,
                          label: 'City',
                          hint: 'Example: Seattle',
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: buildTextField(
                          controller: stateController,
                          label: 'State',
                          hint: 'WA',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                          controller: countryController,
                          label: 'Country',
                          hint: 'United States',
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 140,
                        child: buildTextField(
                          controller: zipCodeController,
                          label: 'ZIP Code',
                          hint: '98122',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: buildDatePickerField(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: buildTimeTextField(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  buildCategoryDropdown(),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isPosting ? null : postEvent,
                      icon: isPosting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add),
                      label: Text(
                        isPosting ? 'Posting...' : 'Create Event',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}