import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/drop_down_field.dart';
import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event.resource.dart';

class CreateEventPage extends StatefulWidget {
  final Event? event;
  EventCategory? catagory;

  CreateEventPage({super.key, this.event, this.catagory});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;
  bool _isSaving = false;

  bool get _isEditing => widget.event != null;

  final List<EventCategory> _categories = EventCategory.defaults;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    if (event != null) {
      _titleController.text = event.title;
      _dateController.text = event.date;
      _locationController.text = event.location;
      _descriptionController.text = event.description;
      _selectedImagePath = event.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return;

    final storedImagePath = await storePickedImage(image);
    if (mounted) setState(() => _selectedImagePath = storedImagePath);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppText.missingEventImage)),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final event = Event(
      id:
          widget.event?.id ??
          '${AppIdentifiers.createdEventPrefix}${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      date: _dateController.text,
      location: _locationController.text.trim(),
      imageUrl: _selectedImagePath!,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
      catagory: widget.catagory,
    );
    final error = await context.read<EventScreenCubit>().save(
      event,
      isEditing: _isEditing,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? AppText.eventUpdated
              : AppText.eventCreated,
        ),
      ),
    );
    if (_isEditing) {
      Navigator.of(context).pop();
      return;
    }
    _formKey.currentState!.reset();
    _titleController.clear();
    _dateController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() => _selectedImagePath = null);
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (date == null) return;
    _dateController.text = '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isEditing
                          ? AppText.updateEventEyebrow
                          : AppText.createEventEyebrow,
                        style: TextStyle(
                          color: Color(0xFFB14F36),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isEditing
                            ? AppText.updateYourEvent
                            : AppText.bringPeopleTogether,
                        style: TextStyle(
                          color: Color(0xFF2D0C57),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        AppText.eventDetailsPrompt,
                        style: TextStyle(
                          color: Color(0xFF6F607A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                          child: _selectedImagePath == null
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 36,
                                    ),
                                    SizedBox(height: 8),
                                    Text(AppText.addEventImage),
                                  ],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: EventImage(
                                    path: _selectedImagePath!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _titleController,
                        label: AppText.eventTitle,
                        icon: Icons.celebration_outlined,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? AppText.enterEventTitle
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _dateController,
                        label: AppText.eventDate,
                        icon: Icons.calendar_today_outlined,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (value) => value == null || value.isEmpty
                            ? AppText.chooseEventDate
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _locationController,
                        label: AppText.location,
                        icon: Icons.location_on_outlined,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? AppText.enterEventLocation
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _descriptionController,
                        label: AppText.description,
                        icon: Icons.notes_outlined,
                        maxLines: 4,
                        validator: (value) =>
                            value == null || value.trim().length < 10
                            ? AppText.addAtLeastTenCharacters
                            : null,
                      ),

                      const SizedBox(height: 24),

                      AppDropDownField<EventCategory>(
                        label: AppText.selectCategory,
                        icon: Icons.category_outlined,
                        value: widget.catagory,
                        validator: (value) =>
                            value == null ? AppText.pleaseSelectCategory : null,
                        items: _categories.map((category) {
                          return DropdownMenuItem<EventCategory>(
                            value: category,
                            child: Row(
                              children: [
                                Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            widget.catagory = newValue;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        label: _isSaving
                            ? AppText.savingEvent
                            : _isEditing
                            ? AppText.updateEvent
                            : AppText.createEvent,
                        isLoading: false,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
