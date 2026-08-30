import 'package:bdo_event/core/di/app_dependencies.dart';
import 'package:bdo_event/core/security/biometric_lock_service.dart';
import 'package:bdo_event/features/profile_screen/presentation/cubit/profile_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiometricLockGate extends StatefulWidget {
  const BiometricLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends State<BiometricLockGate>
    with WidgetsBindingObserver {
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _lockIfEnabled());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _lockIfEnabled();
    }
    if (state == AppLifecycleState.resumed && _isLocked) {
      _authenticate();
    }
  }

  void _lockIfEnabled() {
    if (!mounted) return;
    final enabled = context.read<ProfileScreenCubit>().state.isBiometricLockEnabled;
    if (enabled && !_isLocked) setState(() => _isLocked = true);
  }

  Future<void> _authenticate() async {
    if (!_isLocked || _isAuthenticating || !mounted) return;
    _isAuthenticating = true;
    final unlocked = await getIt<BiometricLockService>().unlock();
    _isAuthenticating = false;
    if (mounted && unlocked) setState(() => _isLocked = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileScreenCubit, ProfileScreenState>(
      listenWhen: (previous, current) =>
          previous.isBiometricLockEnabled != current.isBiometricLockEnabled,
      listener: (context, state) {
        if (!state.isBiometricLockEnabled && _isLocked) {
          setState(() => _isLocked = false);
        }
      },
      child: Stack(
        children: [
          widget.child,
          if (_isLocked)
            Positioned.fill(
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: FilledButton.icon(
                    onPressed: _authenticate,
                    icon: const Icon(Icons.fingerprint_rounded),
                    label: const Text('Unlock app'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}