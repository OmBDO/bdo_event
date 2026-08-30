import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/drop_down_field.dart';
import 'package:bdo_event/core/model/event_model/event_catagory.dart';
import 'package:bdo_event/core/model/location_model/location_model.dart';
import 'package:bdo_event/core/model/location_model/location_catalog.dart';
import 'package:bdo_event/features/event_screen/presentation/cubit/event_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:bdo_event/core/common/event_image/event_image.dart';
import 'package:bdo_event/core/common/event_image/event_image_platform.dart';
import 'package:bdo_event/core/model/event_model/event_model.dart';
import 'package:bdo_event/core/util/event_resource.dart';

// ignore: must_be_immutable
class CreateEventPage extends StatefulWidget {
  final Event? event;
  final bool popParentOnCreateSuccess;
  EventCategory? catagory;

  CreateEventPage({
    super.key,
    this.event,
    this.catagory,
    this.popParentOnCreateSuccess = false,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _registrationDeadlineController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _selectedImagePath;
  String? _originalImagePath;
  final _pendingImagePaths = <String>{};
  Location? _selectedLocation;
  LatLng? _selectedCoordinates;
  EventCategory? _selectedCategory;
  final _locationSearchController = TextEditingController();
  bool _isSaving = false;
  bool _isCancelling = false;
  bool _seatLimitEnabled = false;
  bool _registrationDeadlineEnabled = false;
  DateTime? _registrationDeadline;
  int _locationSearchRequest = 0;

  bool get _isEditing => widget.event != null;

  final List<EventCategory> _categories = EventCategory.defaults;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _selectedCategory = _categoryMatching(widget.catagory ?? event?.catagory);
    if (event != null) {
      _titleController.text = event.title;
      _dateController.text = event.date;
      _startTimeController.text = event.startTime ?? '';
      _endTimeController.text = event.endTime ?? '';
      _seatLimitEnabled = event.capacity != null;
      _capacityController.text = event.capacity?.toString() ?? '';
      _registrationDeadline = event.registrationDeadline?.toLocal();
      _registrationDeadlineEnabled = _registrationDeadline != null;
      _registrationDeadlineController.text = _formatDateTime(
        _registrationDeadline,
      );
      _locationController.text = event.location;
      _selectedLocation = _officeLocations.where((location) {
        return location.id == event.locationId;
      }).firstOrNull;
      _selectedCoordinates = event.latitude != null && event.longitude != null
          ? LatLng(event.latitude!, event.longitude!)
          : null;
      _descriptionController.text = event.description;
      _selectedImagePath = event.imageUrl;
      _originalImagePath = event.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _registrationDeadlineController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null) return;

    try {
      final storedImagePath = await storePickedImage(image);
      if (mounted) {
        setState(() {
          _pendingImagePaths.add(storedImagePath);
          _selectedImagePath = storedImagePath;
        });
      } else {
        await deleteStoredImage(storedImagePath);
      }
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppText.unableToUploadEventImage)),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppText.missingEventImage)));
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
      startTime: _startTimeController.text.trim(),
      endTime: _endTimeController.text.trim(),
      capacity: _seatLimitEnabled
          ? int.tryParse(_capacityController.text.trim())
          : null,
      registrationDeadline: _registrationDeadlineEnabled
          ? _registrationDeadline
          : null,
      location: _locationController.text.trim(),
      imageUrl: _selectedImagePath!,
      description: _descriptionController.text.trim(),
      locationId: _selectedLocation?.id,
      locationAddress:
          _selectedLocation?.address ?? _locationController.text.trim(),
      latitude: _selectedCoordinates?.latitude,
      longitude: _selectedCoordinates?.longitude,
      createdAt: DateTime.now(),
      catagory: _selectedCategory,
    );
    final error = await context.read<EventScreenCubit>().save(
      event,
      isEditing: _isEditing,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      await _deletePendingImages();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    await _deletePendingImages(except: _selectedImagePath);
    if (_isEditing &&
        _originalImagePath != null &&
        _originalImagePath != _selectedImagePath) {
      await _tryDeleteImage(_originalImagePath!);
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? AppText.eventUpdated : AppText.eventCreated),
      ),
    );
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
    if (!_isEditing && widget.popParentOnCreateSuccess) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  Future<void> _deletePendingImages({String? except}) async {
    final paths = _pendingImagePaths.where((path) => path != except).toList();
    _pendingImagePaths.clear();
    if (paths.isEmpty) return;
    await Future.wait(paths.map(_tryDeleteImage));
  }

  Future<void> _tryDeleteImage(String path) async {
    try {
      await deleteStoredImage(path);
    } on Object catch (_) {}
  }

  Future<void> _cancel() async {
    if (_isCancelling) return;
    _isCancelling = true;
    await _deletePendingImages();
    if (mounted) Navigator.of(context).pop();
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

  Future<void> _pickTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: controller.text.isEmpty
          ? TimeOfDay.now()
          : _parseTime(controller.text) ?? TimeOfDay.now(),
    );
    if (time == null || !mounted) return;
    controller.text = _formatTime(time);
    setState(() {});
  }

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String? _validateTimeRange() {
    final start = _parseTime(_startTimeController.text.trim());
    final end = _parseTime(_endTimeController.text.trim());
    if (start == null || end == null) return 'Choose a start and end time';
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes
        ? null
        : 'End time must be after start time';
  }

  Future<void> _pickRegistrationDeadline() async {
    final now = DateTime.now();
    final current = _registrationDeadline ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2035),
      initialDate: DateTime(current.year, current.month, current.day),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (time == null || !mounted) return;
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _registrationDeadline = deadline;
      _registrationDeadlineController.text = _formatDateTime(deadline);
    });
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '${value.day}/${value.month}/${value.year} $hour:${value.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _searchLocation() async {
    final query = _locationSearchController.text.trim();
    if (query.isEmpty) return;
    final requestId = ++_locationSearchRequest;
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
    });
    try {
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'bdo-event'},
      );
      if (response.statusCode != 200) return;
      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty || !mounted || requestId != _locationSearchRequest) {
        return;
      }
      final result = results.first as Map<String, dynamic>;
      final coordinates = LatLng(
        double.parse(result['lat'] as String),
        double.parse(result['lon'] as String),
      );
      setState(() {
        _selectedLocation = null;
        _selectedCoordinates = coordinates;
        _locationController.text = result['display_name'] as String? ?? query;
      });
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to find that location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: _pendingImagePaths.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      _cancel();
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
                            color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppText.eventDetailsPrompt,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface
                                .withValues(alpha: 0.7),
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
                              color: Theme.of(context).colorScheme.surface
                                  .withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                              ),
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 520;
                            final fields = [
                              AppTextField(
                                controller: _dateController,
                                label: AppText.eventDate,
                                icon: Icons.calendar_today_outlined,
                                readOnly: true,
                                onTap: _pickDate,
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? AppText.chooseEventDate
                                    : null,
                              ),
                              AppTextField(
                                controller: _startTimeController,
                                label: 'Start time',
                                icon: Icons.schedule_outlined,
                                readOnly: true,
                                onTap: () => _pickTime(_startTimeController),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'Choose a start time'
                                    : null,
                              ),
                              AppTextField(
                                controller: _endTimeController,
                                label: 'End time',
                                icon: Icons.schedule_outlined,
                                readOnly: true,
                                onTap: () => _pickTime(_endTimeController),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Choose an end time';
                                  }
                                  return _validateTimeRange();
                                },
                              ),
                            ];
                            return compact
                                ? Column(
                                    children: [
                                      fields[0],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(child: fields[1]),
                                          const SizedBox(width: 12),
                                          Expanded(child: fields[2]),
                                        ],
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      Expanded(child: fields[0]),
                                      const SizedBox(width: 12),
                                      Expanded(child: fields[1]),
                                      const SizedBox(width: 12),
                                      Expanded(child: fields[2]),
                                    ],
                                  );
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Limit seats',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Switch(
                              value: _seatLimitEnabled,
                              onChanged: (enabled) =>
                                  setState(() => _seatLimitEnabled = enabled),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 96,
                              child: TextFormField(
                                controller: _capacityController,
                                enabled: _seatLimitEnabled,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  if (!_seatLimitEnabled) return null;
                                  final capacity = int.tryParse(
                                    value?.trim() ?? '',
                                  );
                                  return capacity == null || capacity < 1
                                      ? 'Enter a positive number'
                                      : null;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Seats',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Registration deadline',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Switch(
                              value: _registrationDeadlineEnabled,
                              onChanged: (enabled) => setState(() {
                                _registrationDeadlineEnabled = enabled;
                                if (!enabled) {
                                  _registrationDeadline = null;
                                  _registrationDeadlineController.clear();
                                }
                              }),
                            ),
                          ],
                        ),
                        if (_registrationDeadlineEnabled) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _registrationDeadlineController,
                            readOnly: true,
                            onTap: _pickRegistrationDeadline,
                            validator: (_) {
                              if (_registrationDeadline == null) {
                                return 'Choose a registration deadline';
                              }
                              if (!_registrationDeadline!.isAfter(
                                DateTime.now(),
                              )) {
                                return 'Deadline must be in the future';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              labelText: 'Deadline date and time',
                              prefixIcon: Icon(Icons.schedule_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppDropDownField<Location>(
                          label: AppText.location,
                          icon: Icons.location_on_outlined,
                          value: _selectedLocation,
                          validator: (value) =>
                              value == null &&
                                  _locationController.text.trim().isEmpty
                              ? AppText.enterEventLocation
                              : null,
                          items: [
                            const DropdownMenuItem<Location>(
                              value: null,
                              child: Row(
                                children: [
                                  Icon(Icons.location_searching_rounded),
                                  SizedBox(width: 12),
                                  Text('Select location'),
                                ],
                              ),
                            ),
                            ..._officeLocations.map(
                              (location) => DropdownMenuItem<Location>(
                                value: location,
                                child: Text(location.displayName),
                              ),
                            ),
                          ],
                          onChanged: (location) {
                            setState(() {
                              _selectedLocation = location;
                              _selectedCoordinates =
                                  location?.latitude != null &&
                                      location?.longitude != null
                                  ? LatLng(
                                      location!.latitude!,
                                      location.longitude!,
                                    )
                                  : null;
                              _locationController.text = location == null
                                  ? ''
                                  : location.address ?? location.displayName;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        _LocationPickerSection(
                          searchController: _locationSearchController,
                          coordinates: _selectedCoordinates,
                          locationLocked: _selectedLocation != null,
                          onSearch: _searchLocation,
                          onTap: (coordinates) {
                            setState(() {
                              _selectedCoordinates = coordinates;
                              _selectedLocation = null;
                              _locationController.text =
                                  '${coordinates.latitude.toStringAsFixed(5)}, '
                                  '${coordinates.longitude.toStringAsFixed(5)}';
                            });
                          },
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
                          value: _selectedCategory,
                          validator: (value) => value == null
                              ? AppText.pleaseSelectCategory
                              : null,
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
                              _selectedCategory = newValue;
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
                          isLoading: _isSaving,
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
      ),
    );
  }

  static const _officeLocations = LocationCatalog.offices;

  EventCategory? _categoryMatching(EventCategory? category) {
    if (category == null) return null;
    for (final option in _categories) {
      if (option.name.toLowerCase() == category.name.toLowerCase()) {
        return option;
      }
    }
    return null;
  }
}

class _LocationPickerSection extends StatelessWidget {
  const _LocationPickerSection({
    required this.searchController,
    required this.coordinates,
    required this.locationLocked,
    required this.onSearch,
    required this.onTap,
  });

  final TextEditingController searchController;
  final LatLng? coordinates;
  final bool locationLocked;
  final VoidCallback onSearch;
  final ValueChanged<LatLng> onTap;

  @override
  Widget build(BuildContext context) {
    final center = coordinates ?? const LatLng(20.5937, 78.9629);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => onSearch(),
          decoration: InputDecoration(
            hintText: 'Search an address or place',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: locationLocked ? null : onSearch,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          enabled: !locationLocked,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 230,
            child: FlutterMap(
              key: ValueKey(coordinates),
              options: MapOptions(
                initialCenter: center,
                initialZoom: coordinates == null ? 4.5 : 13,
                interactionOptions: InteractionOptions(
                  flags: locationLocked
                      ? InteractiveFlag.none
                      : InteractiveFlag.all,
                ),
                onTap: locationLocked ? null : (_, point) => onTap(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bdo.event',
                ),
                const RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                  ],
                ),
                if (coordinates != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: coordinates!,
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 42,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose an office above, search for a place, or tap the map to drop a pin.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
