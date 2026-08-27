import 'package:bdo_event/features/auth_screen/auth_repository.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  final ValueChanged<String> onShowSignin;
  final ValueChanged<String> onSignedUp;

  const SignupScreen({
    super.key,
    required this.onShowSignin,
    required this.onSignedUp,
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

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _authError = 'Please accept the terms to continue');
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final error = await AuthRepository.register(
      name: _nameController.text,
      email: email,
      password: _passwordController.text,
    );
    if (error != null) {
      setState(() => _authError = error);
      return;
    }
    widget.onSignedUp(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFB1D4FA), Color(0xFFFFF1E6), Color(0xFFF9CBB0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BrandMark(),
                    const SizedBox(height: 30),
                    const Text(
                      'JOIN THE COMMUNITY',
                      style: TextStyle(
                        color: Color(0xFFB14F36),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        color: Color(0xFF2D0C57),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Save events, manage registrations, and never miss a moment.',
                      style: TextStyle(color: Color(0xFF6F607A), fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F7A4C43),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _field(
                              _nameController,
                              'Full name',
                              Icons.person_outline_rounded,
                              TextInputType.name,
                              (value) =>
                                  value == null || value.trim().length < 2
                                  ? 'Enter your full name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _emailController,
                              'Email address',
                              Icons.mail_outline_rounded,
                              TextInputType.emailAddress,
                              _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _passwordController,
                              'Password',
                              Icons.lock_outline_rounded,
                              null,
                              (value) => value == null || value.length < 8
                                  ? 'Use at least 8 characters'
                                  : null,
                              obscureText: !_showPassword,
                              suffix: _visibilityButton(
                                _showPassword,
                                () => setState(
                                  () => _showPassword = !_showPassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _field(
                              _confirmPasswordController,
                              'Confirm password',
                              Icons.verified_user_outlined,
                              null,
                              (value) => value != _passwordController.text
                                  ? 'Passwords do not match'
                                  : null,
                              obscureText: !_showConfirmPassword,
                              suffix: _visibilityButton(
                                _showConfirmPassword,
                                () => setState(
                                  () => _showConfirmPassword =
                                      !_showConfirmPassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _acceptTerms,
                              onChanged: (value) =>
                                  setState(() => _acceptTerms = value ?? false),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'I agree to the terms and privacy policy',
                              ),
                            ),
                            if (_authError != null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _authError!,
                                  style: const TextStyle(
                                    color: Color(0xFFB64234),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _submit,
                                child: const Text('Create account'),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: Color(0xFF6F607A)),
                                ),
                                TextButton(
                                  onPressed: () => widget.onShowSignin(
                                    _emailController.text.trim(),
                                  ),
                                  child: const Text('Sign in'),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon,
    TextInputType? keyboardType,
    String? Function(String?) validator, {
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _visibilityButton(bool visible, VoidCallback onPressed) {
    return IconButton(
      tooltip: visible ? 'Hide password' : 'Show password',
      onPressed: onPressed,
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF2D0C57),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        const Text(
          'BDO Events',
          style: TextStyle(
            color: Color(0xFF2D0C57),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
