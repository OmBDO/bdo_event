import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/auth_switch.dart';
import 'package:bdo_event/core/common/form_elements/section_header.dart';
import 'package:bdo_event/core/util/helpers/validation_email.dart';
import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:flutter/material.dart';

import '../../../core/common/form_elements/auth_scaffold.dart';

class SignupScreen extends StatefulWidget {
  final ValueChanged<String> onShowSignin;
  final void Function(String email)
  onSignedUp; // Fixed parameter matching assignment profile

  const SignupScreen({
    super.key,
    required this.onShowSignin,
    required this.onSignedUp, // Linked properly inside constructor parameter mappings
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _acceptTerms = false;
  String? _authError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 1. Define a state variable to track submission animations
  bool _isSubmitting = false;

  // 2. Change the method signature to async to handle storage tasks
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptTerms) {
      setState(
        () => _authError = 'You must accept the terms and privacy policy',
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 3. Call your repository to physically save the name, email, and password to LocalAuthStore
      final String? repositoryError = await AuthRepository.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // If the database complains (e.g. account already exists), display the message and stop
      if (repositoryError != null) {
        setState(() => _authError = repositoryError);
        return;
      }

      // 4. Success path: Pass the email out to the wrapper class to pre-fill the sign-in form
      widget.onSignedUp(_emailController.text.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _authError =
            'An unexpected error occurred while writing user credentials.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: 'JOIN THE COMMUNITY',
      title: 'Create your account',
      subtitle: 'Save events, manage registrations, and never miss a moment.',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Full name',
              icon: Icons.person_outline_rounded,
              keyboardType: TextInputType.name,
              validator: (value) => value == null || value.trim().length < 2
                  ? 'Enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Email address',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline_rounded,
              obscureText: !_showPassword,
              validator: (value) => value == null || value.length < 8
                  ? 'Use at least 8 characters'
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm password',
              icon: Icons.verified_user_outlined,
              obscureText: !_showConfirmPassword,
              validator: (value) => value != _passwordController.text
                  ? 'Passwords do not match'
                  : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _showConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(
                  () => _showConfirmPassword = !_showConfirmPassword,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Fix: Wrapped inside a transparent Material layout container to clear runtime splash errors
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: _acceptTerms,
                onChanged: (value) =>
                    setState(() => _acceptTerms = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('I agree to the terms and privacy policy'),
              ),
            ),

            if (_authError != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _authError!,
                  style: const TextStyle(color: Color(0xFFB64234)),
                ),
              ),
            ],
            const SizedBox(height: 18),

            AppButton(
              label: 'Create account',
              isLoading: false,
              onPressed: _submit,
            ),
            const SizedBox(height: 18),

            AuthSwitch(
              prompt: 'Already have an account? ',
              action: "Sign in",
              onTap: () => widget.onShowSignin(_emailController.text.trim()),
            ),
          ],
        ),
      ),
    );
  }
}
