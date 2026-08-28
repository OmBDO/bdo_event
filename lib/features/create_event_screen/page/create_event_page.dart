import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';

class CreateEventPage extends StatefulWidget {
  final Event? event;

  const CreateEventPage({super.key, this.event});

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
        const SnackBar(content: Text('Please add an event image')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final event = Event(
      id:
          widget.event?.id ??
          'created-${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      date: _dateController.text,
      location: _locationController.text.trim(),
      imageUrl: _selectedImagePath!,
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );
    final error = _isEditing
        ? await AuthRepository.updateEvent(event)
        : await AuthRepository.createEvent(event);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Event updated successfully'
              : 'Event created successfully',
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 76, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'UPDATE EVENT' : 'CREATE EVENT',
                    style: TextStyle(
                      color: Color(0xFFB14F36),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isEditing ? 'Update your event' : 'Bring people together',
                    style: TextStyle(
                      color: Color(0xFF2D0C57),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add the essential details and publish your next event.',
                    style: TextStyle(color: Color(0xFF6F607A), fontSize: 14),
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
                                Text('Add event image'),
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
                  _field(
                    controller: _titleController,
                    label: 'Event title',
                    icon: Icons.celebration_outlined,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter an event title'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _dateController,
                    label: 'Event date',
                    icon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Choose an event date'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter the event location'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.notes_outlined,
                    maxLines: 4,
                    validator: (value) =>
                        value == null || value.trim().length < 10
                        ? 'Add at least 10 characters'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        _isSaving
                            ? 'Saving event...'
                            : _isEditing
                            ? 'Update event'
                            : 'Create event',
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
