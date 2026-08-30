import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/auth_scaffold.dart';
import 'package:bdo_event/core/common/form_elements/auth_switch.dart';
import 'package:bdo_event/core/util/helpers/validation_email.dart';
import 'package:bdo_event/core/util/event_resource.dart';
import 'package:flutter/material.dart';

import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_cubit.dart';
import 'package:bdo_event/features/auth_screen/signin_screen/presentation/cubit/signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    try {
      final authenticated = await context.read<SignInCubit>().submit(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      if (authenticated) widget.onAuthenticated();
    } catch (e) {
      if (mounted) {
        context.read<SignInCubit>().showError(
          AppText.unexpectedConnectionError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) => AuthScaffold(
        eyebrow: 'WELCOME BACK',
        title: AppText.signInTitle,
        subtitle: AppText.signInSubtitle,
        form: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _emailController,
                label: AppText.emailAddress,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: AppText.password,
                icon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                validator: (value) => value == null || value.isEmpty
                    ? AppText.enterPassword
                    : null,
                suffixIcon: IconButton(
                  tooltip: _isPasswordVisible
                      ? AppText.hidePassword
                      : AppText.showPassword,
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: AppText.signIn,
                isLoading: state.isSubmitting,
                onPressed: () =>
                    _submit(), // Protect against double-tapping submission
              ),
              const SizedBox(height: 24),
              AuthSwitch(
                prompt: AppText.newToApp,
                action: AppText.createAccountTitle,
                onTap: widget.onShowSignup,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
