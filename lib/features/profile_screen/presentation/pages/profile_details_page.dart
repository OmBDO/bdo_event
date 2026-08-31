import 'dart:async';

import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/util/resource/app_assets.dart';
import 'package:bdo_event/core/util/resource/app_locals.dart';
import 'package:bdo_event/core/util/resource/app_text.dart';
import 'package:bdo_event/core/util/ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bdo_event/core/common/profile_image/picker.dart';
import 'package:bdo_event/core/common/profile_image/profile_image_platform.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:gap/gap.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({
    required this.user,
    this.imagePicker,
    this.storeImage,
    this.deleteImage,
    super.key,
  });

  final User? user;
  final ProfileImagePicker? imagePicker;
  final StoreProfileImage? storeImage;
  final DeleteProfileImage? deleteImage;

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late final ProfileImagePicker _imagePicker =
      widget.imagePicker ?? GalleryProfileImagePicker();
  late final StoreProfileImage _storeImage =
      widget.storeImage ?? storePickedProfileImage;
  late final DeleteProfileImage _deleteImage =
      widget.deleteImage ?? deleteStoredProfileImage;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _bioController;
  final _pendingPhotoUrls = <String>{};
  String? _photoUrl;
  bool _removePhoto = false;
  late String _locale;
  var _isSaving = false;

  User? get user => widget.user;

  @override
  void initState() {
    super.initState();
    _photoUrl = user?.photoUrl;
    _phoneNumberController = TextEditingController(
      text: user?.phoneNumber ?? '',
    );
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locale = user?.locale ?? AppLocales.englishIndia;
  }

  @override
  void dispose() {
    unawaited(_deletePendingPhotoUrls());
    _phoneNumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName.trim() ?? '';
    final email = user?.email.trim() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppText.editProfile),
        actions: [
          IconButton(
            tooltip: AppText.saveProfile,
            onPressed: _isSaving ? null : _save,
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _ProfileSectionTitle(
              title: 'Account information',
              subtitle: 'Name and email are managed by your account.',
            ),
            _ReadOnlyProfileField(
              label: AppText.fullName,
              value: displayName,
              icon: Icons.person_outline_rounded,
            ),
            const Gap(AppSpace.space14),
            _ReadOnlyProfileField(
              label: AppText.emailAddress,
              value: email,
              icon: Icons.email_outlined,
            ),
            const Gap(AppSpace.space28),
            _ProfileSectionTitle(
              title: 'Personal details',
              subtitle: 'Update the information you want to share.',
            ),
            _ProfilePhotoPicker(
              photoUrl: _removePhoto ? null : _photoUrl,
              enabled: !_isSaving,
              onChange: _pickPhoto,
              onRemove: _removePhoto == false && _photoUrl != null
                  ? () => setState(() => _removePhoto = true)
                  : null,
            ),
            const Gap(AppSpace.space14),
            AppTextField(
              controller: _phoneNumberController,
              label: AppText.phoneNumber,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const Gap(AppSpace.space14),
            AppTextField(
              controller: _bioController,
              label: AppText.bio,
              icon: Icons.notes_rounded,
              maxLines: 4,
            ),
            const Gap(AppSpace.space14),
            DropdownButtonFormField<String>(
              initialValue: _locale,
              decoration: const InputDecoration(
                labelText: 'Language and region',
                prefixIcon: Icon(Icons.language_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppLocales.englishIndia,
                  child: Text(AppText.englishIndiaFull),
                ),
                DropdownMenuItem(
                  value: 'en-US',
                  child: Text(AppText.englishUnitedStates),
                ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) => setState(() => _locale = value ?? _locale),
            ),
            const Gap(AppSpace.space28),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Icons.save_rounded),
              label: Text(_isSaving ? 'Saving...' : AppText.saveProfile),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final originalPhotoUrl = user?.photoUrl;
    final nextPhotoUrl = _removePhoto ? '' : _photoUrl;
    final error = await context.read<ProfileScreenCubit>().updateProfile(
      displayName: user?.displayName ?? '',
      email: user?.email ?? '',
      photoUrl: nextPhotoUrl,
      phoneNumber: _phoneNumberController.text,
      bio: _bioController.text,
      locale: _locale,
    );
    if (!mounted) return;
    if (error != null) {
      await _deletePendingPhotoUrls();
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (originalPhotoUrl?.isNotEmpty == true &&
        originalPhotoUrl != nextPhotoUrl) {
      try {
        await _deleteImage(originalPhotoUrl!);
      } on Object {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppText.unableToDeleteProfilePhoto)),
        );
        return;
      }
    }
    if (nextPhotoUrl?.isNotEmpty == true) {
      _pendingPhotoUrls.remove(nextPhotoUrl);
    }
    await _deletePendingPhotoUrls();
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text(AppText.profileUpdated)));
    Navigator.of(context).pop();
  }

  Future<void> _pickPhoto() async {
    final image = await _imagePicker.pickImage();
    if (image == null) return;
    try {
      final url = await _storeImage(image);
      if (!mounted) {
        await _deletePhotoQuietly(url);
        return;
      }
      _pendingPhotoUrls.add(url);
      setState(() {
        _photoUrl = url;
        _removePhoto = false;
      });
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppText.unableToUploadProfilePhoto)),
        );
      }
    }
  }

  Future<void> _deletePendingPhotoUrls() async {
    final urls = Set<String>.of(_pendingPhotoUrls);
    _pendingPhotoUrls.clear();
    await Future.wait(urls.map(_deletePhotoQuietly));
  }

  Future<void> _deletePhotoQuietly(String url) async {
    try {
      await _deleteImage(url);
    } on Object {
      return;
    }
  }
}

class _ProfilePhotoPicker extends StatelessWidget {
  const _ProfilePhotoPicker({
    required this.photoUrl,
    required this.enabled,
    required this.onChange,
    required this.onRemove,
  });

  final String? photoUrl;
  final bool enabled;
  final VoidCallback onChange;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final imageProvider = photoUrl == null || photoUrl!.isEmpty
        ? const NetworkImage(AppAssets.defaultAvatarUrl)
        : NetworkImage(photoUrl!);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 34, backgroundImage: imageProvider),
            const Gap(AppSpace.space16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile photo',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Gap(AppSpace.space4),
                  Text(
                    'Use a photo that represents you.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Gap(AppSpace.space8),
                  Wrap(
                    spacing: AppSpace.space8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: enabled ? onChange : null,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text(AppText.change),
                      ),
                      if (onRemove != null)
                        TextButton(
                          onPressed: enabled ? onRemove : null,
                          child: const Text(AppText.remove),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Gap(AppSpace.space4),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class _ReadOnlyProfileField extends StatelessWidget {
  const _ReadOnlyProfileField({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: value,
    enabled: false,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: IconButton(
        tooltip: AppText.fieldCannotBeChanged,
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label is managed by your account.')),
        ),
        icon: const Icon(Icons.info_outline_rounded),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
