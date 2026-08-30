import 'package:bdo_event/core/common/form_elements/app_text_field.dart';
import 'package:bdo_event/core/common/form_elements/auth_button.dart';
import 'package:bdo_event/core/common/form_elements/auth_scaffold.dart';
import 'package:bdo_event/core/common/form_elements/auth_switch.dart';
import 'package:bdo_event/core/util/helpers/validation_email.dart';
import 'package:bdo_event/core/util/event.resource.dart';
import 'package:bdo_event/core/model/user_model/user_model.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_cubit.dart';
import 'package:bdo_event/features/auth_screen/signup_screen/presentation/cubit/signup_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  UserRole _requestedRole = UserRole.user;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptTerms) {
      context.read<SignUpCubit>().showError(AppText.acceptTerms);
      return;
    }

    try {
      final error = await context.read<SignUpCubit>().submit(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        requestedRole: _requestedRole,
      );

      if (!mounted) return;
      if (error == null) widget.onSignedUp(_emailController.text.trim());
    } catch (e) {
      if (mounted) {
        context.read<SignUpCubit>().showError(
          AppText.unexpectedCredentialError,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpCubit, SignUpState>(
      builder: (context, state) => AuthScaffold(
        eyebrow: 'JOIN THE COMMUNITY',
        title: AppText.createAccountTitle,
        subtitle: AppText.createAccountSubtitle,
        form: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _nameController,
                label: AppText.fullName,
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                validator: (value) => value == null || value.trim().length < 2
                    ? AppText.enterFullName
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: _requestedRole,
                decoration: const InputDecoration(labelText: AppText.role),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(switch (role) {
                          UserRole.user => AppText.roleUser,
                          UserRole.admin => AppText.roleAdmin,
                          UserRole.watcher => AppText.roleWatcher,
                        }),
                      ),
                    )
                    .toList(),
                onChanged: (role) {
                  if (role != null) setState(() => _requestedRole = role);
                },
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(AppText.roleRequestNote),
                ),
              ),
              const SizedBox(height: 16),
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
                obscureText: !_showPassword,
                validator: (value) => value == null || value.length < 8
                    ? AppText.useAtLeastEightCharacters
                    : null,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmPasswordController,
                label: AppText.confirmPassword,
                icon: Icons.verified_user_outlined,
                obscureText: !_showConfirmPassword,
                validator: (value) => value != _passwordController.text
                    ? AppText.passwordsDoNotMatch
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

              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (value) =>
                      setState(() => _acceptTerms = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(AppText.termsAgreement),
                ),
              ),

              if (state.error != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              AppButton(
                label: AppText.createAccount,
                isLoading: state.isSubmitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 18),

              AuthSwitch(
                prompt: AppText.alreadyHaveAccount,
                action: AppText.signIn,
                onTap: () => widget.onShowSignin(_emailController.text.trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
