import 'package:bdo_event/core/util/event.resource.dart';
import 'package:flutter/material.dart';

class ProfileEditDialog extends StatefulWidget {
  const ProfileEditDialog({
    required this.initialDisplayName,
    required this.initialEmail,
    required this.onSave,
    super.key,
  });

  final String initialDisplayName;
  final String initialEmail;
  final Future<String?> Function({
    required String displayName,
    required String email,
  }) onSave;

  @override
  State<ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<ProfileEditDialog> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.initialDisplayName);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text(AppText.editProfile),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _displayNameController,
            enabled: !_isSaving,
            decoration: const InputDecoration(labelText: AppText.fullName),
            validator: (value) => value?.trim().isEmpty ?? true
                ? AppText.fullName
                : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            enabled: !_isSaving,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: AppText.emailAddress),
            validator: (value) {
              final email = value?.trim() ?? '';
              return email.contains('@') && email.contains('.')
                  ? null
                  : AppText.validEmail;
            },
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
        child: const Text(AppText.cancel),
      ),
      FilledButton(
        onPressed: _isSaving ? null : _save,
        child: const Text(AppText.saveProfile),
      ),
    ],
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final error = await widget.onSave(
      displayName: _displayNameController.text,
      email: _emailController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.of(context).pop(true);
  }
}
