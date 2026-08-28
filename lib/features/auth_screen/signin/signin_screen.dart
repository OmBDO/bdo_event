import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/auth_switch.dart';
import 'package:bdo_event/core/util/helpers/validation_email.dart';
import 'package:flutter/material.dart';

import 'package:bdo_event/features/auth_screen/auth_repository.dart';

import '../../../core/common/form_elements/auth_scaffold.dart';

class SigninScreen extends StatefulWidget {
  final String? initialEmail;
  final VoidCallback onShowSignup;
  final VoidCallback onAuthenticated;

  const SigninScreen({
    super.key,
    this.initialEmail,
    required this.onShowSignup,
    required this.onAuthenticated,
  });

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();

    // Clear old errors instantly before re-evaluating the local form
    setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Fix: Added .trim() to clean up trailing whitespaces common with keyboard auto-suggestions
      final error = await AuthRepository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      if (error != null) {
        setState(() => _authError = error);
        return;
      }

      widget.onAuthenticated();
    } catch (e) {
      // Fallback structural safety in case your AuthRepository throws an uncaught exception
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _authError = 'An unexpected connection error occurred.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: 'WELCOME BACK',
      title: 'Sign in to continue',
      subtitle: 'Your next great event is only a few taps away.',
      form: Form(
        key: _formKey,
        child: Column(
          children: [
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
              obscureText: !_isPasswordVisible,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter your password' : null,
              suffixIcon: IconButton(
                tooltip: _isPasswordVisible ? 'Hide password' : 'Show password',
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            if (_authError != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _authError!,
                  style: const TextStyle(
                    color: Color(0xFFB64234),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: 'Sign in',
              isLoading: _isSubmitting,
              onPressed: () =>
                  _submit(), // Protect against double-tapping submission
            ),
            const SizedBox(height: 24),
            AuthSwitch(
              prompt: 'New to BDO Events? ',
              action: 'Create an account',
              onTap: widget.onShowSignup,
            ),
          ],
        ),
      ),
    );
  }
}
